// ============================================================
// NOMBRE: admin_remote_datasource_impl.dart
// USO: Implementación concreta del datasource admin. Realiza
//      operaciones CRUD de exámenes, carreras y salones en Supabase.
// ============================================================
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestion_ets_escom/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/edificio_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/materia_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/salon_model.dart';

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final supabaseClient = Supabase.instance.client;

  // ==========================================
  // LÓGICA DE EXÁMENES
  // ==========================================
  @override
  Future<ExamenModel> createExamen(ExamenModel examen) async {
    final response = await supabaseClient.from('examen').insert(examen.toJson()).select().single();
    return ExamenModel.fromJson(response);
  }

  @override
  Future<ExamenModel> updateExamen(ExamenModel examen) async {
    final response = await supabaseClient.from('examen').update(examen.toJson()).eq('id', examen.id).select().single();
    return ExamenModel.fromJson(response);
  }

  @override
  Future<void> deleteExamen(String id) async {
    await supabaseClient.from('examen').delete().eq('id', id);
  }

  // ==========================================
  // LÓGICA DE CARRERAS
  // ==========================================
  @override
  Future<CarreraModel> createCarrera(CarreraModel carrera) async {
    final response = await supabaseClient.from('carrera').insert(carrera.toJson()).select().single();
    return CarreraModel.fromJson(response);
  }

  @override
  Future<CarreraModel> updateCarrera(CarreraModel carrera) async {
    final response = await supabaseClient.from('carrera').update(carrera.toJson()).eq('id', carrera.id).select().single();
    return CarreraModel.fromJson(response);
  }

  @override
  Future<void> deleteCarrera(String id) async {
    await supabaseClient.from('carrera').delete().eq('id', id);
  }

  // ==========================================
  // LÓGICA DE SALONES
  // ==========================================
  @override
  Future<SalonModel> createSalon(SalonModel salon) async {
    final response = await supabaseClient.from('salon').insert(salon.toJson()).select().single();
    return SalonModel.fromJson(response);
  }

  @override
  Future<SalonModel> updateSalon(SalonModel salon) async {
    final response = await supabaseClient.from('salon').update(salon.toJson()).eq('id', salon.id).select().single();
    return SalonModel.fromJson(response);
  }

  @override
  // Soft-delete: marca inactivo en lugar de eliminar para no romper FK de exámenes.
  Future<void> deleteSalon(String id) async {
    await supabaseClient
        .from('salon')
        .update({'activo': false})
        .eq('id', id);
  }

  // ==========================================
  // LÓGICA DE MATERIAS
  // ==========================================
  static const _materiaSelect =
      'id, nombre, semestre, activo, carrera(id, nombre, abreviatura, plan, activo), area_formacion(id, nombre, color, activo)';

  @override
  Future<MateriaModel> createMateria(MateriaModel materia) async {
    final response = await supabaseClient
        .from('materia')
        .insert(materia.toJson())
        .select(_materiaSelect)
        .single();
    return MateriaModel.fromJson(response);
  }

  @override
  Future<MateriaModel> updateMateria(MateriaModel materia) async {
    final response = await supabaseClient
        .from('materia')
        .update(materia.toJson())
        .eq('id', materia.id)
        .select(_materiaSelect)
        .single();
    return MateriaModel.fromJson(response);
  }

  @override
  Future<void> deleteMateria(String id) async {
    await supabaseClient.from('materia').delete().eq('id', id);
  }

  // ==========================================
  // LÓGICA DE EDIFICIOS
  // ==========================================
  @override
  Future<EdificioModel> createEdificio(EdificioModel edificio) async {
    final response = await supabaseClient
        .from('edificio')
        .insert({'nombre': edificio.nombre, 'numero': edificio.numero})
        .select()
        .single();
    return EdificioModel.fromJson(response);
  }

  @override
  Future<EdificioModel> updateEdificio(EdificioModel edificio, int oldNumero) async {
    if (edificio.numero != oldNumero) {
      await supabaseClient
          .from('salon')
          .update({'edificio': edificio.numero})
          .eq('edificio', oldNumero);
    }
    final response = await supabaseClient
        .from('edificio')
        .update({'nombre': edificio.nombre, 'numero': edificio.numero})
        .eq('id', edificio.id)
        .select()
        .single();
    return EdificioModel.fromJson(response);
  }

  @override
  Future<void> deleteEdificio(String id, int numero) async {
    await supabaseClient.from('salon').update({'activo': false}).eq('edificio', numero);
    await supabaseClient.from('edificio').update({'activo': false}).eq('id', id);
  }
}
