import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart'; // Para manipular datas
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  final Logger _logger = Logger();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    _logger.i('Banco de dados localizado em: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          dueDate TEXT NOT NULL,
          isCompleted INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');

      _logger.i('Tabelas criadas com sucesso!');
    } catch (e) {
      _logger.e('Erro ao criar tabelas', error: e);
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      _logger.i('Atualizando banco de dados de versão $oldVersion para $newVersion');
      // Scripts de atualização, se necessários
    } catch (e) {
      _logger.e('Erro ao atualizar o banco de dados', error: e);
    }
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _logger.i('Banco de dados fechado com sucesso.');
  }

  // CRUD PARA TAREFAS

  Future<int> addTask(Task task) async {
    final db = await instance.database;
    try {
      int id = await db.insert('tasks', task.toMap());
      _logger.i('Tarefa adicionada com sucesso. ID: $id');
      return id;
    } catch (e) {
      _logger.e('Erro ao adicionar tarefa', error: e);
      return -1;
    }
  }

  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;
    try {
      final result = await db.query('tasks', orderBy: 'dueDate ASC');
      _logger.i('Tarefas recuperadas: ${result.length}');
      return result.map((json) => Task.fromMap(json)).toList();
    } catch (e) {
      _logger.e('Erro ao buscar tarefas', error: e);
      return [];
    }
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    try {
      final result = await db.query(
        'tasks',
        where: "DATE(dueDate) = ?",
        whereArgs: [formattedDate],
      );
      _logger.i('Tarefas para $formattedDate recuperadas: ${result.length}');
      return result.map((json) => Task.fromMap(json)).toList();
    } catch (e) {
      _logger.e('Erro ao buscar tarefas para $formattedDate', error: e);
      return [];
    }
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    try {
      int rowsAffected = await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      _logger.i('Tarefa atualizada. Linhas afetadas: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      _logger.e('Erro ao atualizar tarefa', error: e);
      return -1;
    }
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    try {
      int rowsDeleted = await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.i('Tarefa deletada. Linhas excluídas: $rowsDeleted');
      return rowsDeleted;
    } catch (e) {
      _logger.e('Erro ao deletar tarefa', error: e);
      return -1;
    }
  }

  // CRUD PARA USUÁRIOS

  Future<int> addUser(String email, String password) async {
    final db = await instance.database;
    if (email.isEmpty || password.isEmpty) {
      _logger.w('E-mail ou senha estão vazios. Registro abortado.');
      return -1;
    }
    try {
      int id = await db.insert('users', {
        'email': email.trim(),
        'password': password.trim(),
      });
      _logger.i('Usuário adicionado com sucesso. ID: $id');
      return id;
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        _logger.e('O e-mail já está em uso.', error: e);
      } else {
        _logger.e('Erro ao adicionar usuário', error: e);
      }
      return -1;
    }
  }

  Future<bool> validateUser(String email, String password) async {
    final db = await instance.database;
    if (email.isEmpty || password.isEmpty) {
      _logger.w('E-mail ou senha estão vazios. Validação falhou.');
      return false;
    }
    try {
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email.trim(), password.trim()],
      );
      bool isValid = result.isNotEmpty;
      _logger.i('Validação de usuário: $isValid');
      return isValid;
    } catch (e) {
      _logger.e('Erro ao validar usuário', error: e);
      return false;
    }
  }

  Future<bool> emailExists(String email) async {
    final db = await instance.database;
    try {
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim()],
      );
      bool exists = result.isNotEmpty;
      _logger.i('Verificação de e-mail existente: $exists');
      return exists;
    } catch (e) {
      _logger.e('Erro ao verificar e-mail', error: e);
      return false;
    }
  }
}
