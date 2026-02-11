// lib/features/assistant/assistant_screen.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yauctor_ai/features/journey/screens/journeys_overview_screen.dart';
import 'chat_message_model.dart';
import 'services/openrouter_service.dart';
import 'services/ai_assistant_commands.dart'; // Добавлен импорт
import '../../core/utils/logger_service.dart';
import '../../features/home/providers/daily_reflection_provider.dart';
import '../../features/home/daily_reflection_screen.dart';
// Добавлен импорт
import '../../features/journey/journey_screen.dart'; // Добавлен импорт

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _historyScrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      text:
          "Привет! Я Yauctor AI.\n\n"
          "Я помогу вам:\n"
          "• Пройти симуляцию жизненного пути 🎯\n"
          "• Сохранять мысли в дневник 📔\n"
          "• Анализировать ваш прогресс 📈\n\n"
          "Просто напишите что у вас на душе!",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  bool _isTyping = false;
  bool _showHistoryPanel = false;
  Widget? _actionButton; // Для отображения кнопки действия

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty || _isTyping) return;

    // Добавляем сообщение пользователя
    setState(() {
      _messages.add(
        ChatMessageModel(
          text: userText,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
      _actionButton = null; // Сбрасываем кнопку действия
    });

    _controller.clear();
    _focusNode.unfocus();
    _scrollToBottom();

    try {
      // ПЕРВОЕ: Проверяем специальные команды симуляции
      if (SimulationCommands.isSimulationCommand(userText)) {
        await _handleSimulationCommand(userText);
        return;
      }

      if (SimulationCommands.isSimulationHistoryRequest(userText)) {
        await _handleSimulationHistoryRequest();
        return;
      }

      // ВТОРОЕ: Если не команда симуляции, используем AI
      await _handleRegularAIRequest(userText);
    } catch (e, stackTrace) {
      Log.e('Message handling failed', error: e, stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessageModel(
            text: "Произошла ошибка. Попробуйте позже.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }

    _scrollToBottom();
  }

  // Обработчик команды симуляции
  Future<void> _handleSimulationCommand(String userText) async {
    final simulationCount = ref.read(simulationCountProvider);
    final hasSimulations = simulationCount > 0;

    final response = SimulationCommands.generateSimulationResponse(
      hasSimulations: hasSimulations,
      simulationCount: simulationCount,
    );

    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessageModel(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );

      // Добавляем кнопку действия
      _actionButton = SimulationActionButton(
        label: hasSimulations ? 'Новая симуляция' : 'Начать симуляцию',
        onPressed: () => SimulationCommands.navigateToSimulation(context),
        icon: Icons.auto_awesome,
      );
    });
  }

  // Обработчик запроса истории симуляций
  Future<void> _handleSimulationHistoryRequest() async {
    final response = await SimulationCommands.generateHistoryResponse(ref);

    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessageModel(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );

      // Добавляем кнопки действия
      _actionButton = Column(
        children: [
          SimulationActionButton(
            label: 'Посмотреть все симуляции',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const JourneysOverviewScreen()),
            ),
            icon: Icons.timeline,
          ),
          const SizedBox(height: 8),
          SimulationActionButton(
            label: 'Новая симуляция',
            onPressed: () => SimulationCommands.navigateToSimulation(context),
            icon: Icons.add,
          ),
        ],
      );
    });
  }

  // Обработчик обычного AI запроса
  Future<void> _handleRegularAIRequest(String userText) async {
    final openRouterService = ref.read(openRouterServiceProvider);

    // Получаем ответ от AI
    final aiResponse = await openRouterService.getChatCompletion(
      userMessage: userText,
      context: [],
      ref: ref, // Передаем ref для доступа к данным
    );

    if (!mounted) return;

    // Сохраняем в дневник только если пользователь явно попросил
    if (_shouldSaveToJournal(userText)) {
      await _saveToJournalFromRequest(userText);
    }

    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessageModel(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  // Проверяем, просит ли пользователь сохранить в дневник
  bool _shouldSaveToJournal(String userText) {
    final lowerText = userText.toLowerCase();
    return lowerText.contains('сохрани в дневник') ||
        lowerText.contains('запиши в дневник') ||
        lowerText.contains('добавь в дневник') ||
        lowerText.startsWith('сохрани:') ||
        lowerText.startsWith('запиши:');
  }

  // Сохраняем в дневник по просьбе пользователя
  Future<void> _saveToJournalFromRequest(String userText) async {
    try {
      final regex = RegExp(
        r'(сохрани|запиши|добавь)\s+в\s+дневник[:\s,]*',
        caseSensitive: false,
      );
      final match = regex.firstMatch(userText);

      String journalText = '';

      if (match != null) {
        // Извлекаем текст после команды
        journalText = userText.substring(match.end).trim();
      } else {
        // Если формат другой, берем все сообщение
        journalText = userText;
      }

      if (journalText.isNotEmpty) {
        await ref
            .read(dailyReflectionsProvider.notifier)
            .addReflection(journalText);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Запись сохранена в дневник'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      Log.w('Journal save failed: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _navigateToJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DailyReflectionScreen()),
    );
  }

  void _toggleHistoryPanel() {
    setState(() {
      _showHistoryPanel = !_showHistoryPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final journalCount = ref.watch(reflectionCountProvider);
    final simulationCount = ref.watch(simulationCountProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Yauctor AI"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Badge с количеством симуляций
          IconButton(
            icon: Badge(
              label: Text('$simulationCount'),
              isLabelVisible: simulationCount > 0,
              child: const Icon(Icons.timeline_outlined),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const JourneysOverviewScreen()),
            ),
            tooltip: 'Мой путь (симуляции)',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _toggleHistoryPanel,
            tooltip: 'История сообщений',
          ),
          IconButton(
            icon: Badge(
              label: Text('$journalCount'),
              isLabelVisible: journalCount > 0,
              child: const Icon(Icons.book_outlined),
            ),
            onPressed: _navigateToJournal,
            tooltip: 'Дневник',
          ),
        ],
      ),
      body: Row(
        children: [
          // Панель истории сообщений (скрываемая)
          if (_showHistoryPanel) _buildHistoryPanel(),

          // Основной чат
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildChatBubble(message);
                    },
                  ),
                ),

                // Кнопка действия (если есть)
                if (_actionButton != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _actionButton!,
                  ),

                if (_isTyping) _buildTypingIndicator(),
                _buildInputField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'История',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: _toggleHistoryPanel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Список сообщений
          Expanded(
            child: ListView.builder(
              controller: _historyScrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildHistoryItem(message, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ChatMessageModel message, int index) {
    final time = DateFormat('HH:mm').format(message.timestamp);
    final preview = message.text.length > 30
        ? '${message.text.substring(0, 30)}...'
        : message.text;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: message.isUser
            ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
            : const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: message.isUser
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
              : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: message.isUser
              ? const Color(0xFF8B5CF6)
              : const Color(0xFFF5F3FF),
          radius: 12,
          child: Icon(
            message.isUser ? Icons.person : Icons.smart_toy,
            size: 12,
            color: message.isUser ? Colors.white : const Color(0xFF8B5CF6),
          ),
        ),
        title: Text(
          message.isUser ? 'Вы' : 'Yauctor',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: message.isUser
                ? const Color(0xFF8B5CF6)
                : Colors.grey.shade700,
          ),
        ),
        subtitle: Text(
          preview,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          time,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
        onTap: () {
          // Прокручиваем к сообщению при клике
          _scrollToMessage(index);
        },
      ),
    );
  }

  void _scrollToMessage(int index) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        index * 100.0, // Примерная высота
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildChatBubble(ChatMessageModel message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF8B5CF6) : const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isUser
                  ? const Radius.circular(20)
                  : const Radius.circular(4),
              bottomRight: isUser
                  ? const Radius.circular(4)
                  : const Radius.circular(20),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: isUser ? Colors.white : const Color(0xFF1F1F29),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDot(0),
            const SizedBox(width: 4),
            _buildTypingDot(1),
            const SizedBox(width: 4),
            _buildTypingDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Кнопка быстрой симуляции
            IconButton(
              icon: const Icon(
                Icons.auto_awesome_outlined,
                color: Color(0xFF6366F1),
              ),
              onPressed: () {
                _controller.text = "проведи симуляцию";
                _focusNode.requestFocus();
              },
              tooltip: "Начать симуляцию",
            ),
            // Кнопка быстрой записи в дневник
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: Color(0xFF8B5CF6)),
              onPressed: () {
                _controller.text = "сохрани в дневник: ";
                _focusNode.requestFocus();
              },
              tooltip: "Быстрая запись в дневник",
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !_isTyping,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _isTyping
                        ? "ИИ думает..."
                        : "Напишите сообщение...",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _isTyping ? Colors.grey[300] : const Color(0xFF8B5CF6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
                onPressed: _isTyping ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _historyScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
