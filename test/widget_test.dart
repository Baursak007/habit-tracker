import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/providers/theme_provider.dart';
import 'package:habit_tracker/theme/app_theme.dart';
import 'package:habit_tracker/widgets/today_progress_header.dart';
import 'package:habit_tracker/widgets/empty_state.dart';

void main() {
  group('TodayProgressHeader widget tests', () {
    testWidgets('Shows greeting text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: TodayProgressHeader(completed: 0, total: 0, progress: 0)),
      ));
      expect(find.textContaining(RegExp(r'утро|день|вечер|ночь', caseSensitive: false)), findsOneWidget);
    });

    testWidgets('Shows all completed message when complete', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: TodayProgressHeader(completed: 3, total: 3, progress: 1.0)),
      ));
      expect(find.textContaining('Все выполнено'), findsOneWidget);
    });

    testWidgets('Shows count when partially complete', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: TodayProgressHeader(completed: 2, total: 5, progress: 0.4)),
      ));
      expect(find.textContaining('2 из 5'), findsOneWidget);
    });

    testWidgets('Shows add prompt when no habits', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: TodayProgressHeader(completed: 0, total: 0, progress: 0)),
      ));
      expect(find.textContaining('первую привычку'), findsOneWidget);
    });
  });

  group('EmptyStateWidget tests', () {
    testWidgets('Shows empty state text', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: EmptyStateWidget()),
      ));
      expect(find.textContaining('Нет привычек'), findsOneWidget);
    });

    testWidgets('Shows icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: EmptyStateWidget()),
      ));
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
    });
  });

  group('ThemeProvider tests', () {
    test('Default theme mode is system', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, equals(ThemeMode.system));
    });

    test('isDark returns false for system/light', () {
      final provider = ThemeProvider();
      expect(provider.isDark, isFalse);
    });
  });

  group('AppTheme tests', () {
    test('Light theme is not null', () {
      expect(AppTheme.lightTheme, isNotNull);
      expect(AppTheme.lightTheme.brightness, equals(Brightness.light));
    });

    test('Dark theme is not null', () {
      expect(AppTheme.darkTheme, isNotNull);
      expect(AppTheme.darkTheme.brightness, equals(Brightness.dark));
    });
  });
}
