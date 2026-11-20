import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../screens/add_habit_screen.dart';

class HabitDetailBottomSheet extends StatelessWidget {
  final Habit habit;
  const HabitDetailBottomSheet({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HabitProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: scrollController,
          children: [
            // Handle
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            // Header
            Row(children: [
              CircleAvatar(backgroundColor: habit.color, radius: 28, child: Icon(habit.icon, color: Colors.white, size: 28)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text(habit.category.label, style: TextStyle(color: colorScheme.secondary)),
                if (habit.description.isNotEmpty) Text(habit.description, style: Theme.of(context).textTheme.bodySmall),
              ])),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddHabitScreen(habit: habit)));
                },
              ),
            ]),
            const SizedBox(height: 24),
            // Progress
            Center(child: CircularPercentIndicator(
              radius: 70,
              lineWidth: 10,
              percent: habit.completionRate.clamp(0, 1),
              center: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${(habit.completionRate * 100).toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: habit.color)),
                const Text('выполнено', style: TextStyle(fontSize: 11)),
              ]),
              progressColor: habit.color,
              backgroundColor: habit.color.withOpacity(0.1),
              circularStrokeCap: CircularStrokeCap.round,
            )),
            const SizedBox(height: 24),
            // Stats row
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _StatItem(label: 'Текущая серия', value: '${habit.currentStreak}', icon: Icons.local_fire_department, color: Colors.orange),
              _StatItem(label: 'Лучшая серия', value: '${habit.longestStreak}', icon: Icons.emoji_events, color: Colors.amber),
              _StatItem(label: 'Всего раз', value: '${habit.completedDates.length}', icon: Icons.check_circle, color: habit.color),
            ]),
            const SizedBox(height: 24),
            // Calendar last 4 weeks
            Text('Последние 4 недели', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _MiniCalendar(habit: habit),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: color, size: 28),
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
    ]);
  }
}

class _MiniCalendar extends StatelessWidget {
  final Habit habit;
  const _MiniCalendar({required this.habit});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(28, (i) => now.subtract(Duration(days: 27 - i)));
    final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Column(children: [
      Row(children: dayNames.map((d) => Expanded(
        child: Center(child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
      )).toList()),
      const SizedBox(height: 4),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: days.map((day) {
          final done = habit.isCompletedOnDay(day);
          final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
          return Container(
            decoration: BoxDecoration(
              color: done ? habit.color : habit.color.withOpacity(0.07),
              shape: BoxShape.circle,
              border: isToday ? Border.all(color: habit.color, width: 2) : null,
            ),
            child: Center(child: Text(
              '${day.day}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: done ? Colors.white : null),
            )),
          );
        }).toList(),
      ),
    ]);
  }
}
