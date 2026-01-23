// lib/features/home/widgets/event_list_dialog.dart
import 'package:flutter/material.dart';
import '/features/home/models/event_model.dart';

class EventListDialog extends StatelessWidget {
  final DateTime date;
  final List<EventModel> events;
  final Color accentColor;
  final VoidCallback onAddEvent;
  final Function(EventModel) onEventTap;

  const EventListDialog({
    super.key,
    required this.date,
    required this.events,
    required this.accentColor,
    required this.onAddEvent,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Events',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...events.map(
              (event) => _buildEventItem(event),
            ), // Исправлено здесь
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAddEvent,
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add New Event'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: () => onEventTap(event),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.event, color: accentColor),
        ),
        title: Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: event.startTime != null
            ? Text(
                '${event.startTime!.hour}:${event.startTime!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
