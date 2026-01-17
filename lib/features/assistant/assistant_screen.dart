// lib/features/assistant/assistant_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'chat_message_model.dart';
import '../../ui/components/chat_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/simulation_state.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Начальное приветствие
  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      text:
          "Привет! Я твой AI-помощник Yauctor. Готов помочь с анализом симуляции или ответить на вопросы.",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  bool _isTyping = false;

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text;

    setState(() {
      _messages.add(
        ChatMessageModel(
          text: userText,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true; // AI начинает "печатать"
    });

    _controller.clear();
    _scrollToBottom();

    // Получаем данные симуляции
    final simulation = ref.read(simulationProvider);

    // Симуляция ответа AI
    Future.delayed(const Duration(seconds: 1, milliseconds: 300), () {
      if (!mounted) return;

      String aiResponse;

      // Проверяем на null и добавляем кастомное свойство isReady
      final isSimulationReady = simulation != null; // Проверяем, есть ли данные

      if (!isSimulationReady) {
        aiResponse =
            "Я пока не вижу данных симуляции. Запусти или загрузи симуляцию — и я дам точный анализ.";
      } else {
        // Теперь simulation точно не null
        // Используем свойства из вашего SimulationResult
        // Если нет свойства data.length, нужно добавить его в модель
        aiResponse =
            "Я проанализировал симуляцию.\n"
            "Входные данные: \"${simulation.input}\"\n"
            "Рекомендация: ${simulation.recommendation}";
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

      _scrollToBottom();
    });
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

  @override
  Widget build(BuildContext context) {
    final simulation = ref.watch(simulationProvider);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text("AI Assistant"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          // Можно показать иконку статуса симуляции
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              simulation == null ? Icons.sync_disabled : Icons.sync,
              color: simulation == null ? Colors.grey : AppColors.primary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Список сообщений
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),

          // Индикатор печати
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      "Yauctor печатает",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Поле ввода
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: simulation == null
                            ? "Спроси что-нибудь..." // если нет симуляции
                            : "Спроси про симуляцию \"${simulation.input}\"...", // если есть симуляция
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: _sendMessage,
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
