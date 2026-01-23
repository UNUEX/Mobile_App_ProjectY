// lib/features/home/widgets/event_details_dialog.dart
import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventDetailsDialog extends StatefulWidget {
  final EventModel event;
  final Color accentColor;
  final VoidCallback onDelete;
  final Function(EventModel) onEdit;

  const EventDetailsDialog({
    super.key,
    required this.event,
    required this.accentColor,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<EventDetailsDialog> createState() => _EventDetailsDialogState();
}

class _EventDetailsDialogState extends State<EventDetailsDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(
      text: widget.event.description ?? '',
    );
    _locationController = TextEditingController(
      text: widget.event.location ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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
                  _isEditing ? 'Edit Event' : 'Event Details',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isEditing) ...[
              _buildTextField('Title', _titleController),
              const SizedBox(height: 16),
              _buildTextField(
                'Description',
                _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField('Location', _locationController),
              const SizedBox(height: 24),
            ] else ...[
              _buildDetailItem('Title', widget.event.title),
              if (widget.event.description?.isNotEmpty ?? false)
                _buildDetailItem('Description', widget.event.description!),
              if (widget.event.location?.isNotEmpty ?? false)
                _buildDetailItem('Location', widget.event.location!),
              if (widget.event.startTime != null)
                _buildDetailItem(
                  'Time',
                  '${widget.event.startTime!.hour}:${widget.event.startTime!.minute.toString().padLeft(2, '0')}',
                ),
              _buildDetailItem(
                'Date',
                '${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}',
              ),
              const SizedBox(height: 24),
            ],

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (_isEditing) {
                        final editedEvent = EventModel(
                          id: widget.event.id,
                          date: widget.event.date,
                          title: _titleController.text,
                          description: _descriptionController.text.isNotEmpty
                              ? _descriptionController.text
                              : null,
                          location: _locationController.text.isNotEmpty
                              ? _locationController.text
                              : null,
                          startTime: widget.event.startTime,
                          endTime: widget.event.endTime,
                          hasNotification: widget.event.hasNotification,
                          createdAt: widget.event.createdAt,
                          updatedAt: DateTime.now(),
                        );
                        widget.onEdit(editedEvent);
                      } else {
                        widget.onDelete();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isEditing
                          ? widget.accentColor
                          : Colors.red,
                      side: BorderSide(
                        color: _isEditing
                            ? widget.accentColor
                            : Colors.red.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_isEditing ? 'Save Changes' : 'Delete'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isEditing) {
                        setState(() => _isEditing = false);
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEditing
                          ? Colors.grey[800]
                          : widget.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Cancel' : 'Edit',
                      style: TextStyle(
                        color: _isEditing ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.accentColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
