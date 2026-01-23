// lib/features/home/calendar_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:yauctor_ai/features/home/widgets/event_list_dialog.dart';
import 'package:yauctor_ai/services/event_service.dart';
import '../home/models/event_model.dart';
import '../home/widgets/add_event_dialog.dart';
import '../home/widgets/event_details_dialog.dart';

class CalendarScheduleScreen extends StatefulWidget {
  const CalendarScheduleScreen({super.key});

  @override
  State<CalendarScheduleScreen> createState() => _CalendarScheduleScreenState();
}

class _CalendarScheduleScreenState extends State<CalendarScheduleScreen> {
  final Color _accentColor = const Color(0xFFFFD54F);
  DateTime _selectedDate = DateTime.now();
  late DateTime _currentMonth;
  List<EventModel> _events = [];
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventService.getEventsForMonth(_currentMonth);
      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  Future<void> _onDateSelected(DateTime date) async {
    final eventForDate = _events
        .where(
          (event) =>
              event.date.year == date.year &&
              event.date.month == date.month &&
              event.date.day == date.day,
        )
        .toList();

    if (eventForDate.isNotEmpty) {
      await _showEventListDialog(date, eventForDate);
    } else {
      await _showAddEventDialog(date);
    }
  }

  Future<void> _showAddEventDialog(DateTime date) async {
    if (!mounted) return;

    final currentContext = context;
    final result = await showDialog<EventModel>(
      context: currentContext,
      builder: (context) =>
          AddEventDialog(selectedDate: date, accentColor: _accentColor),
    );

    if (result != null && mounted) {
      try {
        await _eventService.createEvent(result);
        await _loadEvents();
        setState(() {
          _selectedDate = date;
        });
      } catch (e) {
        _showErrorSnackbar('Failed to create event');
      }
    }
  }

  Future<void> _showEventListDialog(
    DateTime date,
    List<EventModel> events,
  ) async {
    if (!mounted) return;

    final currentContext = context;
    await showDialog(
      context: currentContext,
      builder: (dialogContext) => EventListDialog(
        date: date,
        events: events,
        accentColor: _accentColor,
        onAddEvent: () {
          Navigator.pop(dialogContext); // Убрали async/await
          _showAddEventDialog(date); // Убрали await
        },
        onEventTap: (event) {
          Navigator.pop(dialogContext); // Убрали async/await
          _showEventDetails(event); // Убрали await
        },
      ),
    );
  }

  Future<void> _showEventDetails(EventModel event) async {
    // Сохраняем контекст ДО асинхронной операции
    final currentContext = context;
    if (!mounted) return;

    await showDialog(
      context: currentContext,
      builder: (dialogContext) => EventDetailsDialog(
        event: event,
        accentColor: _accentColor,
        onDelete: () async {
          try {
            await _eventService.deleteEvent(event.id);
            await _loadEvents();
            if (mounted) {
              // Сохраняем dialogContext перед асинхронной операцией
              // Проверяем mounted перед закрытием диалога
              if (mounted) {
                if (!mounted) return;
                Navigator.of(context).pop();
              }
            }
          } catch (e) {
            if (mounted) {
              _showErrorSnackbar('Failed to delete event');
            }
          }
        },
        onEdit: (editedEvent) async {
          try {
            await _eventService.updateEvent(editedEvent);
            await _loadEvents();
            if (mounted) {
              // Сохраняем dialogContext перед асинхронной операцией
              // Проверяем mounted перед закрытием диалога
              if (mounted) {
                if (!mounted) return;
                Navigator.of(context).pop();
              }
            }
          } catch (e) {
            if (mounted) {
              _showErrorSnackbar('Failed to update event');
            }
          }
        },
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    // Используем WidgetsBinding.instance.addPostFrameCallback
    // чтобы убедиться, что context безопасен
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    });
  }

  List<int> _getDaysForMonth() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday;
    final previousMonthLastDay = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      0,
    );

    List<int> days = [];

    // Добавляем дни предыдущего месяца
    for (
      int i = previousMonthLastDay.day - firstWeekday + 1;
      i <= previousMonthLastDay.day;
      i++
    ) {
      days.add(i);
    }

    // Добавляем дни текущего месяца
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(i);
    }

    // Добавляем дни следующего месяца
    int nextMonthDays = 42 - days.length; // 6 недель * 7 дней = 42
    for (int i = 1; i <= nextMonthDays; i++) {
      days.add(i);
    }

    return days;
  }

  bool _hasEventForDay(int day) {
    return _events.any(
      (event) =>
          event.date.year == _currentMonth.year &&
          event.date.month == _currentMonth.month &&
          event.date.day == day,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),

          // Main Content with scroll
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with weather and profile
                  _buildHeader(),

                  const SizedBox(height: 24),

                  // Event Calendar Section
                  _buildCalendarSection(),

                  const SizedBox(height: 24),

                  // Tasks/Events List
                  _buildEventsList(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Weather Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "16°",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "C, London",
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildWeatherDetail(Icons.cloud, "It's foggy"),
              _buildWeatherDetail(Icons.thermostat, "Real feel: 16°"),
              _buildWeatherDetail(Icons.air, "Wind: WSW 6 mph"),
              _buildWeatherDetail(Icons.wb_sunny, "UV: 7"),
            ],
          ),

          // Profile Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 32, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Event calendar",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => _onDateSelected(_selectedDate),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeekDaysRow(),
          const SizedBox(height: 12),
          _buildCalendarDays(),
        ],
      ),
    );
  }

  Widget _buildWeekDaysRow() {
    final weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDays.map((day) {
        return SizedBox(
          width: 40,
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarDays() {
    final days = _getDaysForMonth();

    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: days.asMap().entries.map((entry) {
        final day = entry.value;
        final index = entry.key;
        final isCurrentMonth = index >= 7 && index < days.length - 14;
        final isSelected =
            isCurrentMonth &&
            day == _selectedDate.day &&
            _selectedDate.month == _currentMonth.month;
        final hasEvent = isCurrentMonth && _hasEventForDay(day);

        return GestureDetector(
          onTap: isCurrentMonth
              ? () async {
                  final selected = DateTime(
                    _currentMonth.year,
                    _currentMonth.month,
                    day,
                  );
                  await _onDateSelected(selected);
                }
              : null,
          child: SizedBox(
            width: 40,
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(
                              alpha: isCurrentMonth ? 0.2 : 0.1,
                            ),
                            width: 1,
                          ),
                  ),
                  child: Center(
                    child: Text(
                      "$day",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isCurrentMonth
                            ? (isSelected ? Colors.black : Colors.white)
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                if (hasEvent) ...[
                  const SizedBox(height: 3),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : _accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEventsList() {
    final todaysEvents = _events
        .where(
          (event) =>
              event.date.year == DateTime.now().year &&
              event.date.month == DateTime.now().month &&
              event.date.day == DateTime.now().day,
        )
        .toList();

    if (todaysEvents.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            "No events for today",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: todaysEvents.map((event) {
          return Column(
            children: [
              _buildEventCard(event: event),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventCard({required EventModel event}) {
    return GestureDetector(
      onTap: () => _showEventDetails(event),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[800],
              ),
              child: Center(
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${event.date.day}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (event.startTime != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      "${event.startTime!.hour}:${event.startTime!.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _accentColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_outward,
                color: Colors.black,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
