import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tasks_provider.dart';
import '../theme/app_theme.dart';

class FilterChipsRow extends ConsumerWidget {
  const FilterChipsRow({super.key});

  static const _filters = [
    (TaskListFilter.todas, 'Todas'),
    (TaskListFilter.trabajo, 'Trabajo'),
    (TaskListFilter.personal, 'Personal'),
    (TaskListFilter.urgente, 'Urgente'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(homeListFilterProvider);

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label) = _filters[index];
          final isSelected = selected == filter;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ref.read(homeListFilterProvider.notifier).state = filter;
              },
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.22)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                    width: isSelected ? 1.2 : 0.8,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.accentLight
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
