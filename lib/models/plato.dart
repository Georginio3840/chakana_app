class Plato {
  final int? id;
  final String nombre;
  final double precio;
  final DateTime fechaCreacion;

  Plato({
    this.id,
    required this.nombre,
    required this.precio,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'fecha_creacion': fechaCreacion.millisecondsSinceEpoch,
    };
  }

  factory Plato.fromMap(Map<String, dynamic> map) {
    return Plato(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      precio: map['precio'] as double,
      fechaCreacion: DateTime.fromMillisecondsSinceEpoch(map['fecha_creacion'] as int),
    );
  }

  Plato copyWith({
    int? id,
    String? nombre,
    double? precio,
    DateTime? fechaCreacion,
  }) {
    return Plato(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'Plato{id: $id, nombre: $nombre, precio: $precio, fechaCreacion: $fechaCreacion}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Plato &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nombre == other.nombre &&
          precio == other.precio;

  @override
  int get hashCode => id.hashCode ^ nombre.hashCode ^ precio.hashCode;
}