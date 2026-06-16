// ============================================================
// NOMBRE: admin_remote_datasource.dart
// USO: Contrato abstracto para las operaciones CRUD avanzadas
//      del administrador (Exámenes, Carreras y Salones).
// ============================================================
import 'dart:typed_data';

import 'package:gestion_ets_escom/features/admin/data/models/administrativo_model.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/examen_create_params.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/examen_update_params.dart';
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/edificio_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/materia_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/salon_model.dart';

export 'package:gestion_ets_escom/features/admin/domain/entities/examen_create_params.dart';
export 'package:gestion_ets_escom/features/admin/domain/entities/examen_update_params.dart';

abstract class AdminRemoteDatasource {
  Future<AdministrativoModel> login(String correo, String password);
  // EXÁMENES
  Future<ExamenModel> createExamen(ExamenModel examen);
  Future<ExamenModel> updateExamen(ExamenModel examen);
  Future<void> deleteExamen(String id);
  Future<void> createExamenCompleto(ExamenCreateParams params);
  Future<void> updateExamenCompleto(ExamenUpdateParams params);
  Future<List<Map<String, dynamic>>> getCatalogMaterias();
  Future<List<Map<String, dynamic>>> getCatalogProfesores();

  // CATÁLOGOS (para dropdowns del formulario de edición de examen)
  Future<List<Map<String, dynamic>>> getCatalogCarreras();
  Future<List<Map<String, dynamic>>> getCatalogAreas();
  Future<List<Map<String, dynamic>>> getCatalogSalonesActivos();
  Future<List<SalonModel>> getSalonesInactivos();

  // ARCHIVOS (Supabase Storage)
  Future<String?> uploadExamenFile(String fileName, Uint8List bytes);
  Future<String> getExamenFileUrl(String fileName);
  
  // CARRERAS
  Future<CarreraModel> createCarrera(CarreraModel carrera);
  Future<CarreraModel> updateCarrera(CarreraModel carrera);
  Future<void> deleteCarrera(String id);
  Future<void> reactivarCarrera(String id);
  Future<List<CarreraModel>> getCarrerasInactivas();
  Future<List<ExamenModel>> getExamenesInactivos();
  Future<void> reactivarExamen(String id);

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
