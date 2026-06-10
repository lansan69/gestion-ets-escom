class LocalDatabase {
  static const String createFavoritesTable = '''
    CREATE TABLE IF NOT EXISTS favoritos (
      examen_id INTEGER PRIMARY KEY,
      materia_nombre TEXT NOT NULL,
      carrera_nombre TEXT NOT NULL,
      carrera_abreviatura TEXT NOT NULL,
      semestre INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      hora TEXT NOT NULL,
      turno TEXT NOT NULL,
      edificio INTEGER NOT NULL,
      piso INTEGER NOT NULL,
      numero_salon INTEGER NOT NULL,
      profesor_nombre_completo TEXT NOT NULL,
      notas TEXT,
      color_hex TEXT NOT NULL,
      guardado_en TEXT NOT NULL
    )
  ''';
}
