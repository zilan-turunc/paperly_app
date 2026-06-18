import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import 'ai_planner_provider.dart';
import 'plan_preview_sheet.dart';

class BrainDumpSheet extends ConsumerStatefulWidget {
  final DateTime date;
  const BrainDumpSheet({super.key, required this.date});

  @override
  ConsumerState<BrainDumpSheet> createState() => _BrainDumpSheetState();
}

class _BrainDumpSheetState extends ConsumerState<BrainDumpSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiPlannerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiPlannerProvider);

    ref.listen(aiPlannerProvider, (_, next) {
      if (next is AiPlannerResult) {
        Navigator.of(context).pop();
        showPlanPreviewSheet(context, widget.date, next.result);
      }
    });

    final isLoading = state is AiPlannerLoading;
    final error = state is AiPlannerError ? state.message : null;

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
              const Text('What\'s on your mind?',
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
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 7,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Dump everything here — tasks, meetings, worries, anything...',
              alignLabelWithHint: true,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(error, style: const TextStyle(fontSize: 13, color: AppColors.destructive)),
          ],
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isLoading || _controller.text.trim().isEmpty
                ? null
                : () => ref.read(aiPlannerProvider.notifier).plan(_controller.text.trim()),
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Plan my day'),
          ),
        ],
      ),
    );
  }
}

void showBrainDumpSheet(BuildContext context, DateTime date) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: BrainDumpSheet(date: date),
    ),
  );
}
