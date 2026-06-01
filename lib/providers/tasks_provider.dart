import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_priority.dart';

enum TaskListFilter {
  todas,
  trabajo,
  personal,
  urgente,
}

enum TaskCompletionFilter { all, pending, completed }

final _uuid = Uuid();

/// Datos alineados con el mockup (3 pendientes hoy, 1 completada).
List<Task> _initialTasks() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 14);

  return [
    Task(
      id: _uuid.v4(),
      title: 'Entregar informe QA',
      description: 'Informe de pruebas del sprint actual.',
      category: TaskCategory.trabajo,
      priority: TaskPriority.alta,
      dueDate: today,
    ),
    Task(
      id: _uuid.v4(),
      title: 'ir a la cita medica',
      description: 'Clínica central, piso 3.',
      category: TaskCategory.personal,
      priority: TaskPriority.media,
      dueDate: today.add(const Duration(hours: 3)),
    ),
    Task(
      id: _uuid.v4(),
      title: 'Preparar presentación',
      description: 'Slides para la reunión del viernes.',
      category: TaskCategory.trabajo,
      priority: TaskPriority.media,
      dueDate: today.add(const Duration(hours: 5)),
    ),
    Task(
      id: _uuid.v4(),
      title: 'Llamar al médico',
      description: 'Confirmar cita de seguimiento.',
      category: TaskCategory.personal,
      priority: TaskPriority.baja,
      dueDate: today,
      isCompleted: true,
    ),
  ];
}

class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super(_initialTasks());

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task task) {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t,
    ];
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void toggleCompleted(String id) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(isCompleted: !t.isCompleted) else t,
    ];
  }

  Task? getById(String id) {
    try {
      return state.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Task> filtered({
    TaskListFilter? listFilter,
    TaskCompletionFilter? completionFilter,
    TaskCategory? category,
    bool? isCompleted,
  }) {
    var result = List<Task>.from(state);

    final filter = listFilter ?? TaskListFilter.todas;
    switch (filter) {
      case TaskListFilter.todas:
        break;
      case TaskListFilter.trabajo:
        result = result.where((t) => t.category == TaskCategory.trabajo).toList();
      case TaskListFilter.personal:
        result = result.where((t) => t.category == TaskCategory.personal).toList();
      case TaskListFilter.urgente:
        result = result.where((t) => t.category == TaskCategory.urgente).toList();
    }

    if (category != null) {
      result = result.where((t) => t.category == category).toList();
    }

    final completion = completionFilter ?? TaskCompletionFilter.all;
    switch (completion) {
      case TaskCompletionFilter.all:
        break;
      case TaskCompletionFilter.pending:
        result = result.where((t) => !t.isCompleted).toList();
      case TaskCompletionFilter.completed:
        result = result.where((t) => t.isCompleted).toList();
    }

    if (isCompleted != null) {
      result = result.where((t) => t.isCompleted == isCompleted).toList();
    }

    result.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return result;
  }

  int get completedCount => state.where((t) => t.isCompleted).length;
  int get pendingCount => state.where((t) => !t.isCompleted).length;
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

final homeListFilterProvider =
    StateProvider<TaskListFilter>((ref) => TaskListFilter.todas);
