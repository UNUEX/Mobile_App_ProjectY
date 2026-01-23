// lib/features/assistant/chat_message_model.dart
class ChatMessageModel {
  final String text;
  final bool isUser; // true = пользователь, false = AI
  final DateTime timestamp;
  final MessageStatus status; // Статус сообщения

  ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  ChatMessageModel copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return ChatMessageModel(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}

enum MessageStatus {
  sending, // Отправляется
  sent, // Отправлено
  error, // Ошибка
}
