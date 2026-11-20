import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../models/habit.dart';
import '../widgets/habit_card.dart';
import '../widgets/today_progress_header.dart';
import '../widgets/empty_state.dart';
import 'add_habit_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Поиск привычек...',
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: habitProvider.setSearch,
              )
            : const Text('Трекер привычек', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  habitProvider.setSearch('');
                }
              });
            },
          ),
          IconButton(
            icon: Icon(themeProvider.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatisticsScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Сегодня', icon: Icon(Icons.today)),
            Tab(text: 'Все', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: Column(
        children: [
          TodayProgressHeader(
            completed: habitProvider.completedTodayCount,
            total: habitProvider.todayHabits.length,
            progress: habitProvider.todayProgress,
          ),
          _CategoryFilter(
            selected: habitProvider.filterCategory,
            onSelected: habitProvider.setFilter,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _HabitList(habits: habitProvider.todayHabits),
                _HabitList(habits: habitProvider.habits),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddHabitScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}

class _HabitList extends StatelessWidget {
  final List<Habit> habits;
  const _HabitList({required this.habits});

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) return const EmptyStateWidget();
    return RefreshIndicator(
      onRefresh: () => context.read<HabitProvider>().loadHabits(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: habits.length,
        itemBuilder: (_, i) => HabitCard(habit: habits[i]),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final HabitCategory? selected;
  final ValueChanged<HabitCategory?> onSelected;

  const _CategoryFilter({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          FilterChip(
            label: const Text('Все'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...HabitCategory.values.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: Icon(cat.icon, size: 16),
                  label: Text(cat.label),
                  selected: selected == cat,
                  onSelected: (_) => onSelected(selected == cat ? null : cat),
                ),
              )),
        ],
      ),
    );
  }
}
