import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../screens/add_habit_screen.dart';
import 'habit_detail_bottom_sheet.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HabitProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = habit.isCompletedToday();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(habit.id),
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddHabitScreen(habit: habit)),
              ),
              backgroundColor: colorScheme.secondary,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Изменить',
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              autoClose: true,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _confirmDelete(context, provider),
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Удалить',
              borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _showDetail(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isCompleted ? habit.color.withOpacity(0.15) : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted ? habit.color : colorScheme.outline.withOpacity(0.3),
                width: isCompleted ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _HabitIcon(habit: habit, isCompleted: isCompleted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? colorScheme.onSurface.withOpacity(0.6) : null,
                        ),
                      ),
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(habit.description, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _StreakBadge(streak: habit.currentStreak, color: habit.color),
                          const SizedBox(width: 8),
                          _CategoryBadge(category: habit.category),
                        ],
                      ),
                    ],
                  ),
                ),
                _CheckButton(habit: habit, isCompleted: isCompleted, onTap: () => provider.toggleHabitCompletion(habit.id)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => HabitDetailBottomSheet(habit: habit),
    );
  }

  void _confirmDelete(BuildContext context, HabitProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить привычку?'),
        content: Text('«${habit.name}» будет удалена безвозвратно'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              provider.deleteHabit(habit.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

class _HabitIcon extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  const _HabitIcon({required this.habit, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: isCompleted ? habit.color : habit.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(habit.icon, color: isCompleted ? Colors.white : habit.color, size: 26),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  final Color color;
  const _StreakBadge({required this.streak, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.local_fire_department, size: 12, color: color),
        const SizedBox(width: 2),
        Text('$streak дн.', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final HabitCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(category.icon, size: 11, color: Theme.of(context).colorScheme.onSecondaryContainer),
        const SizedBox(width: 2),
        Text(category.label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSecondaryContainer)),
      ]),
    );
  }
}

class _CheckButton extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onTap;
  const _CheckButton({required this.habit, required this.isCompleted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isCompleted ? habit.color : Colors.transparent,
          border: Border.all(color: isCompleted ? habit.color : Theme.of(context).colorScheme.outline, width: 2),
          shape: BoxShape.circle,
        ),
        child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 22) : null,
      ),
    );
  }
}
