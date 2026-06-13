// ============================================================
// NOMBRE: log_model.dart
// USO: Modelo de datos para los registros de auditoría del panel
//      admin. Almacena acción, tabla afectada y snapshots JSON
//      de los datos anteriores y nuevos. Consumido por el módulo
//      de logs del panel de gestión.
// ============================================================

class LogModel {
  final int id;
  final int administrativoId;
  final String accion; // 'CREAR' | 'ACTUALIZAR' | 'ELIMINAR'
  final String tablaAfectada;
  final int registroId;
  final Map<String, dynamic>? datosAnteriores; // JSONB
  final Map<String, dynamic>? datosNuevos; // JSONB
  final DateTime creadoEn;

  const LogModel({
    required this.id,
    required this.administrativoId,
    required this.accion,
    required this.tablaAfectada,
    required this.registroId,
    this.datosAnteriores,
    this.datosNuevos,
    required this.creadoEn,
  });

  // Parsea el JSON devuelto por Supabase desde la tabla logs.
  factory LogModel.fromJson(Map<String, dynamic> json) => LogModel(
        id: json['id'] as int,
        administrativoId: json['administrativo_id'] as int,
        accion: json['accion'] as String,
        tablaAfectada: json['tabla_afectada'] as String,
        registroId: json['registro_id'] as int,
        datosAnteriores:
            json['datos_anteriores'] as Map<String, dynamic>?,
        datosNuevos: json['datos_nuevos'] as Map<String, dynamic>?,
        creadoEn: DateTime.parse(json['creado_en'] as String),
      );
}
