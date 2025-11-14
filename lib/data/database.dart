import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xtimer/model/task_model.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'xtimeros.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE Task (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            color INTEGER,
            title TEXT,
            hours INTEGER,
            minutes INTEGER,
            seconds INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insert(Task task) async {
    final db = await database;

    final data = task.toMap();
    data.remove('id');  // id 자동 증가

    return await db.insert(
      'Task',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getAll() async {
    final db = await database;
    final query = await db.query('Task');

    return query.isNotEmpty
        ? query.map((t) => Task.fromMap(t)).toList()
        : [];
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete(
      'Task',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
