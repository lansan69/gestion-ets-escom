import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource.dart';
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/materia_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/profesor_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/salon_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SharedRemoteDatasourceImpl implements SharedRemoteDatasource {
  final SupabaseClient supabaseClient;
  
  SharedRemoteDatasourceImpl({required this.supabaseClient});

  @override
  Future<List<CarreraModel>> getCarreras() async {
    final response = await supabaseClient.from('carrera').select();
    return response.map((json) => CarreraModel.fromJson(json)).toList();
  }

  @override
  Future<List<MateriaModel>> getMaterias(int carreraId) {
    throw UnimplementedError();
  }

  @override
  Future<List<SalonModel>> getSalones() {
    throw UnimplementedError();
  }

  @override
  Future<List<ProfesorModel>> getProfesores() {
    throw UnimplementedError();
  }

  @override
  Future<List<ExamenModel>> getExamenes() {
    throw UnimplementedError();
  }

  @override
  Future<List<ExamenModel>> searchExamenes({
    required int carreraId,
    required int semestre,
    int? materiaId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ExamenModel> getExamenById(int id) {
    throw UnimplementedError();
  }
}
