// ============================================================
// NOMBRE: admin_repository_impl.dart
// USO: Implementación del repositorio admin. Coordina el
//      datasource y mapea errores a Failures. Pendiente de
//      implementar los métodos CRUD de exámenes.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient supabaseClient; // ✅ typed, no default

  AdminRepositoryImpl({required this.supabaseClient}); // ✅ properly injected

  @override
  Future<Either<Failure, Examen>> createExamen(Examen examen) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Examen>> updateExamen(Examen examen) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteExamen(int id) {
    throw UnimplementedError();
  }
}
