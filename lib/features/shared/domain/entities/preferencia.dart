import 'package:equatable/equatable.dart';

class Preferencia extends Equatable {
  final bool omitir;
  final String carreraId;
  final int? seleccion1Semestre;
  final int? seleccion2Semestre;
  final int? seleccion3Semestre;

  const Preferencia({
    required this.omitir,
    required this.carreraId,
    this.seleccion1Semestre,
    this.seleccion2Semestre,
    this.seleccion3Semestre,
  });

  // Returns the ordered list of selected semesters, skipping nulls.
  List<int> get semestres => [
        seleccion1Semestre,
        seleccion2Semestre,
        seleccion3Semestre,
      ].whereType<int>().toList();

  @override
  List<Object?> get props => [
        omitir,
        carreraId,
        seleccion1Semestre,
        seleccion2Semestre,
        seleccion3Semestre,
      ];
}
