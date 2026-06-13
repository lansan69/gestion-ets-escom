// ============================================================
// NOMBRE: shared_remote_datasource.dart
// USO: Contrato abstracto del datasource remoto compartido.
//      Define las operaciones de consulta a Supabase para
//      catálogos y exámenes. Implementado por SharedRemoteDatasourceImpl.
// ============================================================
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/materia_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/profesor_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/salon_model.dart';

abstract class SharedRemoteDatasource {
  Future<List<CarreraModel>> getCarreras();
  Future<List<MateriaModel>> getMaterias(String carreraId);
  Future<List<SalonModel>> getSalones();
  Future<List<ProfesorModel>> getProfesores();

  // Exámenes
  Future<List<ExamenModel>> getExamenes();

  Future<List<ExamenModel>> searchExamenes({
    String? carreraId,
    List<int>? semestres,
    String? materiaId,
    String? areaFormacion,
    String? searchTerm,
  });

  Future<ExamenModel> getExamenById(String id);
}
