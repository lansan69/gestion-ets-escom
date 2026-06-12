import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';

abstract class AdminRemoteDatasource {
  Future<ExamenModel> createExamen(Map<String, dynamic> data);
  Future<ExamenModel> updateExamen(int id, Map<String, dynamic> data);
  Future<void> deleteExamen(int id);
}
