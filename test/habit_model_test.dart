import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/habit.dart';

void main() {
  group('Habit model tests', () {
    late Habit habit;

    setUp(() {
      habit = Habit(
        id: 'test-id',
        name: 'Утренняя зарядка',
        description: 'Делать зарядку каждое утро',
        category: HabitCategory.sport,
        frequency: HabitFrequency.daily,
        targetDays: 30,
        color: Colors.blue,
        icon: Icons.fitness_center,
        createdAt: DateTime(2024, 1, 1),
        completedDates: [],
      );
    });

    test('Habit created with correct initial state', () {
      expect(habit.name, equals('Утренняя зарядка'));
      expect(habit.category, equals(HabitCategory.sport));
      expect(habit.frequency, equals(HabitFrequency.daily));
      expect(habit.isActive, isTrue);
      expect(habit.completedDates, isEmpty);
    });

    test('isCompletedToday returns false when no completions', () {
      expect(habit.isCompletedToday(), isFalse);
    });

    test('isCompletedToday returns true when completed today', () {
      final today = DateTime.now();
      final completedHabit = habit.copyWith(
        completedDates: [DateTime(today.year, today.month, today.day)],
      );
      expect(completedHabit.isCompletedToday(), isTrue);
    });

    test('currentStreak is 0 for empty completions', () {
      expect(habit.currentStreak, equals(0));
    });

    test('currentStreak counts consecutive days correctly', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final habitWithStreak = habit.copyWith(completedDates: [
        DateTime(yesterday.year, yesterday.month, yesterday.day),
        DateTime(today.year, today.month, today.day),
      ]);
      expect(habitWithStreak.currentStreak, equals(2));
    });

    test('longestStreak calculated correctly', () {
      final base = DateTime(2024, 6, 1);
      final completedHabit = habit.copyWith(completedDates: [
        base,
        base.add(const Duration(days: 1)),
        base.add(const Duration(days: 2)),
        base.add(const Duration(days: 10)), // break
        base.add(const Duration(days: 11)),
      ]);
      expect(completedHabit.longestStreak, equals(3));
    });

    test('completionRate calculated correctly', () {
      final createdAt = DateTime.now().subtract(const Duration(days: 9));
      final completedHabit = habit.copyWith(
        createdAt: createdAt,
        completedDates: List.generate(5, (i) => DateTime.now().subtract(Duration(days: i))),
      );
      expect(completedHabit.completionRate, closeTo(0.5, 0.1));
    });

    test('copyWith preserves unchanged fields', () {
      final copied = habit.copyWith(name: 'Новое название');
      expect(copied.name, equals('Новое название'));
      expect(copied.id, equals(habit.id));
      expect(copied.category, equals(habit.category));
      expect(copied.isActive, equals(habit.isActive));
    });

    test('toMap and fromMap roundtrip', () {
      final map = habit.toMap();
      final restored = Habit.fromMap(map, habit.completedDates);
      expect(restored.id, equals(habit.id));
      expect(restored.name, equals(habit.name));
      expect(restored.category, equals(habit.category));
      expect(restored.frequency, equals(habit.frequency));
      expect(restored.targetDays, equals(habit.targetDays));
    });

    test('HabitCategory labels are non-empty', () {
      for (final cat in HabitCategory.values) {
        expect(cat.label, isNotEmpty);
        expect(cat.icon, isNotNull);
      }
    });

    test('isCompletedOnDay checks specific day', () {
      final date = DateTime(2024, 6, 15);
      final completedHabit = habit.copyWith(completedDates: [date]);
      expect(completedHabit.isCompletedOnDay(date), isTrue);
      expect(completedHabit.isCompletedOnDay(date.add(const Duration(days: 1))), isFalse);
    });
  });
}
