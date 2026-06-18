import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../daily/daily_provider.dart';
import 'plan_result.dart';

class PlanPreviewSheet extends ConsumerWidget {
  final DateTime date;
  final PlanResult result;
  const PlanPreviewSheet({super.key, required this.date, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Here's your plan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (result.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Nothing to add — try describing your day with more detail.",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (result.todos.isNotEmpty) ...[
                      const Text('TO DO',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      ...result.todos.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.check_box_outline_blank,
                                    size: 18, color: AppColors.accent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(t.title,
                                      style: const TextStyle(fontSize: 15)),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                    if (result.timeBlocks.isNotEmpty) ...[
                      const Text('SCHEDULE',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      ...result.timeBlocks.map((b) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: AppColors.blockColor(b.color),
                                      width: 4)),
                              color: AppColors.surface,
                              borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(b.label,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Text('${b.startTime} – ${b.endTime}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: result.isEmpty ? null : () async {
              await _applyPlan(ref);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Add to my day'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Start over',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Future<void> _applyPlan(WidgetRef ref) async {
    final notifier = ref.read(dailyNotifierProvider.notifier);
    for (final t in result.todos) {
      await notifier.addTodo(date, t.title);
    }
    for (final b in result.timeBlocks) {
      await notifier.addTimeBlock(
        date: date,
        label: b.label,
        startTime: b.startTime,
        endTime: b.endTime,
        note: b.note,
        color: b.color,
      );
    }
  }
}

void showPlanPreviewSheet(BuildContext context, DateTime date, PlanResult result) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: PlanPreviewSheet(date: date, result: result),
    ),
  );
}
