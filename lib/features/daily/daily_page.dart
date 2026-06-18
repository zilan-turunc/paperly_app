import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/env.dart';
import '../../data/remote/supabase_sync.dart';
import '../profile/profile_sheet.dart';
import '../ai_planner/brain_dump_sheet.dart';
import 'daily_provider.dart';
import 'widgets/todo_list.dart';
import 'widgets/time_block_list.dart';

class DailyPage extends ConsumerStatefulWidget {
  const DailyPage({super.key});

  @override
  ConsumerState<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends ConsumerState<DailyPage> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _triggerSync,
    );
    // sync on first load
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerSync());
  }

  void _triggerSync() {
    ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
    ref.read(syncServiceProvider).sync().then((_) {
      if (mounted) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.idle;
      }
    }).catchError((_) {
      if (mounted) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      }
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(selectedDateProvider);
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(date: date, isToday: isToday),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TodoList(date: date),
                    const SizedBox(height: 28),
                    TimeBlockList(date: date),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  final DateTime date;
  final bool isToday;
  const _Header({required this.date, required this.isToday});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatted = DateFormat('EEEE, MMMM d').format(date);
    final syncStatus = ref.watch(syncStatusProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Wand button (AI planner)
          if (Env.hasOpenAi)
            IconButton(
              icon: const Icon(Icons.auto_fix_high_outlined, size: 20),
              onPressed: () => showBrainDumpSheet(context, date),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: AppColors.accent,
            ),
          if (Env.hasOpenAi) const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(selectedDateProvider.notifier).state =
                date.subtract(const Duration(days: 1)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatted,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                if (isToday)
                  const Text('Today',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.accent)),
              ],
            ),
          ),
          if (!isToday)
            TextButton(
              onPressed: () {
                final now = DateTime.now();
                ref.read(selectedDateProvider.notifier).state =
                    DateTime.utc(now.year, now.month, now.day);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child:
                  const Text('Today', style: TextStyle(fontSize: 13)),
            ),
          const SizedBox(width: 4),
          // Sync indicator
          if (syncStatus == SyncStatus.syncing)
            const SizedBox(
              width: 8,
              height: 8,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.accent,
              ),
            )
          else if (syncStatus == SyncStatus.error)
            const Icon(Icons.circle, size: 8, color: AppColors.destructive),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(selectedDateProvider.notifier).state =
                date.add(const Duration(days: 1)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => showProfileSheet(context),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.border,
              child: Icon(Icons.person_outline,
                  size: 18, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
