import 'package:equatable/equatable.dart';

class CalendarioEntry extends Equatable {
  final String examenId;
  final String color;

  const CalendarioEntry({required this.examenId, required this.color});

  @override
  List<Object?> get props => [examenId, color];
}
