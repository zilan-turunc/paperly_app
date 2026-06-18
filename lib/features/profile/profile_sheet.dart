import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/env.dart';
import '../auth/auth_provider.dart';

class ProfileSheet extends ConsumerWidget {
  const ProfileSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.border,
                child: Icon(Icons.person_outline, size: 24, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.email ?? 'Guest',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    if (user == null)
                      const Text(
                        'Sign in to sync your data',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (user == null && Env.hasSupabase) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/auth');
              },
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 8),
          ],
          if (user != null) ...[
            OutlinedButton(
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
              ),
              child: const Text('Sign out'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _confirmDelete(context, ref),
              style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
              child: const Text('Delete account'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This will permanently delete your account and all data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

void showProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: const ProfileSheet(),
    ),
  );
}
