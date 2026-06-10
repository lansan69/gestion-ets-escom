class SupabaseException implements Exception {
  final String message;
  const SupabaseException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}
