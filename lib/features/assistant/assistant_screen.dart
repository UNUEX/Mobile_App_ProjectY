// lib/features/assistant/assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Удалить импорт flutter_markdown
import 'chat_message_model.dart';
import '../../state/simulation_state.dart';
import 'services/openrouter_service.dart';
import '../../core/utils/logger_service.dart';
import '../../features/home/providers/daily_reflection_provider.dart';
import '../../features/home/daily_reflection_screen.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      text:
          "Привет! Я твой AI-помощник Yauctor.\n\n"
          "Я могу помочь тебе с:\n"
          "• Анализом твоих симуляций\n"
          "• Созданием новых сценариев\n"
          "• Ведением дневника рефлексии\n\n"
          "Просто начни диалог или скажи \"сохрани в дневник\" для быстрой записи мыслей.",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isTyping) return;

    final userText = _controller.text.trim();

    setState(() {
      _messages.add(
        ChatMessageModel(
          text: userText,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _controller.clear();
    _focusNode.unfocus();
    _scrollToBottom();

    try {
      final openRouterService = ref.read(openRouterServiceProvider);
      final simulations = ref.read(simulationsProvider);
      final journalEntries = _getJournalEntriesForAI();

      final simulationsJson = simulations
          .map(
            (sim) => {
              'id': sim.id,
              'scenarioTitle': sim.scenarioTitle,
              'createdAt': sim.createdAt.toIso8601String(),
              'metrics': sim.metrics,
              'recommendation': sim.recommendation,
            },
          )
          .toList();

      final simulationData = {
        'simulations': simulationsJson,
        'hasSimulations': simulations.isNotEmpty,
        'latestSimulation': simulations.isNotEmpty
            ? simulationsJson.last
            : null,
      };

      final aiResponse = await openRouterService.getChatCompletion(
        userMessage: userText,
        context: [],
        simulationData: simulationData,
        journalEntries: journalEntries,
      );

      if (!mounted) return;

      await _handleJournalSaveCommands(aiResponse);

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
    } catch (e, stackTrace) {
      Log.e('Failed to get AI response', error: e, stackTrace: stackTrace);
      if (!mounted) return;

      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessageModel(
            text: "Извините, возникла ошибка. Попробуйте позже.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }

    _scrollToBottom();
  }

  Future<void> _handleJournalSaveCommands(String aiResponse) async {
    final saveJournalRegex = RegExp(
      r'\[SAVE_TO_JOURNAL\](.*?)\[/SAVE_TO_JOURNAL\]',
      dotAll: true,
    );

    if (saveJournalRegex.hasMatch(aiResponse)) {
      final matches = saveJournalRegex.allMatches(aiResponse);

      for (final match in matches) {
        final journalText = match.group(1)?.trim() ?? '';
        if (journalText.isNotEmpty) {
          await ref
              .read(dailyReflectionsProvider.notifier)
              .addReflection(journalText);

          // Проверяем mounted перед использованием контекста
          if (!mounted) return;
          final currentContext = context;
          if (!currentContext.mounted) return;

          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: const Text('✅ Запись сохранена в дневник'),
              action: SnackBarAction(
                label: 'Открыть',
                onPressed: () => _navigateToJournal(),
              ),
            ),
          );
        }
      }
    }
  }

  List<Map<String, dynamic>> _getJournalEntriesForAI() {
    final reflections = ref.watch(formattedReflectionsProvider);
    return reflections
        .map(
          (r) => {
            'id': r.id,
            'text': r.text,
            'date': r.date,
            'emotion': r.emotion,
          },
        )
        .toList();
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

  void _showSaveToJournalDialog(String text) {
    final textController = TextEditingController(text: text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Сохранить в дневник"),
        content: TextField(
          controller: textController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "Отредактируйте текст...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () async {
              final txt = textController.text.trim();
              if (txt.isNotEmpty) {
                await ref
                    .read(dailyReflectionsProvider.notifier)
                    .addReflection(txt);

                // Проверяем mounted перед использованием контекста
                if (!mounted) return;
                final currentContext = context;
                if (!currentContext.mounted) return;

                Navigator.pop(currentContext);
                ScaffoldMessenger.of(currentContext).showSnackBar(
                  const SnackBar(content: Text('✅ Запись сохранена')),
                );
              }
            },
            child: const Text("Сохранить"),
          ),
        ],
      ),
    );
  }

  // Новая функция для простой обработки markdown
  Widget _buildFormattedText(String text) {
    // Простая обработка жирного текста (заменяем **текст**)
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    text.split(boldRegex);
    final matches = boldRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      // Если нет форматирования, просто возвращаем обычный текст
      return Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1F1F29),
          fontSize: 15,
          height: 1.4,
        ),
      );
    }

    // Собираем текст с форматированием
    final List<TextSpan> spans = [];
    int currentIndex = 0;

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];

      // Текст до жирного
      if (currentIndex < match.start) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: const TextStyle(
              color: Color(0xFF1F1F29),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        );
      }

      // Жирный текст
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(
            color: Color(0xFF1F1F29),
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      currentIndex = match.end;
    }

    // Текст после последнего совпадения
    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: const TextStyle(
            color: Color(0xFF1F1F29),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(
          color: Color(0xFF1F1F29),
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journalCount = ref.watch(reflectionCountProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Yauctor AI"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$journalCount'),
              isLabelVisible: journalCount > 0,
              child: const Icon(Icons.book_outlined),
            ),
            onPressed: _navigateToJournal,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildModernChatBubble(message);
              },
            ),
          ),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildModernChatBubble(ChatMessageModel message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Основное сообщение
            GestureDetector(
              onLongPress: !message.isUser
                  ? () => _showMessageMenu(message)
                  : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: message.isUser
                    ? Text(
                        message.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      )
                    : _buildFormattedText(
                        message.text,
                      ), // Используем нашу функцию вместо Markdown
              ),
            ),
            // Кнопки действий для AI сообщений
            if (!message.isUser && !_isTyping)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.content_copy,
                      tooltip: "Копировать",
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: message.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Текст скопирован'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    _buildActionButton(
                      icon: Icons.bookmark_add_outlined,
                      tooltip: "Сохранить в дневник",
                      onPressed: () => _showSaveToJournalDialog(message.text),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.grey[700]),
        ),
      ),
    );
  }

  void _showMessageMenu(ChatMessageModel message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text("Копировать"),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Текст скопирован')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_add),
              title: const Text("Сохранить в дневник"),
              onTap: () {
                Navigator.pop(context);
                _showSaveToJournalDialog(message.text);
              },
            ),
          ],
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final adjustedValue = (value - delay).clamp(0.0, 1.0);
        final opacity = (adjustedValue * 2).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isTyping) {
          setState(() {});
        }
      },
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
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: Color(0xFF8B5CF6)),
              onPressed: () {
                _controller.text = "сохрани в дневник: ";
                _focusNode.requestFocus();
              },
              tooltip: "Быстрая запись",
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
                  decoration: const InputDecoration(
                    hintText: "Напишите сообщение...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
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
    _focusNode.dispose();
    super.dispose();
  }
}
