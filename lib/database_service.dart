// lib/database_service.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'calculation.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'calculations.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE calculations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            a REAL,
            b REAL,
            c REAL,
            discriminant REAL,
            result TEXT,
            dateTime TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertCalculation(Calculation calculation) async {
    final db = await database;
    await db.insert(
      'calculations',
      calculation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Calculation>> getCalculations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('calculations', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Calculation.fromMap(maps[i]));
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('calculations');
  }
}