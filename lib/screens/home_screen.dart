import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/tasks_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_icon_button.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/section_label.dart';
import '../widgets/task_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listFilter = ref.watch(homeListFilterProvider);
    final tasksNotifier = ref.read(tasksProvider.notifier);

    final pending = tasksNotifier.filtered(
      listFilter: listFilter,
      isCompleted: false,
    );
    final completed = tasksNotifier.filtered(
      listFilter: listFilter,
      isCompleted: true,
    );

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
            child: Row(
              children: [
                Text(
                  'TaskAI',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 30,
                      ),
                ),
                const Spacer(),
                CircularIconButton(
                  icon: Icons.search_rounded,
                  onPressed: () {},
                ),
                const SizedBox(width: 10),
                CircularIconButton(
                  icon: Icons.notifications_rounded,
                  onPressed: () {},
                  backgroundColor: AppColors.notificationBell.withValues(alpha: 0.15),
                  iconColor: AppColors.notificationBell,
                  showDot: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const FilterChipsRow(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: [
                SectionLabel(
                  left: 'Hoy',
                  right: '${pending.length} pendientes',
                ),
                if (pending.isEmpty)
                  const _EmptyHint(message: 'No hay tareas pendientes')
                else
                  ...pending.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DismissibleTask(
                        taskId: task.id,
                        title: task.title,
                        onDismissed: () => ref
                            .read(tasksProvider.notifier)
                            .deleteTask(task.id),
                        child: TaskCard(
                          task: task,
                          onTap: () => context.push('/task/${task.id}'),
                          onToggleComplete: () => ref
                              .read(tasksProvider.notifier)
                              .toggleCompleted(task.id),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                SectionLabel(
                  left: 'Completadas',
                  right: '${completed.length}',
                ),
                if (completed.isEmpty)
                  const _EmptyHint(message: 'Aún no hay tareas completadas')
                else
                  ...completed.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DismissibleTask(
                        taskId: task.id,
                        title: task.title,
                        onDismissed: () => ref
                            .read(tasksProvider.notifier)
                            .deleteTask(task.id),
                        child: TaskCard(
                          task: task,
                          onTap: () => context.push('/task/${task.id}'),
                          onToggleComplete: () => ref
                              .read(tasksProvider.notifier)
                              .toggleCompleted(task.id),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissibleTask extends StatelessWidget {
  const _DismissibleTask({
    required this.taskId,
    required this.title,
    required this.onDismissed,
    required this.child,
  });

  final String taskId;
  final String title;
  final VoidCallback onDismissed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(taskId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.checkboxPending.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.checkboxPending),
      ),
      onDismissed: (_) {
        onDismissed();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('«$title» eliminada'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      },
      child: child,
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
