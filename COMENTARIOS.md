# CLAUDE.md

## Idioma
Todos los comentarios deben estar en español.

## Estándar de comentarios

### Encabezado de archivo
Cada archivo debe iniciar con un bloque de comentario con el siguiente formato:

// ============================================================
// NOMBRE: nombre_del_archivo.dart
// USO: Breve descripción de la responsabilidad del módulo
//      y dónde se usa dentro de la app.
// ============================================================

### Funciones y métodos
- Cada función pública debe tener un comentario una línea arriba explicando qué hace.
- Si recibe parámetros importantes, mencionarlos brevemente.

// Carga la lista de carreras desde Supabase y la cachea en el provider.
Future<List<Carrera>> getCarreras() async { ... }

### Providers
- Comentar para qué sirve cada provider y quién lo consume.

// Provider del caso de uso. Lo consumen los FutureProviders de esta feature.
final getCarrerasProvider = Provider<GetCarreras>(...);

### Lógica no obvia
- Comentar cualquier decisión que no sea evidente a primera vista.

// Se usa ref.watch y no ref.read para que el provider
// se recalcule al cambiar carrera o semestre seleccionados.