// lib/features/home/daily_reflection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/daily_reflection_provider.dart';
import 'models/daily_reflection_model.dart';

class DailyReflectionScreen extends ConsumerStatefulWidget {
  const DailyReflectionScreen({super.key});

  @override
  ConsumerState<DailyReflectionScreen> createState() =>
      _DailyReflectionScreenState();
}

class _DailyReflectionScreenState extends ConsumerState<DailyReflectionScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Цветовая палитра
  final Color _accentColor = const Color(0xFF8B5CF6);
  final Color _lightBg = const Color(0xFFF5F3FF);
  final Color _darkText = const Color(0xFF1F1F29);
  final Color _successColor = const Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    // Автоматически фокусируемся на поле ввода при открытии
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      _scrollToTop();
    });
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(dailyReflectionsProvider.notifier).addReflection(text);
      _textController.clear();

      // Показываем подтверждение
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Запись сохранена'),
          backgroundColor: _successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Прокручиваем к началу, чтобы увидеть новую запись
      _scrollToTop();
    }
  }

  void _deleteEntry(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Удалить запись?"),
        content: const Text("Эта запись будет удалена безвозвратно."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () {
              ref.read(dailyReflectionsProvider.notifier).deleteReflection(id);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Запись удалена'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text("Удалить", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Показать статус синхронизации
  void _showSyncStatus(bool isSyncing) {
    if (isSyncing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Синхронизация с облаком...'),
            ],
          ),
          backgroundColor: _accentColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reflectionsAsync = ref.watch(dailyReflectionsProvider);
    final syncStatus = ref.watch(syncStatusProvider);

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
            icon: Icon(
              Icons.sync,
              color: syncStatus ? _accentColor : _darkText,
            ),
            onPressed: () async {
              if (!syncStatus) {
                ref.read(syncStatusProvider.notifier).state = true;
                _showSyncStatus(true);

                try {
                  await ref
                      .read(dailyReflectionsProvider.notifier)
                      .syncWithCloud();
                } finally {
                  ref.read(syncStatusProvider.notifier).state = false;
                }
              }
            },
            tooltip: 'Синхронизировать',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: _darkText),
            onPressed: () {
              ref.read(dailyReflectionsProvider.notifier).refresh();
            },
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: SafeArea(
        child: reflectionsAsync.when(
          data: (reflections) => _buildContent(reflections),
          loading: () => _buildLoading(),
          error: (error, stackTrace) => _buildError(error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(List<DailyReflectionModel> reflections) {
    final hasEntries = reflections.isNotEmpty;
    final syncStatus = ref.watch(syncStatusProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статистика
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _lightBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Всего записей',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '${reflections.length}',
                      style: TextStyle(
                        color: _darkText,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        if (syncStatus)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _accentColor,
                              ),
                            ),
                          ),
                        Text(
                          'Последняя запись',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      hasEntries
                          ? DateFormat('dd.MM').format(reflections.first.date)
                          : '—',
                      style: TextStyle(
                        color: _darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Заголовок с текущей датой
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
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
              controller: _scrollController,
              child: Column(
                children: [
                  // Текущая запись
                  Container(
                    decoration: BoxDecoration(
                      color: _lightBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _accentColor.withAlpha((0.2 * 255).toInt()),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withAlpha((0.1 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              color: _accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Today's Thoughts",
                              style: TextStyle(
                                color: _accentColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                                'Как прошел ваш день? Что вы чувствуете? О чем думаете?\n\nЭти записи помогают обучать ваш Digital Twin и улучшать рекомендации AI...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          cursorColor: _accentColor,
                          onSubmitted: (_) => _saveEntry(),
                        ),
                      ],
                    ),
                  ),

                  // Сохраненные записи
                  if (hasEntries) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Previous Entries',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _darkText,
                            ),
                          ),
                          Text(
                            '${reflections.length} записей',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...reflections.map((reflection) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(
                                (0.05 * 255).toInt(),
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _accentColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat(
                                              'MMM d, yyyy • HH:mm',
                                            ).format(reflection.date),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.more_vert,
                                          size: 18,
                                          color: Colors.grey[400],
                                        ),
                                        onPressed: () =>
                                            _deleteEntry(reflection.id),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    reflection.text,
                                    style: TextStyle(
                                      color: _darkText,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (reflection.emotion != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _accentColor.withAlpha(
                                          (0.1 * 255).toInt(),
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Настроение: ${reflection.emotion}',
                                        style: TextStyle(
                                          color: _accentColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
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
                            'Пока нет записей',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ваша первая запись появится здесь\n\nНачните писать в поле выше или скажите AI-помощнику "сохрани в дневник"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Ваши записи автоматически синхронизируются с облаком',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _accentColor.withValues(alpha: .7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Save Reflection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (syncStatus) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Загрузка дневника...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Ошибка загрузки дневника',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(dailyReflectionsProvider.notifier).refresh();
              },
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }
}
