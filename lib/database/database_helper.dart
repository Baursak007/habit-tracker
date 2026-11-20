import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habit_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        category INTEGER NOT NULL DEFAULT 6,
        frequency INTEGER NOT NULL DEFAULT 0,
        targetDays INTEGER NOT NULL DEFAULT 30,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE completions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (habitId) REFERENCES habits(id) ON DELETE CASCADE
      )
    ''');
  }

  // HABITS CRUD
  Future<void> insertHabit(Habit habit) async {
    final db = await database;
    await db.insert('habits', habit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await database;
    await db.update('habits', habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
  }

  Future<void> deleteHabit(String id) async {
    final db = await database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
    await db.delete('completions', where: 'habitId = ?', whereArgs: [id]);
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final habitMaps = await db.query('habits', where: 'isActive = 1', orderBy: 'createdAt DESC');
    final List<Habit> habits = [];
    for (final map in habitMaps) {
      final completedDates = await getCompletions(map['id'] as String);
      habits.add(Habit.fromMap(map, completedDates));
    }
    return habits;
  }

  // COMPLETIONS
  Future<void> addCompletion(String habitId, DateTime date) async {
    final db = await database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final existing = await db.query(
      'completions',
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, dateStr],
    );
    if (existing.isEmpty) {
      await db.insert('completions', {'habitId': habitId, 'date': dateStr});
    }
  }

  Future<void> removeCompletion(String habitId, DateTime date) async {
    final db = await database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    await db.delete(
      'completions',
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, dateStr],
    );
  }

  Future<List<DateTime>> getCompletions(String habitId) async {
    final db = await database;
    final rows = await db.query('completions', where: 'habitId = ?', whereArgs: [habitId]);
    return rows.map((r) => DateTime.parse(r['date'] as String)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
