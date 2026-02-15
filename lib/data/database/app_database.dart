import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class AppDatabase {
  static Database? _database;
  static final AppDatabase instance = AppDatabase._init();

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orthokosh.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        currency INTEGER NOT NULL,
        type INTEGER NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        note TEXT,
        loanType INTEGER,
        personName TEXT,
        dueDate INTEGER,
        isPaid INTEGER DEFAULT 0,
        goalAmount REAL,
        targetDate INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY DEFAULT 1,
        defaultCurrency INTEGER NOT NULL DEFAULT 0,
        lowBalanceThreshold REAL NOT NULL DEFAULT 1000.0,
        enableNotifications INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Insert default settings
    await db.insert('user_settings', {
      'id': 1,
      'defaultCurrency': 0,
      'lowBalanceThreshold': 1000.0,
      'enableNotifications': 1,
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          passwordHash TEXT NOT NULL,
          createdAt INTEGER NOT NULL
        )
      ''');
    }
  }

  // === User CRUD ===

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  // === Transaction CRUD ===

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByType(
      TransactionType type) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type.index],
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // === Aggregate Queries ===

  Future<double> getTotalByType(TransactionType type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = ?',
      [type.index],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> calculateBalance() async {
    final totalEarn = await getTotalByType(TransactionType.earn);
    final totalSavings = await getTotalByType(TransactionType.savings);
    final totalExpense = await getTotalByType(TransactionType.expense);
    final totalLoan = await getTotalByType(TransactionType.loan);
    return (totalEarn + totalSavings) - (totalExpense + totalLoan);
  }

  // === Settings ===

  Future<Map<String, dynamic>> getSettings() async {
    final db = await database;
    final maps = await db.query('user_settings', where: 'id = 1');
    return maps.first;
  }

  Future<int> updateSettings(Map<String, dynamic> settings) async {
    final db = await database;
    return await db.update(
      'user_settings',
      settings,
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
