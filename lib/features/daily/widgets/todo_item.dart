import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/theme.dart';
import '../../../data/local/database.dart';
import '../daily_provider.dart';

class TodoItem extends ConsumerWidget {
  final Todo todo;
  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dailyNotifierProvider.notifier);

    return Slidable(
      key: ValueKey(todo.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (_) => notifier.deleteTodo(todo.id),
            backgroundColor: AppColors.destructive,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
          ),
        ],
      ),
      child: Container(
        color: AppColors.surface,
        child: Row(
          children: [
            Checkbox(
              value: todo.isDone,
              onChanged: (_) => notifier.toggleTodo(todo),
            ),
            Expanded(
              child: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 15,
                  color: todo.isDone ? AppColors.textPlaceholder : AppColors.textPrimary,
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.drag_handle, color: AppColors.textPlaceholder, size: 20),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
