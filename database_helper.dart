import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('task_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Mở database và tạo các bảng nếu chưa có
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tạo bảng users
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT NOT NULL,
        avatar TEXT,
        createdAt TEXT NOT NULL,
        lastActive TEXT NOT NULL
      )
    ''');

    // Tạo bảng tasks
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        priority INTEGER NOT NULL,
        dueDate TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        assignedTo TEXT,
        createdBy TEXT NOT NULL,
        category TEXT,
        attachments TEXT,
        completed INTEGER NOT NULL
      )
    ''');
  }

  /// --- Các phương thức CRUD cho User ---
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUser(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  /// --- Các phương thức CRUD cho Task ---
  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<TaskModel?> getTask(String id) async {
    final db = await database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return TaskModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final result = await db.query('tasks');
    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// --- Hàm tìm kiếm và lọc dữ liệu theo điều kiện ---
  Future<List<TaskModel>> searchTasks({String? keyword, String? status, String? category}) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (keyword != null && keyword.isNotEmpty) {
      whereClauses.add('(title LIKE ? OR description LIKE ?)');
      whereArgs.add('%$keyword%');
      whereArgs.add('%$keyword%');
    }

    if (status != null && status.isNotEmpty) {
      whereClauses.add('status = ?');
      whereArgs.add(status);
    }

    if (category != null && category.isNotEmpty) {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;
    final result = await db.query('tasks', where: whereString, whereArgs: whereArgs);
    return result.map((map) => TaskModel.fromMap(map)).toList();
  }
}
