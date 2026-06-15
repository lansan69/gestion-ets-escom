// ============================================================
// NOMBRE: database_helper.dart
// USO: Singleton que inicializa y expone la base de datos SQLite
//      local. Crea todas las tablas necesarias para el caché
//      offline de exámenes y catálogos. Consumido únicamente por
//      SharedLocalDatasourceImpl.
// ============================================================

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Devuelve la instancia de la BD, inicializándola si todavía no existe.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gestion_ets.db');
    return openDatabase(
      path,
      version: 2,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Crea la tabla preferencia si no existía (migración de v1 a v2).
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS preferencia (
          omitir     INTEGER NOT NULL DEFAULT 0,
          carrera_id TEXT NOT NULL,
          semestre   INTEGER NOT NULL,
          PRIMARY KEY (carrera_id, semestre)
        )
      ''');
      await db.execute('''
      CREATE TABLE  IF NOT EXISTS calendario (
        examen_id TEXT PRIMARY KEY
      )
    ''');
    }
  }

  // Activa las claves foráneas en SQLite (desactivadas por defecto en sqflite).
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Crea el esquema completo en la primera instalación.
  // El orden importa: las tablas referenciadas deben crearse antes que las que las usan.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE areas_formacion (
        id           TEXT PRIMARY KEY,
        nombre       TEXT NOT NULL,
        color        TEXT NOT NULL,
        activo       INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE carreras (
        id           TEXT PRIMARY KEY,
        nombre       TEXT NOT NULL,
        abreviatura  TEXT NOT NULL,
        plan         INTEGER NOT NULL,
        activo       INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE materias (
        id                TEXT PRIMARY KEY,
        nombre            TEXT NOT NULL,
        semestre          INTEGER NOT NULL,
        activo            INTEGER NOT NULL,
        carrera_id        TEXT NOT NULL,
        area_formacion_id TEXT,
        FOREIGN KEY (carrera_id)        REFERENCES carreras(id),
        FOREIGN KEY (area_formacion_id) REFERENCES areas_formacion(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE salones (
        id            TEXT PRIMARY KEY,
        edificio      INTEGER NOT NULL,
        piso          INTEGER NOT NULL,
        numero_salon  INTEGER NOT NULL,
        etiqueta_salon TEXT,
        activo        INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE profesores (
        id                TEXT PRIMARY KEY,
        nombre            TEXT NOT NULL,
        primer_apellido   TEXT NOT NULL,
        segundo_apellido  TEXT,
        correo            TEXT NOT NULL,
        activo            INTEGER NOT NULL,
        area_formacion_id TEXT,
        FOREIGN KEY (area_formacion_id) REFERENCES areas_formacion(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE examenes (
        id                 TEXT PRIMARY KEY,
        materia_id         TEXT NOT NULL,
        salon_id           TEXT NOT NULL,
        profesor_id        TEXT NOT NULL,
        fecha              TEXT NOT NULL,
        hora               TEXT NOT NULL,
        turno              TEXT NOT NULL,
        documento_guia     TEXT,
        documento_proyecto TEXT,
        notas              TEXT,
        activo             INTEGER NOT NULL,
        creado_en          TEXT,
        actualizado_en     TEXT,
        FOREIGN KEY (materia_id)  REFERENCES materias(id),
        FOREIGN KEY (salon_id)    REFERENCES salones(id),
        FOREIGN KEY (profesor_id) REFERENCES profesores(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE preferencia (
      omitir     INTEGER NOT NULL DEFAULT 0,
      carrera_id TEXT NOT NULL,
      semestre   INTEGER NOT NULL,
      PRIMARY KEY (carrera_id, semestre)
      )
    ''');

    await db.execute('''
      CREATE TABLE calendario (
        examen_id TEXT PRIMARY KEY
      )
    ''');
  }
}
