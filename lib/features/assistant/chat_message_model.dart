//lib/features/assistant/chat_message_model.dart
class ChatMessageModel {
  final String text;
  final bool isUser; // true = я, false = AI
  final DateTime timestamp;

  ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
