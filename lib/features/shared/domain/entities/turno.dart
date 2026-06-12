enum Turno {
  matutino('MATUTINO'),
  vespertino('VESPERTINO'),
  nocturno('NOCTURNO');

  const Turno(this.value);
  final String value;

  static Turno fromValue(String v) =>
      Turno.values.firstWhere((t) => t.value == v.toUpperCase());
}
