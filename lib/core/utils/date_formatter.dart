// ============================================================
// NOMBRE: date_formatter.dart
// USO: Utilidad para formatear fechas a cadenas legibles en
//      español. Consumido por widgets que muestran fechas de
//      exámenes (CardExamenMateria, CardExamenMateriaExpanded).
// ============================================================

class DateFormatter {
  static const _months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  static String formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';
}
