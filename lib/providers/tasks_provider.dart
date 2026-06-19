import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

const _uuid = Uuid();

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
  TasksNotifier() : super([]) {
    _init();
  }

  static const _storageKey = 'tasks_list_v2';

  Future<void> _init() async {
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString(_storageKey);

      if (tasksJson != null) {
        final List<dynamic> decoded = jsonDecode(tasksJson);
        state = decoded.map((item) => Task.fromJson(item)).toList();
      } else {
        // Primera vez, cargar iniciales y guardar
        state = _initialTasks();
        await _saveTasks();
      }
    } catch (e) {
      // En caso de error, cargar iniciales para no dejar la app vacía
      state = _initialTasks();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(state.map((task) => task.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void addTask(Task task) {
    state = [...state, task];
    _saveTasks();
  }

  void updateTask(Task task) {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t,
    ];
    _saveTasks();
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
    _saveTasks();
  }

  void toggleCompleted(String id) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(isCompleted: !t.isCompleted) else t,
    ];
    _saveTasks();
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
