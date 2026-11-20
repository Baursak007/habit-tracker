import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final habits = provider.allHabits;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Экспорт CSV',
            onPressed: () {
              final csv = provider.exportToCsv();
              Share.share(csv, subject: 'Мои привычки');
            },
          ),
        ],
      ),
      body: habits.isEmpty
          ? const Center(child: Text('Нет данных для статистики'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryCards(habits: habits),
                const SizedBox(height: 20),
                _WeeklyProgressChart(habits: habits),
                const SizedBox(height: 20),
                _CategoryPieChart(habits: habits),
                const SizedBox(height: 20),
                _HabitRankingList(habits: habits),
              ],
            ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final List<Habit> habits;
  const _SummaryCards({required this.habits});

  @override
  Widget build(BuildContext context) {
    final totalCompletions = habits.fold(0, (sum, h) => sum + h.completedDates.length);
    final bestStreak = habits.fold(0, (m, h) => h.currentStreak > m ? h.currentStreak : m);
    final avgRate = habits.isEmpty ? 0.0 : habits.map((h) => h.completionRate).reduce((a, b) => a + b) / habits.length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(label: 'Привычек', value: '${habits.length}', icon: Icons.list_alt, color: const Color(0xFF6C63FF)),
        _StatCard(label: 'Выполнено раз', value: '$totalCompletions', icon: Icons.check_circle, color: const Color(0xFF43AA8B)),
        _StatCard(label: 'Лучшая серия', value: '$bestStreak дн.', icon: Icons.local_fire_department, color: const Color(0xFFF8961E)),
        _StatCard(label: 'Ср. выполнение', value: '${(avgRate * 100).toStringAsFixed(0)}%', icon: Icons.percent, color: const Color(0xFFFF6584)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _WeeklyProgressChart extends StatelessWidget {
  final List<Habit> habits;
  const _WeeklyProgressChart({required this.habits});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final bars = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final count = habits.where((h) => h.isCompletedOnDay(day)).length.toDouble();
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: count, color: Theme.of(context).colorScheme.primary, width: 20, borderRadius: BorderRadius.circular(6)),
      ]);
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Последние 7 дней', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(BarChartData(
                barGroups: bars,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Text(dayLabels[v.toInt()], style: const TextStyle(fontSize: 11)),
                  )),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<Habit> habits;
  const _CategoryPieChart({required this.habits});

  @override
  Widget build(BuildContext context) {
    final Map<HabitCategory, int> counts = {};
    for (final h in habits) {
      counts[h.category] = (counts[h.category] ?? 0) + 1;
    }

    final categoryColors = [
      const Color(0xFF6C63FF), const Color(0xFFFF6584), const Color(0xFF43AA8B),
      const Color(0xFFF8961E), const Color(0xFF577590), const Color(0xFF90BE6D),
      const Color(0xFFE63946),
    ];

    final sections = counts.entries.toList().asMap().entries.map((entry) {
      final idx = entry.key;
      final cat = entry.value.key;
      final count = entry.value.value;
      return PieChartSectionData(
        value: count.toDouble(),
        title: '${cat.label}\n$count',
        color: categoryColors[idx % categoryColors.length],
        radius: 80,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    if (sections.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('По категориям', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 30)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitRankingList extends StatelessWidget {
  final List<Habit> habits;
  const _HabitRankingList({required this.habits});

  @override
  Widget build(BuildContext context) {
    final sorted = List<Habit>.from(habits)
      ..sort((a, b) => b.completionRate.compareTo(a.completionRate));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Рейтинг привычек', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...sorted.take(10).toList().asMap().entries.map((entry) {
              final i = entry.key;
              final h = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: h.color,
                  child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(h.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Серия: ${h.currentStreak} дн. | Лучшая: ${h.longestStreak} дн.'),
                trailing: Text(
                  '${(h.completionRate * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: h.color, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
