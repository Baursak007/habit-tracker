import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? habit; // null = add, non-null = edit
  const AddHabitScreen({super.key, this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  HabitCategory _category = HabitCategory.other;
  HabitFrequency _frequency = HabitFrequency.daily;
  int _targetDays = 30;
  Color _color = const Color(0xFF6C63FF);
  IconData _icon = Icons.star;

  static const _colors = [
    Color(0xFF6C63FF), Color(0xFFFF6584), Color(0xFF43AA8B),
    Color(0xFFF8961E), Color(0xFF577590), Color(0xFF90BE6D),
    Color(0xFFE63946), Color(0xFF457B9D), Color(0xFFE9C46A),
  ];

  static const _icons = [
    Icons.star, Icons.favorite, Icons.fitness_center, Icons.school,
    Icons.work, Icons.palette, Icons.people, Icons.local_drink,
    Icons.book, Icons.music_note, Icons.directions_run, Icons.spa,
    Icons.self_improvement, Icons.emoji_events, Icons.language,
    Icons.code, Icons.attach_money, Icons.bed, Icons.restaurant,
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _descCtrl = TextEditingController(text: h?.description ?? '');
    if (h != null) {
      _category = h.category;
      _frequency = h.frequency;
      _targetDays = h.targetDays;
      _color = h.color;
      _icon = h.icon;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<HabitProvider>();
    if (widget.habit == null) {
      await provider.addHabit(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        frequency: _frequency,
        targetDays: _targetDays,
        color: _color,
        icon: _icon,
      );
    } else {
      await provider.updateHabit(widget.habit!.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        frequency: _frequency,
        targetDays: _targetDays,
        color: _color,
        icon: _icon,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEdit = widget.habit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать' : 'Новая привычка'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(isEdit ? 'Сохранить' : 'Добавить',
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview card
            Card(
              color: _color.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: _color, child: Icon(_icon, color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_nameCtrl.text.isEmpty ? 'Название привычки' : _nameCtrl.text,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(_category.label, style: TextStyle(color: colorScheme.secondary)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Название *', prefixIcon: Icon(Icons.edit)),
              onChanged: (_) => setState(() {}),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите название' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Описание (необязательно)', prefixIcon: Icon(Icons.notes)),
            ),
            const SizedBox(height: 20),
            Text('Категория', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HabitCategory.values.map((cat) => ChoiceChip(
                avatar: Icon(cat.icon, size: 16),
                label: Text(cat.label),
                selected: _category == cat,
                onSelected: (_) => setState(() => _category = cat),
              )).toList(),
            ),
            const SizedBox(height: 20),
            Text('Частота', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<HabitFrequency>(
              segments: const [
                ButtonSegment(value: HabitFrequency.daily, label: Text('Ежедневно'), icon: Icon(Icons.today)),
                ButtonSegment(value: HabitFrequency.weekly, label: Text('Еженедельно'), icon: Icon(Icons.view_week)),
              ],
              selected: {_frequency},
              onSelectionChanged: (s) => setState(() => _frequency = s.first),
            ),
            const SizedBox(height: 20),
            Text('Цель: $_targetDays дней', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Slider(
              value: _targetDays.toDouble(),
              min: 7, max: 365, divisions: 51,
              label: '$_targetDays дней',
              onChanged: (v) => setState(() => _targetDays = v.round()),
            ),
            const SizedBox(height: 20),
            Text('Цвет', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _colors.map((c) => GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: _color == c ? Border.all(color: colorScheme.onSurface, width: 3) : null,
                  ),
                  child: _color == c ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            Text('Иконка', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _icons.map((ic) => GestureDetector(
                onTap: () => setState(() => _icon = ic),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _icon == ic ? _color : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(ic, color: _icon == ic ? Colors.white : colorScheme.onSurfaceVariant),
                ),
              )).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
