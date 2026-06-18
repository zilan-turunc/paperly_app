import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/theme.dart';
import '../../../data/local/database.dart';
import '../daily_provider.dart';
import 'add_block_sheet.dart';

class TimeBlockItem extends ConsumerWidget {
  final TimeBlock block;
  const TimeBlockItem({super.key, required this.block});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dailyNotifierProvider.notifier);
    final color = AppColors.blockColor(block.color);

    return Slidable(
      key: ValueKey(block.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (_) => notifier.deleteTimeBlock(block.id),
            backgroundColor: AppColors.destructive,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => showAddBlockSheet(context, block.date, existing: block),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                block.label,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                              ),
                            ),
                            Text(
                              '${block.startTime} – ${block.endTime}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        if (block.note != null && block.note!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            block.note!,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
