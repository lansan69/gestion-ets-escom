// ============================================================
// NOMBRE: admin_repository.dart
// USO: Contrato abstracto del repositorio admin. Define las
//      operaciones CRUD de exámenes, carreras y salones.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/edificio.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';

abstract class AdminRepository {
  // ==========================================
  // EXAMEN CRUD
  // ==========================================
  Future<Either<Failure, Examen>> createExamen(Examen examen);
  Future<Either<Failure, Examen>> updateExamen(Examen examen);
  Future<Either<Failure, void>> deleteExamen(String id);

  // ==========================================
  // CARRERA CRUD (Catálogo)
  // ==========================================
  Future<Either<Failure, Carrera>> createCarrera(Carrera carrera);
  Future<Either<Failure, Carrera>> updateCarrera(Carrera carrera);
  Future<Either<Failure, void>> deleteCarrera(String id);

  // ==========================================
  // SALÓN CRUD (Catálogo)
  // ==========================================
  Future<Either<Failure, Salon>> createSalon(Salon salon);
  Future<Either<Failure, Salon>> updateSalon(Salon salon);
  Future<Either<Failure, void>> deleteSalon(String id);

  // ==========================================
  // MATERIA CRUD (Catálogo)
  // ==========================================
  Future<Either<Failure, Materia>> createMateria(Materia materia);
  Future<Either<Failure, Materia>> updateMateria(Materia materia);
  Future<Either<Failure, void>> deleteMateria(String id);

  // ==========================================
  // EDIFICIO CRUD (Catálogo)
  // ==========================================
  Future<Either<Failure, Edificio>> createEdificio(Edificio edificio);
  Future<Either<Failure, Edificio>> updateEdificio(Edificio edificio, int oldNumero);
  Future<Either<Failure, void>> deleteEdificio(String id, int numero);
}