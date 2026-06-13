# Arquitectura del Proyecto — gestion_ets_escom

---

## Raíz del proyecto

| Archivo | Descripción |
|---|---|
| `pubspec.yaml` | Dependencias del proyecto (flutter_riverpod, go_router, supabase_flutter, dartz, equatable, etc.) |
| `COMENTARIOS.md` | Estándar de comentarios en español que debe seguir todo el código |

---

## lib/

| Archivo | Descripción |
|---|---|
| `main.dart` | Punto de entrada. Inicializa Supabase, configura ProviderScope y lanza la app |

---

## lib/core/

Lógica transversal que no pertenece a ninguna feature.

### lib/core/constants/

| Archivo | Descripción |
|---|---|
| `api_constants.dart` | URLs y claves de la API de Supabase |
| `app_constants.dart` | Constantes globales de la app (nombre, versión, etc.) |

### lib/core/errors/

| Archivo | Descripción |
|---|---|
| `exceptions.dart` | Excepciones propias del dominio |
| `failures.dart` | Clases `Failure` usadas con `Either` de dartz (`ServerFailure`, etc.) |

### lib/core/providers/

| Archivo | Descripción |
|---|---|
| `core_providers.dart` | Providers de infraestructura: `supabaseClientProvider`, `sharedRepositoryProvider` y similares |

### lib/core/router/

| Archivo | Descripción |
|---|---|
| `router.dart` | Definición de todas las rutas con GoRouter |
| `app_router.dart` | Configuración y construcción del `GoRouter` (guards, redirect) |
| `app_shell.dart` | Shell con `BottomNavigationBar` compartida entre las rutas principales |
| `router_refresh_stream.dart` | `Listenable` que notifica a GoRouter cuando cambia el estado de autenticación |

### lib/core/services/

| Archivo | Descripción |
|---|---|
| `export_service.dart` | Lógica para exportar datos (PDF u otro formato) |
| `launcher_service.dart` | Abstracción sobre `url_launcher` para abrir URLs y archivos externos |
| `notification_service.dart` | Configuración y envío de notificaciones locales |

### lib/core/supabase/

| Archivo | Descripción |
|---|---|
| `supabase_provider.dart` | Provider que expone el `SupabaseClient` inicializado |

### lib/core/theme/

| Archivo | Descripción |
|---|---|
| `app_theme.dart` | `ThemeData` global de la app |
| `color_schemes.dart` | Esquemas de color material3 |

### lib/core/utils/

| Archivo | Descripción |
|---|---|
| `date_formatter.dart` | Utilidades para formatear `DateTime` a strings legibles |
| `snackbar_helper.dart` | Helper para mostrar `SnackBar` de forma centralizada |

---

## lib/features/

Organizada por features. Cada feature sigue Clean Architecture: `domain` → `data` → `presentation`.

---

## lib/features/shared/

Código compartido entre las features `user` y `admin`.

### lib/features/shared/domain/entities/

Entidades de dominio puras, sin dependencias de Flutter ni de librerías externas.

| Archivo | Descripción |
|---|---|
| `examen.dart` | Entidad central del sistema. Contiene `Materia`, `Salon`, `Profesor`, `Turno`, fechas y documentos opcionales |
| `examen_filter.dart` | Modelo inmutable de filtros (`carreraId`, `semestres`, `materiaId`, `areaFormacion`, `searchTerm`) con `copyWith` |
| `materia.dart` | Representa una materia del plan de estudios, con su `Carrera` y `AreaFormacion` |
| `carrera.dart` | Representa una carrera (ISC, IA, LCD, etc.) con abreviatura y plan |
| `area_formacion.dart` | Área de formación académica con nombre y color hex |
| `salon.dart` | Salón de examen con edificio, piso y número de salón |
| `profesor.dart` | Profesor con nombre completo, correo y área de formación |
| `turno.dart` | Enum `Turno` con valores `matutino`, `vespertino`, `nocturno` y parseo desde string |

### lib/features/shared/domain/repositories/

| Archivo | Descripción |
|---|---|
| `shared_repository.dart` | Contrato abstracto: catálogos (`getCarreras`, `getMaterias`, `getSalones`, `getProfesores`) y exámenes (`getExamenes`, `searchExamenes`, `getExamenById`) |

### lib/features/shared/domain/usecases/

Casos de uso de dominio. Un archivo por operación.

#### lib/features/shared/domain/usecases/carrera/

| Archivo | Descripción |
|---|---|
| `get_carreras.dart` | Obtiene la lista de todas las carreras activas |
| `get_carrera_by_id.dart` | Obtiene una carrera por su UUID |

#### lib/features/shared/domain/usecases/catalogs/

| Archivo | Descripción |
|---|---|
| `get_materias.dart` | Obtiene las materias de una carrera dada |
| `get_profesores.dart` | Obtiene la lista de profesores |
| `get_salones.dart` | Obtiene la lista de salones |

#### lib/features/shared/domain/usecases/examen/

| Archivo | Descripción |
|---|---|
| `get_examenes.dart` | Obtiene todos los exámenes sin filtros. Consumido por `examenesProvider` para la carga inicial |
| `search_examenes.dart` | Busca exámenes con filtros opcionales (carrera, semestres, materia, área, texto libre) |
| `get_examen_by_id.dart` | Obtiene un examen por su UUID |

### lib/features/shared/data/models/

Modelos de datos que mapean JSON de Supabase a entidades de dominio.

| Archivo | Descripción |
|---|---|
| `examen_model.dart` | `fromJson` y `toEntity` para `Examen` |
| `materia_model.dart` | `fromJson` y `toEntity` para `Materia` |
| `carrera_model.dart` | `fromJson` y `toEntity` para `Carrera` |
| `area_model.dart` | `fromJson` y `toEntity` para `AreaFormacion` |
| `salon_model.dart` | `fromJson` y `toEntity` para `Salon` |
| `profesor_model.dart` | `fromJson` y `toEntity` para `Profesor` |

### lib/features/shared/data/datasources/

| Archivo | Descripción |
|---|---|
| `shared_remote_datasource.dart` | Contrato abstracto del datasource remoto compartido |
| `shared_remote_datasource_impl.dart` | Implementación con Supabase. Define el fragmento SELECT con JOINs, aplica filtros de carrera, semestre, área y texto en la query |

### lib/features/shared/data/repositories/

| Archivo | Descripción |
|---|---|
| `shared_repository_impl.dart` | Implementa `SharedRepository`. Delega al datasource y mapea `PostgrestException` a `Failure` |

### lib/features/shared/presentation/

#### lib/features/shared/presentation/theme/

| Archivo | Descripción |
|---|---|
| `app_colors.dart` | Paleta de colores semánticos de la app (primarios, status, texto, fondos) |
| `app_text_styles.dart` | Estilos de texto reutilizables (`headingLarge`, `bodySecondary`, etc.) |
| `colores_app.dart` | Definiciones de color adicionales o alias |

#### lib/features/shared/presentation/theme/elements/

Widgets reutilizables entre features.

| Archivo | Descripción |
|---|---|
| `app_buttons.dart` | `AppPrimaryButton`, `AppSecondaryButton` y `AppAnimatedPress` (wrapper con animación de escala) |
| `app_search_bar.dart` | Barra de búsqueda con campo de texto y botón de filtros. Abre `FilterCard` al presionar el ícono |
| `filter_card.dart` | Bottom sheet deslizable con filtros de carrera (chips), semestre (chips), área (chips), turno (radio chips), fecha (date picker) y salón (input numérico). Comunica cambios al padre vía callbacks |
| `card_materia.dart` | Tarjeta compacta de examen ETS con barra de color por estado/área, nombre, profesor, semestre, salón, fecha y hora |
| `card_materia_expanded.dart` | Tarjeta expandida de examen con sección de documentos PDF descargables |
| `career_card.dart` | Tarjeta informativa de carrera (sin estado seleccionable) |
| `selectable_career_card.dart` | Tarjeta de carrera con toggle de selección y límite via `canSelect`. Usada en onboarding y exploración |
| `semestre_card.dart` | Tarjeta de semestre con toggle de selección y límite. Usada en onboarding |
| `background_pattern_painter.dart` | `CustomPainter` que dibuja el patrón de fondo decorativo en la barra azul superior |
| `metachip.dart` | Chip pequeño de metadato (etiqueta + valor) usado en tarjetas de detalle |
| `pdf_chip.dart` | Chip con ícono de descarga para mostrar archivos PDF adjuntos a un examen |

#### lib/features/shared/presentation/

| Archivo | Descripción |
|---|---|
| `welcome_page.dart` | Pantalla de bienvenida mostrada antes del onboarding o cuando no hay sesión activa |

---

## lib/features/user/

Feature del usuario final (estudiante). Solo lectura; sin operaciones de escritura sobre la DB.

### lib/features/user/presentation/providers/

| Archivo | Descripción |
|---|---|
| `selection_providers.dart` | `SelectedCarreraNotifier` (String? UUID) y `SelectedSemestresNotifier` (List<int>, máx 3). Estado de la selección durante el onboarding |
| `carrera_providers.dart` | `FutureProvider` que carga la lista de carreras desde Supabase via el caso de uso `GetCarreras` |
| `filter_providers.dart` | Un `Notifier` + `NotifierProvider` por cada campo de filtro de búsqueda: `FilterCarreraNotifier` (String?), `FilterSemestresNotifier` (List<int>), `FilterAreaNotifier` (String?), `FilterTurnoNotifier` (String?), `FilterFechaNotifier` (DateTime?), `FilterSalonNotifier` (String?) |
| `examenes_providers.dart` | `getExamenesProvider` expone el caso de uso. `_allExamenesProvider` hace la carga única desde Supabase. `examenesProvider` aplica todos los filtros en memoria sobre el array completo y devuelve `AsyncValue<List<Examen>>` |

### lib/features/user/presentation/pages/

| Archivo | Descripción |
|---|---|
| `onboarding_carrera.dart` | Paso 1 del onboarding. Muestra `SelectableCareerCard` por carrera; guarda la selección en `selectedCarreraProvider`. Ruta: `/onboarding/carrera` |
| `onboarding_semestre.dart` | Paso 2 del onboarding. Muestra `SemestreCard` con límite de 3 semestres; guarda en `selectedSemestresProvider`. Ruta: `/onboarding/semestre` |
| `explore_exams.dart` | Pantalla principal del usuario. Lee los seis `filterProviders` con `ref.watch`, los convierte al formato que espera `FilterCard` y pasa los resultados filtrados de `examenesProvider` a `CardExamenMateria`. Ruta: `/inicio` |
| `individual_materia_view.dart` | Detalle de un examen individual. Muestra `CardExamenMateriaExpanded` con toda la información y documentos. Ruta: `/materia` |

---

## lib/features/admin/

Feature del administrador (personal ESCOM). Operaciones de escritura sobre la DB.

### lib/features/admin/domain/entities/

| Archivo | Descripción |
|---|---|
| `administrativo.dart` | Entidad que representa un usuario administrador con rol y correo institucional |

### lib/features/admin/domain/repositories/

| Archivo | Descripción |
|---|---|
| `admin_repository.dart` | Contrato para operaciones CRUD de exámenes: `createExamen`, `updateExamen`, `deleteExamen` |
| `auth_repository.dart` | Contrato de autenticación: `login` y `logout` |

### lib/features/admin/domain/usecases/examen/

| Archivo | Descripción |
|---|---|
| `create_examen.dart` | Crea un nuevo examen en la DB via `AdminRepository` |
| `update_examen.dart` | Actualiza los datos de un examen existente |
| `delete_examen.dart` | Elimina un examen por su UUID |

### lib/features/admin/domain/usecases/login/

| Archivo | Descripción |
|---|---|
| `login_usecase.dart` | Autentica al administrador con email y contraseña via `AuthRepository` |
| `logout_usecase.dart` | Cierra la sesión del administrador |

### lib/features/admin/data/datasources/

| Archivo | Descripción |
|---|---|
| `admin_remote_datasource.dart` | Contrato abstracto del datasource de administración |
| `admin_remote_datasource_impl.dart` | Implementación con Supabase para operaciones CRUD de exámenes |
| `auth_remote_datasource.dart` | Contrato abstracto del datasource de autenticación |
| `auth_remote_datasource_impl.dart` | Implementación con `supabase.auth.signInWithPassword` y `signOut` |

### lib/features/admin/data/models/

| Archivo | Descripción |
|---|---|
| `administrativo_model.dart` | `fromJson` y `toEntity` para `Administrativo` |
| `log_model.dart` | Modelo de log de operaciones administrativas |

### lib/features/admin/data/repositories/

| Archivo | Descripción |
|---|---|
| `admin_repository_impl.dart` | Implementa `AdminRepository`. Delega al datasource y mapea errores a `Failure` |
| `auth_repository_impl.dart` | Implementa `AuthRepository`. Delega al datasource de auth y mapea errores |

---

## Flujo de datos (user feature)

```
Supabase
  └── SharedRemoteDatasourceImpl   (SQL + JOINs)
        └── SharedRepositoryImpl   (Either<Failure, T>)
              └── GetExamenes      (caso de uso)
                    └── _allExamenesProvider   (carga única, FutureProvider)
                          └── examenesProvider  (filtra en memoria, Provider<AsyncValue>)
                                ↑ watch
                          filter_providers.dart  (6 Notifiers independientes)
                                ↑ callbacks
                          FilterCard            (bottom sheet con chips, date picker, input)
                                ↑ onFilterTap
                          AppSearchBar
                                ↑ widget
                          ExploreExams          (pantalla principal)
```
