// ============================================================
// NOMBRE: admin_repository_impl.dart
// USO: Implementación del repositorio admin. Coordina el
//      datasource remoto y mapea errores a Failures.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/edificio_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/materia_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/salon_model.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/edificio.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource remoteDatasource;

  AdminRepositoryImpl({required this.remoteDatasource});

  // ==========================================
  // EXAMEN CRUD
  // ==========================================
  @override
  Future<Either<Failure, Examen>> createExamen(Examen examen) async {
    try {
      final model = await remoteDatasource.createExamen(examen as ExamenModel);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Examen>> updateExamen(Examen examen) async {
    try {
      final model = await remoteDatasource.updateExamen(examen as ExamenModel);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  // CORRECCIÓN: String en lugar de int
  Future<Either<Failure, void>> deleteExamen(String id) async { 
    try {
      await remoteDatasource.deleteExamen(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==========================================
  // CARRERA CRUD (Catálogo)
  // ==========================================
  @override
  Future<Either<Failure, Carrera>> createCarrera(Carrera carrera) async {
    try {
      final model = await remoteDatasource.createCarrera(CarreraModel(
        id: carrera.id,
        nombre: carrera.nombre,
        abreviatura: carrera.abreviatura,
        plan: carrera.plan,
        activo: carrera.activo,
      ));
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Carrera>> updateCarrera(Carrera carrera) async {
    try {
      final model = await remoteDatasource.updateCarrera(CarreraModel(
        id: carrera.id,
        nombre: carrera.nombre,
        abreviatura: carrera.abreviatura,
        plan: carrera.plan,
        activo: carrera.activo,
      ));
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCarrera(String id) async {
    try {
      await remoteDatasource.deleteCarrera(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==========================================
  // SALÓN CRUD (Catálogo)
  // ==========================================
  @override
  Future<Either<Failure, Salon>> createSalon(Salon salon) async {
    try {
      final model = await remoteDatasource.createSalon(SalonModel(
        id: salon.id,
        edificio: salon.edificio,
        piso: salon.piso,
        numeroSalon: salon.numeroSalon,
        etiquetaSalon: salon.etiquetaSalon,
        activo: salon.activo,
      ));
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Salon>> updateSalon(Salon salon) async {
    try {
      final model = await remoteDatasource.updateSalon(SalonModel(
        id: salon.id,
        edificio: salon.edificio,
        piso: salon.piso,
        numeroSalon: salon.numeroSalon,
        etiquetaSalon: salon.etiquetaSalon,
        activo: salon.activo,
      ));
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSalon(String id) async {
    try {
      await remoteDatasource.deleteSalon(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==========================================
  // MATERIA CRUD (Catálogo)
  // ==========================================
  @override
  Future<Either<Failure, Materia>> createMateria(Materia materia) async {
    try {
      final model = await remoteDatasource.createMateria(MateriaModel(
        id: materia.id,
        nombre: materia.nombre,
        carrera: materia.carrera,
        semestre: materia.semestre,
        activo: materia.activo,
        areaFormacion: materia.areaFormacion,
      ));
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Materia>> updateMateria(Materia materia) async {
    try {
      final model = await remoteDatasource.updateMateria(MateriaModel(
        id: materia.id,
        nombre: materia.nombre,
        carrera: materia.carrera,
        semestre: materia.semestre,
        activo: materia.activo,
        areaFormacion: materia.areaFormacion,
      ));
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMateria(String id) async {
    try {
      await remoteDatasource.deleteMateria(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==========================================
  // EDIFICIO CRUD (Catálogo)
  // ==========================================
  @override
  Future<Either<Failure, Edificio>> createEdificio(Edificio edificio) async {
    try {
      final model = await remoteDatasource.createEdificio(EdificioModel(
        id: edificio.id,
        nombre: edificio.nombre,
        numero: edificio.numero,
        activo: edificio.activo,
      ));
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Edificio>> updateEdificio(Edificio edificio, int oldNumero) async {
    try {
      final model = await remoteDatasource.updateEdificio(
        EdificioModel(
          id: edificio.id,
          nombre: edificio.nombre,
          numero: edificio.numero,
          activo: edificio.activo,
        ),
        oldNumero,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEdificio(String id, int numero) async {
    try {
      await remoteDatasource.deleteEdificio(id, numero);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}