// lib/ui/components/chat_bubble.dart
import 'package:flutter/material.dart';
import '../../features/assistant/chat_message_model.dart';
import '../../core/constants/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Цвета по умолчанию, если AppColors не определены
    final primaryColor = AppColors.primary;
    final surfaceVariantColor = Colors.grey.shade100;
    final textPrimaryColor = Colors.black;
    final textSecondaryColor = Colors.grey.shade600;
    final borderColor = Colors.grey.shade300;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser ? primaryColor : surfaceVariantColor,
          borderRadius: BorderRadius.circular(20),
          border: message.isUser ? null : Border.all(color: borderColor),
          boxShadow: [
            if (!message.isUser)
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Аватар и имя (только для AI)
            if (!message.isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color.alphaBlend(
                        primaryColor.withAlpha((0.1 * 255).toInt()),
                        Colors.transparent,
                      ),
                      radius: 12,
                      child: Icon(
                        Icons.smart_toy,
                        size: 12,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Yauctor AI',
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Текст сообщения
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : textPrimaryColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            // Статус сообщения (только для пользователя)
            if (message.isUser && message.status != MessageStatus.sent)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Icon(
                  message.status == MessageStatus.error
                      ? Icons.error_outline
                      : Icons.access_time,
                  size: 12,
                  color: message.status == MessageStatus.error
                      ? Colors.red
                      : Colors.white.withValues(alpha: .6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
