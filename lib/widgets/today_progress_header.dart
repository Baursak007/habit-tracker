import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class TodayProgressHeader extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;

  const TodayProgressHeader({
    super.key,
    required this.completed,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final greeting = _greeting();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary.withOpacity(0.1), colorScheme.secondary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 4),
          total == 0
              ? Text('Добавь свою первую привычку! 🚀', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
              : Text(
                  completed == total ? 'Все выполнено! 🎉' : '$completed из $total выполнено',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
          if (total > 0) ...[
            const SizedBox(height: 10),
            LinearPercentIndicator(
              lineHeight: 10,
              percent: progress.clamp(0, 1),
              backgroundColor: colorScheme.surfaceVariant,
              progressColor: progress == 1.0 ? Colors.green : colorScheme.primary,
              barRadius: const Radius.circular(8),
              padding: EdgeInsets.zero,
              animation: true,
              animationDuration: 600,
            ),
          ],
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Доброе утро!';
    if (hour < 17) return 'Добрый день!';
    if (hour < 21) return 'Добрый вечер!';
    return 'Доброй ночи!';
  }
}
