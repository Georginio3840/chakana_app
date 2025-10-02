class Usuario {
  final int? id;
  final String nombre;
  final String email;
  final DateTime fechaCreacion;

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'fecha_creacion': fechaCreacion.millisecondsSinceEpoch,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id']?.toInt(),
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      fechaCreacion: DateTime.fromMillisecondsSinceEpoch(map['fecha_creacion']),
    );
  }

  Usuario copyWith({
    int? id,
    String? nombre,
    String? email,
    DateTime? fechaCreacion,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'Usuario(id: $id, nombre: $nombre, email: $email, fechaCreacion: $fechaCreacion)';
  }
}