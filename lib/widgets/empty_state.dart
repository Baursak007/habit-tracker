import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement, size: 80, color: colorScheme.primary.withOpacity(0.4)),
            const SizedBox(height: 20),
            Text(
              'Нет привычек',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Нажми кнопку + внизу, чтобы добавить первую привычку и начать путь к лучшей жизни',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.arrow_downward, color: colorScheme.primary.withOpacity(0.5), size: 32),
          ],
        ),
      ),
    );
  }
}
