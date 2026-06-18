import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../data/local/database.dart';
import '../daily_provider.dart';

class AddBlockSheet extends ConsumerStatefulWidget {
  final DateTime date;
  final TimeBlock? existing;
  const AddBlockSheet({super.key, required this.date, this.existing});

  @override
  ConsumerState<AddBlockSheet> createState() => _AddBlockSheetState();
}

class _AddBlockSheetState extends ConsumerState<AddBlockSheet> {
  final _labelController = TextEditingController();
  final _noteController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _color = 'slate';
  bool _loading = false;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _labelController.text = e.label;
      _noteController.text = e.note ?? '';
      _startTime = _parseTime(e.startTime);
      _endTime = _parseTime(e.endTime);
      _color = e.color ?? 'slate';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  bool _isEndAfterStart() {
    final startMins = _startTime.hour * 60 + _startTime.minute;
    final endMins = _endTime.hour * 60 + _endTime.minute;
    return endMins > startMins;
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
      _timeError = _isEndAfterStart() ? null : 'End time must be after start';
    });
  }

  Future<void> _submit() async {
    final label = _labelController.text.trim();
    if (label.isEmpty) return;
    if (!_isEndAfterStart()) {
      setState(() => _timeError = 'End time must be after start');
      return;
    }
    setState(() => _loading = true);
    final notifier = ref.read(dailyNotifierProvider.notifier);
    final note = _noteController.text.trim();
    if (widget.existing != null) {
      await notifier.updateTimeBlock(
        id: widget.existing!.id,
        label: label,
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
        note: note.isEmpty ? null : note,
        color: _color,
      );
    } else {
      await notifier.addTimeBlock(
        date: widget.date,
        label: label,
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
        note: note.isEmpty ? null : note,
        color: _color,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Edit block' : 'Add time block',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              autofocus: !isEdit,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Label (e.g. Deep work)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _TimePicker(label: 'Start', time: _startTime, onTap: () => _pickTime(true))),
                const SizedBox(width: 12),
                Expanded(child: _TimePicker(label: 'End', time: _endTime, onTap: () => _pickTime(false))),
              ],
            ),
            if (_timeError != null) ...[
              const SizedBox(height: 6),
              Text(_timeError!, style: const TextStyle(fontSize: 12, color: AppColors.destructive)),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Note (optional)'),
            ),
            const SizedBox(height: 12),
            _ColorPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _labelController.text.trim().isEmpty || _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Save' : 'Add block'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimePicker({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatted = time.format(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(formatted, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _ColorPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppColors.blockColors.entries.map((e) {
        final isSelected = e.key == selected;
        return GestureDetector(
          onTap: () => onChanged(e.key),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: e.value,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: AppColors.textPrimary, width: 2) : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

void showAddBlockSheet(BuildContext context, DateTime date, {TimeBlock? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => AddBlockSheet(date: date, existing: existing),
  );
}
