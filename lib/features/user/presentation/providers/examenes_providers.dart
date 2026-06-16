// ============================================================
// NOMBRE: examenes_providers.dart
// USO: Providers para la carga y filtrado en memoria de exámenes ETS.
//      _allExamenesProvider carga con estrategia offline-first.
//      examenesProvider aplica los filtros activos en memoria sobre
//      esa lista, incluido el término de búsqueda por materia/profesor.
//      areasFormacionProvider extrae áreas únicas de los exámenes cargados
//      para alimentar los chips de FilterCard. Consumido por ExploreExams.
// ============================================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/area_formacion.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen_filter.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/examen/get_examenes.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/filter_providers.dart';

// Provider del caso de uso. Consumido únicamente por _allExamenesProvider.
final getExamenesProvider = Provider<GetExamenes>(
  (ref) => GetExamenes(ref.read(sharedRepositoryProvider)),
);

// Carga offline-first de todos los exámenes sin pre-filtro de onboarding.
// El filtrado fino se realiza en memoria dentro de examenesProvider.
// Público para que admin pueda invalidarlo tras mutaciones.
final allExamenesProvider = StreamProvider<List<Examen>>((ref) {
  return ref
      .read(getExamenesProvider)(const ExamenFilter())
      .map(
        (either) => either.fold(
          (failure) => throw failure.message,
          (examenes) => examenes,
        ),
      );
});

// Extrae las áreas de formación únicas de los exámenes ya cargados.
// No realiza consultas adicionales: se deriva de allExamenesProvider.
// Se recalcula automáticamente cuando allExamenesProvider emite nuevos datos.
// Consumido por ExploreExams para alimentar los chips de área en FilterCard.
final areasFormacionProvider = Provider<AsyncValue<List<AreaFormacion>>>((ref) {
  final examsAsync = ref.watch(allExamenesProvider);
  return examsAsync.whenData((exams) {
    final seen = <String>{};
    final areas = <AreaFormacion>[];
    for (final e in exams) {
      final af = e.materia.areaFormacion;
      if (af != null && seen.add(af.id)) areas.add(af);
    }
    return areas;
  });
});

// Aplica los filtros activos sobre la lista completa en memoria.
// Se recalcula automáticamente cuando cambia cualquier provider de filtro.
// Devuelve AsyncValue para que el consumidor pueda manejar loading/error/data.
final examenesProvider = Provider<AsyncValue<List<Examen>>>((ref) {
  final allAsync = ref.watch(allExamenesProvider);
  final carrera = ref.watch(filterCarreraProvider);
  final semestres = ref.watch(filterSemestresProvider);
  final area = ref.watch(filterAreaProvider);
  final turno = ref.watch(filterTurnoProvider);
  final fecha = ref.watch(filterFechaProvider);
  final salon = ref.watch(filterSalonProvider);
  final search = ref.watch(filterSearchbarProvider);

  return allAsync.whenData((all) {
    return all.where((e) {
      if (carrera.isNotEmpty && !carrera.contains(e.materia.carrera.id)) return false;
      if (semestres.isNotEmpty && !semestres.contains(e.materia.semestre)) {
        return false;
      }
      if (area.isNotEmpty && !area.contains(e.materia.areaFormacion?.id)) return false;
      // El FilterCard envía 'Matutino'/'Vespertino'; el enum usa 'MATUTINO'/'VESPERTINO'.
      if (turno != null && e.turno.value != turno.toUpperCase()) return false;
      if (fecha != null) {
        final examDay = DateTime(e.fecha.year, e.fecha.month, e.fecha.day);
        final filterDay = DateTime(fecha.year, fecha.month, fecha.day);
        if (examDay != filterDay) return false;
      }
      // El FilterCard almacena el número de salón como String via int.toString().
      if (salon != null &&
          !e.salon.etiquetaSalon.toString().toLowerCase().contains(salon.toLowerCase()))
        return false;
      // Búsqueda insensible a mayúsculas por nombre de materia o nombre completo del profesor.
      if (search != null && search.isNotEmpty) {
        final term = search.toLowerCase();
        if (!e.materia.nombre.toLowerCase().contains(term) &&
            !e.profesor.nombreCompleto.toLowerCase().contains(term)) {
          return false;
        }
      }
      return true;
    }).toList();
  });
});
