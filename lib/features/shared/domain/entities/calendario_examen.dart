import 'package:equatable/equatable.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';

class CalendarioExamen extends Equatable {
  final Examen examen;
  final String color; // hex from calendario table, e.g. '#1A3A8F'

  const CalendarioExamen({required this.examen, required this.color});

  @override
  List<Object?> get props => [examen, color];
}
