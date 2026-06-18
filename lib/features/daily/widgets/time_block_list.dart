import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../daily_provider.dart';
import 'time_block_item.dart';
import 'add_block_sheet.dart';

class TimeBlockList extends ConsumerWidget {
  final DateTime date;
  const TimeBlockList({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(timeBlocksProvider(date));

    return blocksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
      data: (blocks) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SCHEDULE',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5),
                ),
                GestureDetector(
                  onTap: () => showAddBlockSheet(context, date),
                  child: const Icon(Icons.add, size: 20, color: AppColors.accent),
                ),
              ],
            ),
          ),
          if (blocks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Nothing yet — add something', style: TextStyle(fontSize: 14, color: AppColors.textPlaceholder)),
            )
          else
            ...blocks.map((b) => TimeBlockItem(key: ValueKey(b.id), block: b)),
        ],
      ),
    );
  }
}
