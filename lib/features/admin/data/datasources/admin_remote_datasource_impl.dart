// ============================================================
// NOMBRE: admin_remote_datasource_impl.dart
// USO: Implementación concreta del datasource admin. Realiza
//      operaciones CRUD de exámenes, carreras y salones en Supabase.
// ============================================================
import 'dart:typed_data';

import 'package:gestion_ets_escom/features/admin/data/models/administrativo_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestion_ets_escom/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/edificio_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/materia_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/salon_model.dart';

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final supabaseClient = Supabase.instance.client;

  @override
  Future<AdministrativoModel> login(String correo, String password) async {
    final authResponse = await supabaseClient.auth.signInWithPassword(
      email: correo,
      password: password,
    );

    if (authResponse.user == null) {
      throw Exception('Credenciales inválidas');
    }

    final data = await supabaseClient
        .from('administrativo')
        .select()
        .eq('correo', correo)
        .single();

    return AdministrativoModel.fromJson(data);
  }

  // ==========================================
  // LÓGICA DE EXÁMENES
  // ==========================================
  @override
  Future<ExamenModel> createExamen(ExamenModel examen) async {
    final response = await supabaseClient
        .from('examen')
        .insert(examen.toJson())
        .select()
        .single();
    return ExamenModel.fromJson(response);
  }

  @override
  Future<ExamenModel> updateExamen(ExamenModel examen) async {
    final response = await supabaseClient
        .from('examen')
        .update(examen.toJson())
        .eq('id', examen.id)
        .select()
        .single();
    return ExamenModel.fromJson(response);
  }

  @override
  // Soft-delete: marca inactivo para no perder el historial ni romper FKs.
  Future<void> deleteExamen(String id) async {
    await supabaseClient.from('examen').update({'activo': false}).eq('id', id);
  }

  // Actualiza en paralelo el examen (incluyendo profesor_id) y la materia (carrera/área).
  @override
  Future<void> updateExamenCompleto(ExamenUpdateParams params) async {
    await Future.wait([
      supabaseClient
          .from('examen')
          .update({
            'salon_id': params.salonId,
            'profesor_id': params.profesorId,
            'fecha': params.fecha.toIso8601String(),
            'hora': params.hora,
            'documento_guia': params.documentoGuia,
            'documento_proyecto': params.documentoProyecto,
            'notas': params.notas,
          })
          .eq('id', params.examenId),
      supabaseClient
          .from('materia')
          .update({
            'carrera_id': params.carreraId,
            'area_formacion_id': params.areaFormacionId,
          })
          .eq('id', params.materiaId),
    ]);
  }

  @override
  Future<void> createExamenCompleto(ExamenCreateParams params) async {
    await supabaseClient.from('examen').insert({
      'materia_id': params.materiaId,
      'salon_id': params.salonId,
      'profesor_id': params.profesorId,
      'fecha': params.fecha.toIso8601String(),
      'hora': params.hora,
      'turno': params.turno.value.toLowerCase(),
      'documento_guia': params.documentoGuia,
      'documento_proyecto': params.documentoProyecto,
      'notas': params.notas,
      'activo': true,
    });
  }

  // ==========================================
  // CATÁLOGOS (para dropdowns del formulario de edición)
  // ==========================================

  @override
  Future<List<Map<String, dynamic>>> getCatalogMaterias() async {
    final response = await supabaseClient
        .from('materia')
        .select('id, nombre, semestre, carrera(id, nombre, abreviatura)')
        .eq('activo', true)
        .order('nombre');
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getCatalogProfesores() async {
    final response = await supabaseClient
        .from('profesor')
        .select('id, nombre, primer_apellido, correo')
        .eq('activo', true)
        .order('primer_apellido')
        .order('nombre');
    return List<Map<String, dynamic>>.from(response as List);
  }

  // Devuelve solo carreras activas con campo color para el chip decorativo del dropdown.
  @override
  Future<List<Map<String, dynamic>>> getCatalogCarreras() async {
    final response = await supabaseClient
        .from('carrera')
        .select('id, nombre, abreviatura, plan, color')
        .eq('activo', true);
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getCatalogAreas() async {
    final response = await supabaseClient
        .from('area_formacion')
        .select('id, nombre, color');
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getCatalogSalonesActivos() async {
    final response = await supabaseClient
        .from('salon')
        .select('id, edificio, piso, numero_salon, etiqueta_salon')
        .eq('activo', true);
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<SalonModel>> getSalonesInactivos() async {
    final response = await supabaseClient
        .from('salon')
        .select()
        .eq('activo', false)
        .order('edificio')
        .order('piso')
        .order('numero_salon');
    return (response as List)
        .map((json) => SalonModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ==========================================
  // ARCHIVOS (Supabase Storage)
  // ==========================================
  @override
  Future<String?> uploadExamenFile(String fileName, Uint8List bytes) async {
    await supabaseClient.storage
        .from('Material de apoyo')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return fileName;
  }

  @override
  Future<String> getExamenFileUrl(String fileName) async {
    final String publicUrl = supabaseClient.storage
        .from('Material de apoyo')
        .getPublicUrl(fileName);

    return publicUrl;
  }

  // ==========================================
  // LÓGICA DE CARRERAS
  // ==========================================
  @override
  Future<CarreraModel> createCarrera(CarreraModel carrera) async {
    final response = await supabaseClient
        .from('carrera')
        .insert(carrera.toJson())
        .select()
        .single();
    return CarreraModel.fromJson(response);
  }

  @override
  Future<CarreraModel> updateCarrera(CarreraModel carrera) async {
    final response = await supabaseClient
        .from('carrera')
        .update(carrera.toJson())
        .eq('id', carrera.id)
        .select()
        .single();
    return CarreraModel.fromJson(response);
  }

  @override
  // Soft-delete: marca inactivo para preservar materias y exámenes asociados.
  Future<void> deleteCarrera(String id) async {
    await supabaseClient.from('carrera').update({'activo': false}).eq('id', id);
  }

  @override
  Future<List<CarreraModel>> getCarrerasInactivas() async {
    final response = await supabaseClient
        .from('carrera')
        .select()
        .eq('activo', false)
        .order('nombre');
    return (response as List)
        .map((json) => CarreraModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> reactivarCarrera(String id) async {
    await supabaseClient.from('carrera').update({'activo': true}).eq('id', id);
  }

  @override
  Future<void> reactivarExamen(String id) async {
    await supabaseClient.from('examen').update({'activo': true}).eq('id', id);
  }

  static const _examenSelectAdmin = '''
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

  @override
  Future<List<ExamenModel>> getExamenesInactivos() async {
    final response = await supabaseClient
        .from('examen')
        .select(_examenSelectAdmin)
        .eq('activo', false)
        .order('fecha', ascending: false);
    return (response as List)
        .map((json) => ExamenModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ==========================================
  // LÓGICA DE SALONES
  // ==========================================
  @override
  Future<SalonModel> createSalon(SalonModel salon) async {
    final response = await supabaseClient
        .from('salon')
        .insert(salon.toJson())
        .select()
        .single();
    return SalonModel.fromJson(response);
  }

  @override
  Future<SalonModel> updateSalon(SalonModel salon) async {
    final response = await supabaseClient
        .from('salon')
        .update(salon.toJson())
        .eq('id', salon.id)
        .select()
        .single();
    return SalonModel.fromJson(response);
  }

  @override
  // Soft-delete: marca inactivo en lugar de eliminar para no romper FK de exámenes.
  Future<void> deleteSalon(String id) async {
    await supabaseClient.from('salon').update({'activo': false}).eq('id', id);
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
  Future<EdificioModel> updateEdificio(
    EdificioModel edificio,
    int oldNumero,
  ) async {
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
    await supabaseClient
        .from('salon')
        .update({'activo': false})
        .eq('edificio', numero);
    await supabaseClient
        .from('edificio')
        .update({'activo': false})
        .eq('id', id);
  }
}
