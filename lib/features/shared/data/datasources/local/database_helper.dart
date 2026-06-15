// ============================================================
// NOMBRE: database_helper.dart
// USO: Singleton que inicializa y expone la base de datos SQLite
//      local. Crea todas las tablas necesarias para el caché
//      offline de exámenes y catálogos. Consumido únicamente por
//      SharedLocalDatasourceImpl.
// ============================================================

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// v1 → v2: added preferencia + calendario tables
// v2 → v3: added color column to calendario
// v3 → v4: consolidated preferencia from one-row-per-semestre to
//           one-row-per-carrera with seleccion1/2/3_semestre columns
const int _kDbVersion = 4;

const String _kPreferenciaSchema = '''
  CREATE TABLE preferencia (
    omitir              INTEGER NOT NULL DEFAULT 0,
    carrera_id          TEXT    PRIMARY KEY,
    seleccion1_semestre INTEGER DEFAULT NULL,
    seleccion2_semestre INTEGER DEFAULT NULL,
    seleccion3_semestre INTEGER DEFAULT NULL
  )
''';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gestion_ets.db');
    return openDatabase(
      path,
      version: _kDbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(_kPreferenciaSchema);
      await db.execute('''
        CREATE TABLE IF NOT EXISTS calendario (
          examen_id TEXT PRIMARY KEY,
          color TEXT NOT NULL DEFAULT '#1A3A8F'
        )
      ''');
    }
    if (oldVersion < 3) {
      try {
        await db.execute(
          "ALTER TABLE calendario ADD COLUMN color TEXT NOT NULL DEFAULT '#1A3A8F'",
        );
      } catch (_) {
        // Column already exists — safe to ignore.
      }
    }
    if (oldVersion < 4) {
      await _migratePreferencia(db);
    }
  }

  // Migrates the preferencia table from old or broken schemas to the current one.
  // Old schema (v2): one row per (carrera_id, semestre) pair.
  // Broken schema (v3): had the 3-column layout but wrong PRIMARY KEY referencing
  //   a non-existent 'semestre' column — SQLite may have silently created it without
  //   the composite key, leaving it in an ambiguous state.
  Future<void> _migratePreferencia(Database db) async {
    try {
      final cols = await db.rawQuery('PRAGMA table_info(preferencia)');
      final names = {for (final c in cols) c['name'] as String};

      if (names.contains('semestre')) {
        // Old schema: consolidate multiple rows into one row per carrera.
        final oldRows = await db.query('preferencia');
        await db.execute('DROP TABLE preferencia');
        await db.execute(_kPreferenciaSchema);

        final Map<String, List<int>> byCarrera = {};
        bool hasOmit = false;
        for (final row in oldRows) {
          if ((row['omitir'] as int? ?? 0) == 1) {
            hasOmit = true;
            continue;
          }
          final cid = row['carrera_id'] as String? ?? '';
          if (cid.isEmpty) continue;
          final sem = row['semestre'] as int? ?? 0;
          if (sem <= 0) continue;
          final list = byCarrera.putIfAbsent(cid, () => []);
          if (list.length < 3) list.add(sem);
        }
        for (final e in byCarrera.entries) {
          final s = e.value;
          await db.insert('preferencia', {
            'carrera_id': e.key,
            'omitir': 0,
            'seleccion1_semestre': s.isNotEmpty ? s[0] : null,
            'seleccion2_semestre': s.length > 1 ? s[1] : null,
            'seleccion3_semestre': s.length > 2 ? s[2] : null,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        if (hasOmit) {
          await db.insert('preferencia', {'carrera_id': '', 'omitir': 1},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      } else if (!names.contains('seleccion1_semestre')) {
        // Broken v3 schema — recreate clean (no recoverable data).
        await db.execute('DROP TABLE IF EXISTS preferencia');
        await db.execute(_kPreferenciaSchema);
      }
      // Already correct schema — no-op.
    } catch (_) {
      await db.execute('DROP TABLE IF EXISTS preferencia');
      await db.execute(_kPreferenciaSchema);
    }
  }

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
        id             TEXT PRIMARY KEY,
        edificio       INTEGER NOT NULL,
        piso           INTEGER NOT NULL,
        numero_salon   INTEGER NOT NULL,
        etiqueta_salon TEXT,
        activo         INTEGER NOT NULL
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

    await db.execute(_kPreferenciaSchema);

    await db.execute('''
      CREATE TABLE calendario (
        examen_id TEXT PRIMARY KEY,
        color TEXT NOT NULL DEFAULT '#1A3A8F'
      )
    ''');
  }
}
