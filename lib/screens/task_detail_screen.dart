import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_priority.dart';
import '../providers/scan_draft_provider.dart';
import '../providers/tasks_provider.dart';
import '../theme/app_theme.dart';

class _Subtask {
  _Subtask({required this.title, this.done = false});
  String title;
  bool done;
}

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, this.taskId});

  final String? taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subtaskController = TextEditingController();

  TaskPriority _priority = TaskPriority.media;
  TaskCategory _category = TaskCategory.trabajo;
  DateTime _dueDate = DateTime.now().add(const Duration(hours: 2));
  final List<_Subtask> _subtasks = [
    _Subtask(title: 'Recopilar datos'),
  ];

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTask());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyPendingScanDraft());
    }
  }

  Future<void> _applyPendingScanDraft() async {
    final draft = ref.read(pendingScanDraftProvider) ??
        await ref.read(scanDraftStorageProvider).read();

    if (draft == null || !draft.isValid) return;

    setState(() {
      _titleController.text = draft.title;
      _descriptionController.text = draft.description;
    });

    ref.read(pendingScanDraftProvider.notifier).state = null;
    await ref.read(scanDraftStorageProvider).clear();
  }

  void _loadTask() {
    final task = ref.read(tasksProvider.notifier).getById(widget.taskId!);
    if (task == null) return;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _priority = task.priority;
    _category = task.category;
    _dueDate = task.dueDate;
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _dueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dueDate.hour,
          _dueDate.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (picked != null) {
      setState(() {
        _dueDate = DateTime(
          _dueDate.year,
          _dueDate.month,
          _dueDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    final notifier = ref.read(tasksProvider.notifier);
    final description = _descriptionController.text.trim();

    if (_isEditing) {
      final existing = notifier.getById(widget.taskId!);
      if (existing != null) {
        notifier.updateTask(
          existing.copyWith(
            title: title,
            description: description,
            category: _category,
            priority: _priority,
            dueDate: _dueDate,
          ),
        );
      }
    } else {
      notifier.addTask(
        Task(
          id: const Uuid().v4(),
          title: title,
          description: description,
          category: _category,
          priority: _priority,
          dueDate: _dueDate,
        ),
      );
    }

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d MMMM', 'es');
    final timeFmt = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(_isEditing ? 'Editar tarea' : 'Nueva tarea'),
        actions: [
          if (!_isEditing)
            IconButton(
              tooltip: 'Escanear tarea',
              icon: const Icon(Icons.document_scanner_outlined),
              onPressed: () async {
                final imported = await context.push<bool>('/scan');
                if (imported == true && mounted) {
                  await _applyPendingScanDraft();
                }
              },
            ),
          TextButton(
            onPressed: _save,
            child: const Text(
              'Guardar',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.accentLight,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: '¿Qué necesitas hacer?',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Añade más detalles...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Fecha y Hora',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateTimeButton(
                  icon: Icons.calendar_today_outlined,
                  label: dateFmt.format(_dueDate),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateTimeButton(
                  icon: Icons.access_time_rounded,
                  label: timeFmt.format(_dueDate),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'PRIORIDAD',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: TaskPriority.values.map((p) {
              final selected = _priority == p;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: p != TaskPriority.baja ? 8 : 0,
                  ),
                  child: _PriorityChip(
                    label: p.label,
                    priority: p,
                    selected: selected,
                    onTap: () => setState(() => _priority = p),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'CATEGORÍA',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TaskCategory>(
            value: _category,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: TaskCategory.values
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.categoryColor(c),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(c.label),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _category = v);
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SUBTAREAS',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              TextButton.icon(
                onPressed: () {
                  final text = _subtaskController.text.trim();
                  if (text.isEmpty) {
                    setState(() => _subtasks.add(_Subtask(title: 'Nueva subtarea')));
                  } else {
                    setState(() {
                      _subtasks.add(_Subtask(title: text));
                      _subtaskController.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Añadir'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._subtasks.asMap().entries.map((entry) {
            final index = entry.key;
            final sub = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: sub.done,
                      onChanged: (v) {
                        setState(() => sub.done = v ?? false);
                      },
                      activeColor: AppColors.accent,
                    ),
                    Expanded(
                      child: Text(
                        sub.title,
                        style: TextStyle(
                          decoration: sub.done ? TextDecoration.lineThrough : null,
                          color: sub.done
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() => _subtasks.removeAt(index));
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          TextField(
            controller: _subtaskController,
            decoration: InputDecoration(
              hintText: 'Escribe una subtarea y pulsa Añadir',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  final text = _subtaskController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _subtasks.add(_Subtask(title: text));
                      _subtaskController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las subtareas son solo visuales en v1.0 y no se guardan.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  const _DateTimeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.accentLight),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.label,
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final TaskPriority priority;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.priorityColor(priority);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.priorityBackground(priority)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? fg.withValues(alpha: 0.5) : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? fg : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
