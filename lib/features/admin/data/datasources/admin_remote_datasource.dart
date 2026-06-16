// ============================================================
// NOMBRE: admin_remote_datasource.dart
// USO: Contrato abstracto para las operaciones CRUD avanzadas
//      del administrador (Exámenes, Carreras y Salones).
// ============================================================
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/edificio_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/materia_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/salon_model.dart';

abstract class AdminRemoteDatasource {
  // EXÁMENES
  Future<ExamenModel> createExamen(ExamenModel examen);
  Future<ExamenModel> updateExamen(ExamenModel examen);
  Future<void> deleteExamen(String id);

  // CARRERAS
  Future<CarreraModel> createCarrera(CarreraModel carrera);
  Future<CarreraModel> updateCarrera(CarreraModel carrera);
  Future<void> deleteCarrera(String id);

  // SALONES
  Future<SalonModel> createSalon(SalonModel salon);
  Future<SalonModel> updateSalon(SalonModel salon);
  Future<void> deleteSalon(String id);

  // MATERIAS
  Future<MateriaModel> createMateria(MateriaModel materia);
  Future<MateriaModel> updateMateria(MateriaModel materia);
  Future<void> deleteMateria(String id);

  // EDIFICIOS
  Future<EdificioModel> createEdificio(EdificioModel edificio);
  Future<EdificioModel> updateEdificio(EdificioModel edificio, int oldNumero);
  Future<void> deleteEdificio(String id, int numero);
}