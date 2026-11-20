import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../database/database_helper.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;
  String _searchQuery = '';
  HabitCategory? _filterCategory;

  List<Habit> get habits => _filtered;
  List<Habit> get allHabits => _habits;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  HabitCategory? get filterCategory => _filterCategory;

  List<Habit> get _filtered {
    var result = List<Habit>.from(_habits);
    if (_searchQuery.isNotEmpty) {
      result = result.where((h) => h.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_filterCategory != null) {
      result = result.where((h) => h.category == _filterCategory).toList();
    }
    return result;
  }

  List<Habit> get todayHabits {
    final today = DateTime.now().weekday; // 1 = Monday
    return _habits.where((h) {
      if (h.frequency == HabitFrequency.daily) return true;
      if (h.frequency == HabitFrequency.weekly) return today == 1; // Mondays
      return true;
    }).toList();
  }

  int get completedTodayCount {
    return todayHabits.where((h) => h.isCompletedToday()).length;
  }

  double get todayProgress {
    if (todayHabits.isEmpty) return 0;
    return completedTodayCount / todayHabits.length;
  }

  HabitProvider() {
    loadHabits();
  }

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();
    try {
      _habits = await DatabaseHelper.instance.getAllHabits();
    } catch (e) {
      debugPrint('Error loading habits: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHabit({
    required String name,
    required String description,
    required HabitCategory category,
    required HabitFrequency frequency,
    required int targetDays,
    required Color color,
    required IconData icon,
  }) async {
    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      description: description,
      category: category,
      frequency: frequency,
      targetDays: targetDays,
      color: color,
      icon: icon,
      createdAt: DateTime.now(),
    );
    await DatabaseHelper.instance.insertHabit(habit);
    _habits.insert(0, habit);
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await DatabaseHelper.instance.updateHabit(habit);
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx != -1) {
      _habits[idx] = habit;
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    await DatabaseHelper.instance.deleteHabit(id);
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  Future<void> toggleHabitCompletion(String habitId) async {
    final idx = _habits.indexWhere((h) => h.id == habitId);
    if (idx == -1) return;
    final habit = _habits[idx];
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    List<DateTime> updated;
    if (habit.isCompletedToday()) {
      await DatabaseHelper.instance.removeCompletion(habitId, todayNorm);
      updated = habit.completedDates.where((d) {
        return !(d.year == todayNorm.year && d.month == todayNorm.month && d.day == todayNorm.day);
      }).toList();
    } else {
      await DatabaseHelper.instance.addCompletion(habitId, todayNorm);
      updated = [...habit.completedDates, todayNorm];
    }

    _habits[idx] = habit.copyWith(completedDates: updated);
    notifyListeners();
  }

  Future<void> markDateCompletion(String habitId, DateTime date, bool completed) async {
    final idx = _habits.indexWhere((h) => h.id == habitId);
    if (idx == -1) return;
    final habit = _habits[idx];
    final dateNorm = DateTime(date.year, date.month, date.day);
    List<DateTime> updated;
    if (completed) {
      await DatabaseHelper.instance.addCompletion(habitId, dateNorm);
      updated = [...habit.completedDates, dateNorm];
    } else {
      await DatabaseHelper.instance.removeCompletion(habitId, dateNorm);
      updated = habit.completedDates.where((d) {
        return !(d.year == dateNorm.year && d.month == dateNorm.month && d.day == dateNorm.day);
      }).toList();
    }
    _habits[idx] = habit.copyWith(completedDates: updated);
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(HabitCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  // Export habits to CSV string
  String exportToCsv() {
    final buf = StringBuffer();
    buf.writeln('Привычка,Категория,Частота,Цель,Серия,Выполнено раз,Процент');
    for (final h in _habits) {
      buf.writeln(
        '"${h.name}","${h.category.label}","${h.frequency == HabitFrequency.daily ? "Ежедневно" : "Еженедельно"}",${h.targetDays},${h.currentStreak},${h.completedDates.length},"${(h.completionRate * 100).toStringAsFixed(1)}%"',
      );
    }
    return buf.toString();
  }
}
