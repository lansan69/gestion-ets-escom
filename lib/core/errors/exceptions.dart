// ============================================================
// NOMBRE: exceptions.dart
// USO: Excepciones personalizadas de la capa de datos. Lanzadas
//      por los datasources y capturadas en los repositorios para
//      convertirlas a Failure.
// ============================================================

class SupabaseException implements Exception {
  final String message;
  const SupabaseException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}
