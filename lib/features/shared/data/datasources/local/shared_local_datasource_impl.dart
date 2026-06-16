// ============================================================
// NOMBRE: shared_local_datasource_impl.dart
// USO: Implementación concreta del datasource local con sqflite.
//      Ejecuta lecturas y escrituras sobre la BD SQLite a través
//      de DatabaseHelper. Consumido por SharedRepositoryImpl.
// ============================================================

import 'package:sqflite/sqflite.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/local/database_helper.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/local/shared_local_datasource.dart';
import 'package:gestion_ets_escom/features/shared/data/models/area_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/preferencia_model.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/calendario_entry.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/calendario_examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen_filter.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/stats_result.dart';

class SharedLocalDatasourceImpl implements SharedLocalDatasource {
  final DatabaseHelper dbHelper;

  SharedLocalDatasourceImpl({required this.dbHelper});

  // Lee todas las carreras almacenadas en la tabla carreras.
  @override
  Future<List<CarreraModel>> getCarreras() async {
    final db = await dbHelper.database;
    final rows = await db.query('carreras');
    return rows.map((row) => CarreraModel.fromMap(row)).toList();
  }

  // Lee todas las áreas de formación almacenadas en la tabla areas_formacion.
  @override
  Future<List<AreaFormacionModel>> getAreasFormacion() async {
    final db = await dbHelper.database;
    final rows = await db.query('areas_formacion');
    return rows.map((row) => AreaFormacionModel.fromMap(row)).toList();
  }

  // Lee exámenes con JOIN completo y aplica filtros opcionales de carrera y semestres.
  // La consulta reconstruye todos los objetos anidados desde las tablas normalizadas.
  @override
  Future<List<ExamenModel>> getExamenes(ExamenFilter filter) async {
    final db = await dbHelper.database;

    final whereClauses = <String>[];
    final args = <dynamic>[];

    if (filter.carreraId != null) {
      whereClauses.add('c.id = ?');
      args.add(filter.carreraId);
    }
    if (filter.semestres.isNotEmpty) {
      final placeholders = filter.semestres.map((_) => '?').join(', ');
      whereClauses.add('m.semestre IN ($placeholders)');
      args.addAll(filter.semestres);
    }

    final whereClause = whereClauses.isEmpty
        ? ''
        : 'WHERE ${whereClauses.join(' AND ')}';

    // Se usan alias para evitar colisiones de nombres entre tablas.
    final rows = await db.rawQuery('''
      SELECT
        e.id            AS e_id,
        e.fecha,        e.hora,        e.turno,
        e.documento_guia,              e.documento_proyecto,
        e.notas,
        e.activo        AS e_activo,
        e.creado_en,    e.actualizado_en,

        m.id            AS m_id,
        m.nombre        AS m_nombre,
        m.semestre,
        m.activo        AS m_activo,

        c.id            AS c_id,
        c.nombre        AS c_nombre,
        c.abreviatura,  c.plan,
        c.activo        AS c_activo,

        af_m.id         AS af_m_id,
        af_m.nombre     AS af_m_nombre,
        af_m.color      AS af_m_color,
        af_m.activo     AS af_m_activo,

        s.id            AS s_id,
        s.edificio,     s.piso,        s.numero_salon,
        s.etiqueta_salon,
        s.activo        AS s_activo,

        p.id            AS p_id,
        p.nombre        AS p_nombre,
        p.primer_apellido,             
        p.segundo_apellido,
        p.correo,
        p.activo        AS p_activo,

        af_p.id         AS af_p_id,
        af_p.nombre     AS af_p_nombre,
        af_p.color      AS af_p_color,
        af_p.activo     AS af_p_activo

      FROM examenes e
      INNER JOIN materias      m    ON e.materia_id         = m.id
      INNER JOIN carreras      c    ON m.carrera_id         = c.id
      LEFT  JOIN areas_formacion af_m ON m.area_formacion_id = af_m.id
      INNER JOIN salones       s    ON e.salon_id            = s.id
      INNER JOIN profesores    p    ON e.profesor_id         = p.id
      LEFT  JOIN areas_formacion af_p ON p.area_formacion_id = af_p.id
      $whereClause
      ORDER BY e.fecha ASC, e.hora ASC
    ''', args);
    return rows.map((row) => ExamenModel.fromMap(row)).toList();
  }

  // Inserta o reemplaza carreras en lote. Usa replace para actualizar registros existentes.
  @override
  Future<void> upsertCarreras(List<CarreraModel> carreras) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (final c in carreras) {
      batch.insert(
        'carreras',
        c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Inserta o reemplaza áreas de formación en lote.
  @override
  Future<void> upsertAreasFormacion(List<AreaFormacionModel> areas) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (final af in areas) {
      batch.insert(
        'areas_formacion',
        af.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Inserta o reemplaza exámenes y todos sus objetos relacionados en lote.
  // El orden de inserción respeta las claves foráneas:
  //   areas_formacion → carreras → materias → salones → profesores → examenes
  @override
  Future<void> upsertExamenes(List<ExamenModel> examenes) async {
    final db = await dbHelper.database;
    final batch = db.batch();

    for (final exam in examenes) {
      final m = exam.materia;
      final p = exam.profesor;
      final s = exam.salon;

      // 1. Área de formación de la materia (si existe)
      if (m.areaFormacion != null) {
        final af = m.areaFormacion!;
        batch.insert('areas_formacion', {
          'id': af.id,
          'nombre': af.nombre,
          'color': af.color,
          'activo': af.activo ? 1 : 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 2. Carrera
      batch.insert('carreras', {
        'id': m.carrera.id,
        'nombre': m.carrera.nombre,
        'abreviatura': m.carrera.abreviatura,
        'plan': m.carrera.plan,
        'activo': m.carrera.activo ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // 3. Materia — se guarda con carrera_id y área de formación como FK plana
      batch.insert('materias', {
        'id': m.id,
        'nombre': m.nombre,
        'semestre': m.semestre,
        'activo': m.activo ? 1 : 0,
        'carrera_id': m.carrera.id,
        'area_formacion_id': m.areaFormacion?.id,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // 4. Salón
      batch.insert('salones', {
        'id': s.id,
        'edificio': s.edificio,
        'piso': s.piso,
        'numero_salon': s.numeroSalon,
        'etiqueta_salon': s.etiquetaSalon,
        'activo': s.activo ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // 5. Área de formación del profesor (si existe)
      if (p.areaFormacion != null) {
        final af = p.areaFormacion!;
        batch.insert('areas_formacion', {
          'id': af.id,
          'nombre': af.nombre,
          'color': af.color,
          'activo': af.activo ? 1 : 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 6. Profesor
      batch.insert('profesores', {
        'id': p.id,
        'nombre': p.nombre,
        'primer_apellido': p.primerApellido,
        'segundo_apellido': p.segundoApellido,
        'correo': p.correo,
        'activo': p.activo ? 1 : 0,
        'area_formacion_id': p.areaFormacion?.id,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // 7. Examen — solo almacena FKs; los datos relacionados ya están en sus tablas
      batch.insert(
        'examenes',
        exam.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<bool> hasPreferencia() async {
    final db = await dbHelper.database;
    final rows = await db.query('preferencia', limit: 1);
    return rows.isNotEmpty;
  }

  @override
  Future<PreferenciaModel?> getPreferencia() async {
    final db = await dbHelper.database;
    final rows = await db.query(
      'preferencia',
      where: 'omitir = 0',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PreferenciaModel.fromMap(rows.first);
  }

  @override
  Future<void> savePreferencia(PreferenciaModel model) async {
    final db = await dbHelper.database;
    await db.insert(
      'preferencia',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> addToCalendario(String examenId, String color) async {
    final db = await dbHelper.database;
    await db.rawInsert(
      'INSERT OR REPLACE INTO calendario (examen_id, color) VALUES (?, ?)',
      [examenId, color],
    );
  }

  @override
  Future<bool> isInCalendario(String examenId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM calendario WHERE examen_id = ?',
      [examenId],
    );
    return (result.first['cnt'] as int) > 0;
  }

  @override
  Future<List<CalendarioEntry>> getCalendario() async {
    final db = await dbHelper.database;
    final rows = await db.query('calendario');
    return rows
        .map((r) => CalendarioEntry(
              examenId: r['examen_id'] as String,
              color: r['color'] as String,
            ))
        .toList();
  }

  @override
  Future<List<CalendarioExamen>> getCalendarioExamenes() async {
    final db = await dbHelper.database;

    // Same JOIN alias structure as getExamenes, joined with calendario.
    final rows = await db.rawQuery('''
      SELECT
        cal.color       AS cal_color,

        e.id            AS e_id,
        e.fecha,        e.hora,        e.turno,
        e.documento_guia,              e.documento_proyecto,
        e.notas,
        e.activo        AS e_activo,
        e.creado_en,    e.actualizado_en,

        m.id            AS m_id,
        m.nombre        AS m_nombre,
        m.semestre,
        m.activo        AS m_activo,

        c.id            AS c_id,
        c.nombre        AS c_nombre,
        c.abreviatura,  c.plan,
        c.activo        AS c_activo,

        af_m.id         AS af_m_id,
        af_m.nombre     AS af_m_nombre,
        af_m.color      AS af_m_color,
        af_m.activo     AS af_m_activo,

        s.id            AS s_id,
        s.edificio,     s.piso,        s.numero_salon,
        s.etiqueta_salon,
        s.activo        AS s_activo,

        p.id            AS p_id,
        p.nombre        AS p_nombre,
        p.primer_apellido,
        p.segundo_apellido,
        p.correo,
        p.activo        AS p_activo,

        af_p.id         AS af_p_id,
        af_p.nombre     AS af_p_nombre,
        af_p.color      AS af_p_color,
        af_p.activo     AS af_p_activo

      FROM calendario cal
      INNER JOIN examenes      e    ON e.id                  = cal.examen_id
      INNER JOIN materias      m    ON e.materia_id          = m.id
      INNER JOIN carreras      c    ON m.carrera_id          = c.id
      LEFT  JOIN areas_formacion af_m ON m.area_formacion_id = af_m.id
      INNER JOIN salones       s    ON e.salon_id            = s.id
      INNER JOIN profesores    p    ON e.profesor_id         = p.id
      LEFT  JOIN areas_formacion af_p ON p.area_formacion_id = af_p.id
      ORDER BY e.fecha ASC, e.hora ASC
    ''');

    return rows
        .map((row) => CalendarioExamen(
              examen: ExamenModel.fromMap(row).toEntity(),
              color: row['cal_color'] as String,
            ))
        .toList();
  }

  @override
  Future<void> removeFromCalendario(String examenId) async {
    final db = await dbHelper.database;
    await db.delete(
      'calendario',
      where: 'examen_id = ?',
      whereArgs: [examenId],
    );
  }

  @override
  Future<void> clearCache() async {
    final db = await dbHelper.database;
    final batch = db.batch();
    batch.delete('preferencia');
    batch.delete('calendario');
    await batch.commit(noResult: true);
  }

  // Consulta únicamente SQLite. La FK de carrera y área está en materias, no en examenes,
  // por lo que el JOIN pasa por materias → carreras / areas_formacion.
  @override
  Future<StatsResult> getStats() async {
    final db = await dbHelper.database;

    final carreraRows = await db.rawQuery('''
      SELECT c.id, c.nombre, c.abreviatura, COUNT(e.id) AS total
      FROM examenes e
      INNER JOIN materias m           ON e.materia_id        = m.id
      INNER JOIN carreras c           ON m.carrera_id        = c.id
      GROUP BY c.id, c.nombre, c.abreviatura
      ORDER BY total DESC
    ''');

    final areaRows = await db.rawQuery('''
      SELECT a.id, a.nombre, a.color, COUNT(e.id) AS total
      FROM examenes e
      INNER JOIN materias      m ON e.materia_id        = m.id
      INNER JOIN areas_formacion a ON m.area_formacion_id = a.id
      GROUP BY a.id, a.nombre, a.color
      ORDER BY total DESC
    ''');

    final totalExamenes = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM examenes'),
        ) ??
        0;
    final totalCarreras = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM carreras'),
        ) ??
        0;
    final totalAreas = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM areas_formacion'),
        ) ??
        0;

    return StatsResult(
      porCarrera: carreraRows
          .map((r) => CarreraStats(
                carreraId: r['id'] as String,
                nombre: r['nombre'] as String,
                abreviatura: r['abreviatura'] as String,
                total: r['total'] as int,
              ))
          .toList(),
      porArea: areaRows
          .map((r) => AreaStats(
                areaId: r['id'] as String,
                nombre: r['nombre'] as String,
                color: r['color'] as String,
                total: r['total'] as int,
              ))
          .toList(),
      totalExamenes: totalExamenes,
      totalCarreras: totalCarreras,
      totalAreas: totalAreas,
    );
  }
}
