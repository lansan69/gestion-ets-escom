# Gestión de ETS — ESCOM

Aplicación móvil para explorar, filtrar y gestionar los **Exámenes a Título de Suficiencia (ETS)** de la Escuela Superior de Cómputo (ESCOM). Orientada a dos perfiles: **estudiantes**, que consultan y guardan exámenes en su calendario personal, y **administradores**, que gestionan el catálogo completo.

---

## Contenido

1. [Características](#características)
2. [Tecnologías](#tecnologías)
3. [Arquitectura](#arquitectura)
4. [Estructura del proyecto](#estructura-del-proyecto)
5. [Configuración del entorno](#configuración-del-entorno)
6. [Ejecución](#ejecución)
7. [Esquema de base de datos local](#esquema-de-base-de-datos-local)
8. [Rutas de navegación](#rutas-de-navegación)
9. [Providers y estado global](#providers-y-estado-global)
10. [Patrones de diseño clave](#patrones-de-diseño-clave)

---

## Características

### Vista de estudiante

| Módulo | Descripción |
|---|---|
| **Explorar ETS** | Lista de exámenes filtrable por carrera, semestre, área de formación, turno, fecha y salón; búsqueda por materia o profesor |
| **Filtros multi-selección** | Carreras y áreas permiten seleccionar varios valores simultáneamente; semestres hasta tres opciones |
| **Calendario personal** | Agrega exámenes a tu calendario con código de color personalizable |
| **Detalle de examen** | Información completa: salón, profesor, turno, documentos (guía/proyecto) y notas |
| **Directorio de salones** | Salones organizados por edificio y piso con croquis visual |
| **Onboarding** | Selección de carrera y hasta tres semestres activos en la primera apertura |
| **Notificaciones locales** | Recordatorios configurables: día(s) de anticipación y hora del aviso para exámenes guardados en el calendario |
| **Modo offline-first** | Caché local SQLite; los datos están disponibles sin conexión y se sincronizan con Supabase en segundo plano |
| **Preferencias** | Cambio de carrera/semestres desde configuración; limpieza de caché |

### Vista de administrador

| Módulo | Descripción |
|---|---|
| **Autenticación** | Inicio de sesión con correo y contraseña mediante Supabase Auth |
| **Gestión de exámenes** | Crear, editar y desactivar exámenes (soft-delete con campo `activo`) |
| **Catálogos** | CRUD completo de carreras, materias y salones con listas de activos/inactivos |
| **Reactivación** | Restaurar elementos desactivados desde la vista de inactivos |
| **Logs** | Registro de acciones del administrador en Supabase |
| **Perfil** | Información del usuario administrador autenticado y cierre de sesión |

---

## Tecnologías

### Frontend
- **Flutter** / **Dart** ^3.12.1 — framework y lenguaje principal
- **flutter_riverpod** ^3.3.2 — gestión de estado e inyección de dependencias
- **go_router** ^17.3.0 — navegación declarativa con rutas anidadas y `ShellRoute`
- **table_calendar** ^3.2.0 — widget de calendario
- **flutter_svg** ^2.0.0 — renderizado de SVG
- **intl** ^0.20.2 — internacionalización (locale `es_ES`)

### Backend y persistencia
- **Supabase** (supabase_flutter ^2.14.1) — base de datos PostgreSQL, autenticación y almacenamiento de archivos
- **sqflite** ^2.3.3+1 — caché local SQLite con migraciones por versión
- **flutter_local_notifications** ^18.0.0 — notificaciones locales programadas
- **timezone** ^0.9.4 / **flutter_timezone** ^5.0.0 — soporte de zonas horarias para notificaciones

### Utilidades
- **dartz** ^0.10.1 — tipo `Either<Failure, T>` para manejo funcional de errores
- **equatable** ^2.0.8 — comparación estructural de entidades
- **flutter_dotenv** ^6.0.1 — variables de entorno desde `.env`
- **url_launcher** ^6.3.0 — apertura de documentos y vínculos externos
- **file_selector** ^1.0.3 — selector de archivos para carga de documentos
- **uuid** ^4.5.1 — generación de identificadores únicos

---

## Arquitectura

El proyecto sigue **Clean Architecture** con separación estricta en tres capas por feature:

```
lib/features/<feature>/
├── data/
│   ├── datasources/          # Acceso externo: Supabase (remoto) y SQLite (local)
│   ├── models/               # DTOs con serialización (fromJson / toMap)
│   └── repositories/         # Implementaciones concretas con Either<Failure, T>
├── domain/
│   ├── entities/             # Clases Dart puras con Equatable
│   ├── repositories/         # Contratos abstractos
│   └── usecases/             # Operaciones de responsabilidad única
└── presentation/
    ├── pages/                # Pantallas completas
    ├── providers/            # Riverpod Notifiers, FutureProvider, StreamProvider
    └── widgets/              # Componentes reutilizables
```

### Flujo de datos

```
Supabase ──► SharedRemoteDatasourceImpl ──┐
                                          ├──► SharedRepositoryImpl ──► UseCase ──► Provider ──► UI
SQLite   ──► SharedLocalDatasourceImpl  ──┘
```

- **Offline-first**: El datasource local emite datos inmediatamente; el datasource remoto actualiza en segundo plano y persiste en SQLite.
- **Either**: Todos los errores se mapean a `Failure`; la UI nunca recibe excepciones sin manejar.
- **Riverpod**: Los providers en cascada desde el repositorio hasta la UI garantizan reactividad automática al invalidar.

---

## Estructura del proyecto

```
lib/
├── core/
│   ├── constants/            # Constantes de API y configuración
│   ├── errors/               # Tipos Failure y Exception
│   ├── providers/            # core_providers.dart — providers globales
│   ├── router/               # Configuración de GoRouter y shells
│   ├── services/             # notification_service.dart
│   ├── theme/                # app_theme.dart y esquemas de color
│   └── utils/                # DateFormatter, SnackbarHelper, TextUtils
├── features/
│   ├── admin/
│   │   ├── data/
│   │   │   ├── datasources/  # AdminRemoteDatasourceImpl, AuthRemoteDatasourceImpl
│   │   │   ├── models/       # AdministrativoModel, LogModel
│   │   │   └── repositories/ # AdminRepositoryImpl, AuthRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/     # Administrativo, ExamenCreateParams, ExamenUpdateParams
│   │   │   ├── repositories/ # AdminRepository, AuthRepository
│   │   │   └── usecases/     # Login, Logout, CreateExamen, UpdateExamen...
│   │   └── presentation/
│   │       ├── pages/        # admin_login, admin_dashboard, admin_catalogs, admin_profile
│   │       ├── providers/    # admin_filter_providers, admin_salon_providers, catalog_provider
│   │       └── widgets/      # admin_examen_edit_form, catalog_modals
│   ├── shared/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── local/    # DatabaseHelper, SharedLocalDatasourceImpl
│   │   │   │   └── shared_remote_datasource_impl.dart
│   │   │   ├── models/       # ExamenModel, CarreraModel, MateriaModel...
│   │   │   └── repositories/ # SharedRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/     # Examen, Carrera, Materia, Salon, Profesor, AreaFormacion...
│   │   │   ├── repositories/ # SharedRepository
│   │   │   └── usecases/     # GetExamenes, AddToCalendario, GetPreferencia...
│   │   └── presentation/
│   │       ├── pages/        # individual_materia_view, welcome_page, splash_page
│   │       └── theme/        # app_colors, app_text_styles, elementos UI compartidos
│   └── user/
│       └── presentation/
│           ├── pages/        # explore_exams, calendar_page, salones_page,
│           │                 # settings_page, onboarding_carrera, onboarding_semestre
│           └── providers/    # examenes_providers, filter_providers, carrera_providers,
│                             # notification_prefs_provider, preferencias_provider...
├── main.dart                 # Inicialización: dotenv, Supabase, NotificationService
android/
├── app/
│   ├── build.gradle.kts      # compileSdk 36, Java 17 + desugaring
│   └── src/main/AndroidManifest.xml
└── build.gradle.kts          # Repositorios y configuración global de Gradle
```

---

## Configuración del entorno

### Requisitos previos

- Flutter ≥ 3.29 (Dart ≥ 3.3)
- Android Studio o VS Code con extensiones de Flutter y Dart
- JDK 17 o superior
- Cuenta en [Supabase](https://supabase.com) con el proyecto configurado

### Variables de entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://<tu-proyecto>.supabase.co
SUPABASE_PUBLISHABLE_KEY=<tu-publishable-key>
```

> El archivo `.env` está declarado como asset en `pubspec.yaml` y lo carga `flutter_dotenv` al inicio. **No lo incluyas en repositorios públicos.**

### Tablas requeridas en Supabase

El esquema remoto en PostgreSQL debe contar con las siguientes tablas (todas con columna `activo BOOLEAN`):

| Tabla | Descripción |
|---|---|
| `carrera` | Carreras de ingeniería |
| `area_formacion` | Áreas de formación con color hex |
| `materia` | Materias con FK a carrera y área |
| `salon` | Salones con edificio, piso y etiqueta |
| `profesor` | Profesores/coordinadores |
| `examen` | Exámenes ETS con todos sus atributos |
| `administrativo` | Usuarios administradores |
| `log` | Registro de acciones administrativas |

### Instalación de dependencias

```bash
flutter pub get
```

---

## Ejecución

```bash
# Ejecutar en dispositivo o emulador conectado
flutter run

# Build de debug para Android
flutter build apk --debug

# Build de release para Android
flutter build apk --release
```

> **Nota:** La primera compilación tarda varios minutos por la descarga de dependencias de Gradle. Las siguientes son incrementales.

---

## Esquema de base de datos local

El caché local usa SQLite gestionado por `DatabaseHelper`. La versión actual es **v5**.

| Tabla | Clave primaria | Propósito |
|---|---|---|
| `areas_formacion` | `id TEXT` | Áreas de formación con color para etiquetado visual |
| `carreras` | `id TEXT` | Carreras de ingeniería |
| `materias` | `id TEXT` | Materias vinculadas a carrera y área |
| `salones` | `id TEXT` | Salones con datos de ubicación |
| `profesores` | `id TEXT` | Profesores coordinadores de ETS |
| `examenes` | `id TEXT` | Exámenes con FK a las tablas anteriores |
| `preferencia` | `carrera_id TEXT` | Carrera y hasta 3 semestres seleccionados por el usuario |
| `calendario` | `examen_id TEXT` | Exámenes guardados con color asignado |
| `notification_prefs` | `id INTEGER (= 1)` | Preferencias de notificación: habilitado, días de anticipación, hora |

### Historia de migraciones

| Versión | Cambio |
|---|---|
| v1 | Esquema inicial: areas_formacion, carreras, materias, salones, profesores, examenes |
| v2 | Tablas `preferencia` y `calendario` |
| v3 | Columna `color` en `calendario` |
| v4 | Consolidación de `preferencia` a una fila por carrera con 3 columnas de semestre |
| v5 | Tabla `notification_prefs` para preferencias de notificación local |

---

## Rutas de navegación

La app usa GoRouter con dos shells principales.

### Shell de usuario (`AppShell` — barra de tabs inferior)

| Ruta | Página | Descripción |
|---|---|---|
| `/inicio` | `ExploreExams` | Lista de exámenes con filtros avanzados |
| `/calendario` | `CalendarPage` | Calendario de exámenes guardados |
| `/salones` | `SalonesPage` | Directorio de salones por edificio |
| `/config` | `SettingsPage` | Configuración: notificaciones, preferencias, caché |
| `/materia` | `IndividualMateriaView` | Detalle de un examen (recibe `extra: MateriaData`) |
| `/onboarding/carrera` | `OnBoardingCarrera` | Selección de carrera (onboarding y edición) |
| `/onboarding/semestre` | `OnBoardingSemestre` | Selección de semestres activos |
| `/settings/preferencias/carrera` | `OnBoardingCarrera` | Cambio de carrera desde configuración |
| `/settings/preferencias/semestre` | `OnBoardingSemestre` | Cambio de semestres desde configuración |

### Shell de administrador (`AdminShell`)

| Ruta | Página | Descripción |
|---|---|---|
| `/admin/login` | `AdminLoginPage` | Autenticación de administrador |
| `/admin/dashboard` | `AdminDashboardPage` | Gestión de exámenes y creación |
| `/admin/catalogos` | `AdminCatalogsPage` | Gestión de carreras, materias y salones |
| `/admin/perfil` | `AdminProfilePage` | Perfil y cierre de sesión del administrador |

### Pantallas auxiliares

| Ruta | Página |
|---|---|
| `/splash` | `SplashPage` — determina la ruta inicial según preferencias guardadas |
| `/bienvenida` | `WelcomePage` — pantalla de bienvenida / onboarding |

---

## Providers y estado global

### Providers de usuario

| Provider | Tipo Riverpod | Descripción |
|---|---|---|
| `allExamenesProvider` | `StreamProvider<List<Examen>>` | Carga offline-first de todos los exámenes |
| `examenesProvider` | `Provider<AsyncValue<List<Examen>>>` | Lista filtrada en memoria |
| `areasFormacionProvider` | `Provider<AsyncValue<List<AreaFormacion>>>` | Áreas únicas derivadas de los exámenes cargados |
| `filterCarreraProvider` | `NotifierProvider<Set<String>>` | Carreras seleccionadas como filtro (multi-selección) |
| `filterSemestresProvider` | `NotifierProvider<List<int>>` | Semestres seleccionados (multi-selección, hasta 3) |
| `filterAreaProvider` | `NotifierProvider<Set<String>>` | Áreas de formación seleccionadas (multi-selección) |
| `filterTurnoProvider` | `NotifierProvider<String?>` | Turno único: Matutino / Vespertino |
| `filterFechaProvider` | `NotifierProvider<DateTime?>` | Filtro de fecha exacta |
| `filterSalonProvider` | `NotifierProvider<String?>` | Filtro de salón por etiqueta |
| `filterSearchbarProvider` | `NotifierProvider<String?>` | Término de búsqueda por materia / profesor |
| `notificationPrefsProvider` | `AsyncNotifierProvider<NotificationPrefs>` | Preferencias de notificación local persistidas en SQLite |
| `preferenciasPageProvider` | `FutureProvider<Preferencia?>` | Preferencias del usuario (carrera + semestres) |
| `carrerasProvider` | `FutureProvider<List<Carrera>>` | Lista de carreras activas |

### Providers de administrador

| Provider | Tipo Riverpod | Descripción |
|---|---|---|
| `adminExamenesProvider` | `FutureProvider<List<Examen>>` | Exámenes activos para la vista de gestión |
| `adminExamenesInactivosProvider` | `FutureProvider<List<Examen>>` | Exámenes desactivados (soft-delete) |
| `adminCarrerasInactivasProvider` | `FutureProvider<List<Carrera>>` | Carreras desactivadas |
| `adminFilterCarreraProvider` | `NotifierProvider<Set<String>>` | Filtro de carrera en vista admin (multi-selección) |
| `adminFilterAreaProvider` | `NotifierProvider<Set<String>>` | Filtro de área en vista admin (multi-selección) |
| `currentAdminProvider` | `NotifierProvider<Administrativo?>` | Administrador autenticado en sesión |

---

## Patrones de diseño clave

### Soft-delete

Las entidades `examen` y `carrera` no se eliminan físicamente de Supabase. Al "eliminar" un registro se actualiza `activo = false`. Todas las consultas de recuperación filtran con `.eq('activo', true)`. Las vistas de administrador incluyen un toggle **Activos / Inactivos** que permite visualizar y reactivar registros desactivados.

### Offline-first con StreamProvider

`allExamenesProvider` usa un `StreamProvider` que emite primero los datos de SQLite y luego los de Supabase, garantizando que la UI responda aunque no haya conexión:

```dart
Stream<Either<Failure, List<Examen>>> getExamenes(ExamenFilter filter) async* {
  // 1. Emite desde caché local inmediatamente
  final localData = await _local.getExamenes(filter);
  yield Right(localData.map((m) => m.toEntity()).toList());

  // 2. Sincroniza con Supabase y actualiza SQLite
  final remoteData = await _remote.getExamenes();
  await _local.upsertExamenes(remoteData);
  yield Right(remoteData.map((m) => m.toEntity()).toList());
}
```

### Filtrado en memoria

El filtrado ocurre dentro de `examenesProvider` sin consultas adicionales a la base de datos, logrando respuesta instantánea al cambiar cualquier filtro.

### Notificaciones locales

`NotificationService` (singleton en `lib/core/services/notification_service.dart`) programa una notificación por cada examen en el calendario del usuario. Las preferencias (días de anticipación y hora) se persisten en SQLite y se configuran desde **Ajustes → Notificaciones**:

```
Guardar preferencias
       │
       ▼
NotificationService.scheduleAll(calendarioExamenes, prefs)
       │
       ├─ Cancela todas las notificaciones anteriores
       │
       └─ Por cada examen futuro:
          zonedSchedule(examDate − daysBefore @ hour:minute)
```

### Either / Failure

Todos los repositorios y casos de uso retornan `Either<Failure, T>`. La UI maneja el resultado con `.fold(onFailure, onSuccess)`, eliminando `try/catch` en la capa de presentación.

---

## Licencia

Proyecto académico — Escuela Superior de Cómputo (ESCOM), Instituto Politécnico Nacional.
