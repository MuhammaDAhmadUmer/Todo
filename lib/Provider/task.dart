import 'package:flutter/material.dart';
import 'package:api_practice/models/task.dart';
import 'package:api_practice/services/task.dart';

enum TaskFilter { all, active, completed }

class TaskProvider extends ChangeNotifier {
  final TaskServices _taskServices = TaskServices();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  TaskFilter _filter = TaskFilter.all;

  // Search
  List<Task> _searchResults = [];
  bool _isSearching = false;
  bool _searchLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TaskFilter get filter => _filter;

  List<Task> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get searchLoading => _searchLoading;

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.complete == true).length;
  int get activeCount => _tasks.where((t) => t.complete != true).length;

  List<Task> get filteredTasks {
    switch (_filter) {
      case TaskFilter.active:
        return _tasks.where((t) => t.complete != true).toList();
      case TaskFilter.completed:
        return _tasks.where((t) => t.complete == true).toList();
      case TaskFilter.all:
        return _tasks;
    }
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearError() {
    _error = null;
  }

  Future<void> loadTasks(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _taskServices.getAllTasks(token);
      _tasks = result.tasks ?? [];
      // Newest first.
      _tasks.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(String token, String description) async {
    try {
      final result = await _taskServices.createTask(
        token: token,
        description: description,
      );
      if (result.task != null) {
        _tasks.insert(0, result.task!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleComplete(String token, Task task) async {
    if (task.id == null) return false;
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return false;

    final old = _tasks[index];
    final newValue = !(old.complete ?? false);

    // Optimistic update so the UI feels instant.
    _tasks[index] = _copyWith(old, complete: newValue);
    notifyListeners();

    try {
      final success = await _taskServices.toggleComplete(
        token: token,
        id: task.id!,
        complete: newValue,
      );
      if (!success) {
        _tasks[index] = old;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _tasks[index] = old;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(String token, String id, String description) async {
    try {
      final success = await _taskServices.updateTask(
        token: token,
        id: id,
        description: description,
      );
      if (success) {
        final index = _tasks.indexWhere((t) => t.id == id);
        if (index != -1) {
          _tasks[index] = _copyWith(
            _tasks[index],
            description: description,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> search(String token, String keyword) async {
    if (keyword.trim().isEmpty) {
      clearSearch();
      return;
    }
    _isSearching = true;
    _searchLoading = true;
    notifyListeners();
    try {
      final result = await _taskServices.searchTasks(
        token: token,
        keyword: keyword.trim(),
      );
      _searchResults = result.tasks ?? [];
    } catch (e) {
      _error = e.toString();
      _searchResults = [];
    } finally {
      _searchLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _isSearching = false;
    _searchResults = [];
    notifyListeners();
  }

  Future<bool> deleteTask(String token, String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return false;
    final removed = _tasks[index];

    // Optimistic removal.
    _tasks.removeAt(index);
    notifyListeners();

    try {
      final success = await _taskServices.deleteTask(token: token, id: id);
      if (!success) {
        _tasks.insert(index, removed);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _tasks.insert(index, removed);
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Task _copyWith(
    Task task, {
    String? description,
    bool? complete,
    DateTime? updatedAt,
  }) {
    return Task(
      id: task.id,
      description: description ?? task.description,
      complete: complete ?? task.complete,
      owner: task.owner,
      createdAt: task.createdAt,
      updatedAt: updatedAt ?? task.updatedAt,
      v: task.v,
    );
  }
}
