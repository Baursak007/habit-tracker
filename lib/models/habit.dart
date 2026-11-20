import 'package:flutter/material.dart';

enum HabitFrequency { daily, weekly }

enum HabitCategory {
  health,
  sport,
  education,
  work,
  hobby,
  social,
  other;

  String get label {
    switch (this) {
      case HabitCategory.health:
        return 'Здоровье';
      case HabitCategory.sport:
        return 'Спорт';
      case HabitCategory.education:
        return 'Образование';
      case HabitCategory.work:
        return 'Работа';
      case HabitCategory.hobby:
        return 'Хобби';
      case HabitCategory.social:
        return 'Общение';
      case HabitCategory.other:
        return 'Другое';
    }
  }

  IconData get icon {
    switch (this) {
      case HabitCategory.health:
        return Icons.favorite;
      case HabitCategory.sport:
        return Icons.fitness_center;
      case HabitCategory.education:
        return Icons.school;
      case HabitCategory.work:
        return Icons.work;
      case HabitCategory.hobby:
        return Icons.palette;
      case HabitCategory.social:
        return Icons.people;
      case HabitCategory.other:
        return Icons.star;
    }
  }
}

class Habit {
  final String id;
  final String name;
  final String description;
  final HabitCategory category;
  final HabitFrequency frequency;
  final int targetDays;
  final Color color;
  final IconData icon;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final bool isActive;

  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.frequency,
    required this.targetDays,
    required this.color,
    required this.icon,
    required this.createdAt,
    this.completedDates = const [],
    this.isActive = true,
  });

  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any(
      (d) => d.year == today.year && d.month == today.month && d.day == today.day,
    );
  }

  bool isCompletedOnDay(DateTime day) {
    return completedDates.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    );
  }

  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    for (final date in sortedDates) {
      final diff = checkDate.difference(date).inDays;
      if (diff == 0 || diff == 1) {
        streak++;
        checkDate = date;
      } else {
        break;
      }
    }
    return streak;
  }

  int get longestStreak {
    if (completedDates.isEmpty) return 0;
    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => a.compareTo(b));
    
    int longest = 1;
    int current = 1;
    
    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }

  double get completionRate {
    if (completedDates.isEmpty) return 0;
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays + 1;
    return completedDates.length / daysSinceCreation;
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    HabitCategory? category,
    HabitFrequency? frequency,
    int? targetDays,
    Color? color,
    IconData? icon,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.index,
      'frequency': frequency.index,
      'targetDays': targetDays,
      'color': color.value,
      'icon': icon.codePoint,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map, List<DateTime> completedDates) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      category: HabitCategory.values[map['category'] as int],
      frequency: HabitFrequency.values[map['frequency'] as int],
      targetDays: map['targetDays'] as int? ?? 30,
      color: Color(map['color'] as int),
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedDates: completedDates,
      isActive: (map['isActive'] as int?) == 1,
    );
  }
}
