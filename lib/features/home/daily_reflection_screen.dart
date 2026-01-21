// lib/features/home/daily_reflection_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyReflectionScreen extends StatefulWidget {
  const DailyReflectionScreen({super.key});

  @override
  State<DailyReflectionScreen> createState() => _DailyReflectionScreenState();
}

class _DailyReflectionScreenState extends State<DailyReflectionScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Цветовая палитра
  final Color _accentColor = const Color(0xFF8B5CF6);
  final Color _lightBg = const Color(0xFFF5F3FF);
  final Color _darkText = const Color(0xFF1F1F29);

  // Сохраненные записи (в реальном приложении это было бы в базе данных)
  final List<Map<String, String>> _entries = [
    {
      'date': '2024-03-15',
      'text':
          'Сегодня был продуктивный день. Завершил проект и чувствую удовлетворение.',
    },
    {
      'date': '2024-03-14',
      'text':
          'Чувствовал усталость, но вечерняя прогулка помогла восстановить энергию.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Автоматически фокусируемся на поле ввода при открытии
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _entries.insert(0, {
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'text': _textController.text,
        });
        _textController.clear();

        // Показываем подтверждение
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Запись сохранена'),
            backgroundColor: _accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daily Reflection',
          style: TextStyle(
            color: _darkText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: _darkText),
            onPressed: () {
              // Дополнительные действия (экспорт, настройки и т.д.)
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с текущей датой
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                child: Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Поле для новой записи
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Текущая запись
                      Container(
                        decoration: BoxDecoration(
                          color: _lightBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _accentColor.withValues(alpha: 0.2),
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Thoughts",
                              style: TextStyle(
                                color: _accentColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              maxLines: null,
                              style: TextStyle(
                                fontSize: 16,
                                color: _darkText,
                                height: 1.5,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Как прошел ваш день? Что вы чувствуете? О чем думаете?\n\nЭти записи помогают обучать ваш Digital Twin...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                              ),
                              cursorColor: _accentColor,
                            ),
                          ],
                        ),
                      ),

                      // Сохраненные записи
                      if (_entries.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Previous Entries',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _darkText,
                            ),
                          ),
                        ),
                        ..._entries.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: _accentColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('MMM d, yyyy').format(
                                        DateFormat(
                                          'yyyy-MM-dd',
                                        ).parse(entry['date']!),
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry['text']!,
                                  style: TextStyle(
                                    color: _darkText,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ] else ...[
                        // Пустое состояние
                        Container(
                          margin: const EdgeInsets.only(top: 60),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.edit_note_rounded,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No entries yet',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your first reflection will appear here',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Кнопка сохранения
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Save Reflection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
