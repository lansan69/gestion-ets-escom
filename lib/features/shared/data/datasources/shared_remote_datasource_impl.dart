// ============================================================
// NOMBRE: shared_remote_datasource_impl.dart
// USO: Implementación concreta del datasource remoto compartido.
//      Realiza consultas a Supabase para catálogos y exámenes.
// ============================================================

import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource.dart';
import 'package:gestion_ets_escom/features/shared/data/models/area_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/edificio_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/materia_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/profesor_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/salon_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Fragmento de SELECT reutilizado para examen con sus relaciones completas.
// materia!inner garantiza INNER JOIN: filas sin materia coincidente son excluidas,
// evitando que los filtros por carrera/semestre devuelvan materia:null.
const _examenSelect = '''
  *,
  materia!inner (
    id, nombre, semestre, activo,
    carrera ( id, nombre, abreviatura, plan, activo ),
    area_formacion ( id, nombre, color, activo )
  ),
  salon ( id, edificio, piso, numero_salon, etiqueta_salon, activo ),
  profesor (
    id, nombre, primer_apellido, segundo_apellido, correo, activo,
    area_formacion ( id, nombre, color, activo )
  )
''';

class SharedRemoteDatasourceImpl implements SharedRemoteDatasource {
  final SupabaseClient supabaseClient;

  SharedRemoteDatasourceImpl({required this.supabaseClient});

  // Obtiene todas las carreras activas.
  @override
  Future<List<CarreraModel>> getCarreras() async {
    final response = await supabaseClient.from('carrera').select();
    return response.map((json) => CarreraModel.fromJson(json)).toList();
  }

  // Obtiene las materias de una carrera específica con su área de formación.
  @override
  Future<List<MateriaModel>> getMaterias(String carreraId) async {
    final response = await supabaseClient
        .from('materia')
        .select(
          'id, nombre, semestre, activo, carrera ( id, nombre, abreviatura, plan, activo ), area_formacion ( id, nombre, color, activo )',
        )
        .eq('carrera_id', carreraId);
    return response.map((json) => MateriaModel.fromJson(json)).toList();
  }

  // Obtiene todos los salones activos (excluye soft-deleted).
  @override
  Future<List<SalonModel>> getSalones() async {
    final response = await supabaseClient
        .from('salon')
        .select()
        .eq('activo', true);
    return response.map((json) => SalonModel.fromJson(json)).toList();
  }

  // Obtiene todos los profesores con su área de formación.
  @override
  Future<List<ProfesorModel>> getProfesores() async {
    final response = await supabaseClient
        .from('profesor')
        .select('*, area_formacion ( id, nombre, color, activo )');
    return response.map((json) => ProfesorModel.fromJson(json)).toList();
  }

  // Obtiene todos los exámenes con sus relaciones completas.
  @override
  Future<List<ExamenModel>> getExamenes() async {
    final response =
        await supabaseClient.from('examen').select(_examenSelect);
    return response.map((json) => ExamenModel.fromJson(json)).toList();
  }

  // Busca exámenes aplicando filtros opcionales sobre materia, carrera, semestres y área.
  @override
  Future<List<ExamenModel>> searchExamenes({
    String? carreraId,
    List<int>? semestres,
    String? materiaId,
    String? areaFormacion,
    String? searchTerm,
  }) async {
    var query = supabaseClient.from('examen').select(_examenSelect);

    if (materiaId != null) query = query.eq('materia_id', materiaId);
    if (carreraId != null) query = query.eq('materia.carrera_id', carreraId);
    if (semestres != null && semestres.isNotEmpty) {
      query = query.inFilter('materia.semestre', semestres);
    }
    if (areaFormacion != null) {
      query = query.eq('materia.area_formacion_id', areaFormacion);
    }
    if (searchTerm != null && searchTerm.isNotEmpty) {
      query = query.ilike('materia.nombre', '%$searchTerm%');
    }

    final response = await query;
    return response.map((json) => ExamenModel.fromJson(json)).toList();
  }

  // Obtiene un examen por su ID (UUID).
  @override
  Future<ExamenModel> getExamenById(String id) async {
    final response = await supabaseClient
        .from('examen')
        .select(_examenSelect)
        .eq('id', id)
        .single();
    return ExamenModel.fromJson(response);
  }

  // Obtiene todas las áreas de formación activas.
  @override
  Future<List<AreaFormacionModel>> getAreasFormacion() async {
    final response = await supabaseClient
        .from('area_formacion')
        .select()
        .eq('activo', true);
    return response.map((json) => AreaFormacionModel.fromJson(json)).toList();
  }

  @override
  Future<List<EdificioModel>> getEdificios() async {
    final response = await supabaseClient
        .from('edificio')
        .select()
        .eq('activo', true)
        .order('numero');
    return response.map((json) => EdificioModel.fromJson(json)).toList();
  }
}
