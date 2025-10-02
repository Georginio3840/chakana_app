enum EstadoOrden {
  enPreparacion('En Preparación'),
  entregado('Entregado');

  const EstadoOrden(this.nombre);
  final String nombre;
}

class Orden {
  final int? id;
  final DateTime fechaCreacion;
  final EstadoOrden estado;
  final double total;
  final List<PlatoOrden> platos;

  Orden({
    this.id,
    DateTime? fechaCreacion,
    this.estado = EstadoOrden.enPreparacion,
    required this.total,
    required this.platos,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha_creacion': fechaCreacion.millisecondsSinceEpoch,
      'estado': estado.index,
      'total': total,
    };
  }

  factory Orden.fromMap(Map<String, dynamic> map, List<PlatoOrden> platos) {
    return Orden(
      id: map['id'] as int?,
      fechaCreacion: DateTime.fromMillisecondsSinceEpoch(map['fecha_creacion'] as int),
      estado: EstadoOrden.values[map['estado'] as int],
      total: map['total'] as double,
      platos: platos,
    );
  }

  double calcularTotal() {
    return platos.fold(0.0, (sum, item) => sum + (item.precio * item.cantidad));
  }

  Orden copyWith({
    int? id,
    DateTime? fechaCreacion,
    EstadoOrden? estado,
    double? total,
    List<PlatoOrden>? platos,
  }) {
    return Orden(
      id: id ?? this.id,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      estado: estado ?? this.estado,
      total: total ?? this.total,
      platos: platos ?? this.platos,
    );
  }

  @override
  String toString() {
    return 'Orden{id: $id, fechaCreacion: $fechaCreacion, estado: $estado, total: $total, platos: ${platos.length}}';
  }
}

class PlatoOrden {
  final int? id;
  final int ordenId;
  final int platoId;
  final String nombre;
  final double precio;
  final int cantidad;

  PlatoOrden({
    this.id,
    required this.ordenId,
    required this.platoId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orden_id': ordenId,
      'plato_id': platoId,
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
    };
  }

  factory PlatoOrden.fromMap(Map<String, dynamic> map) {
    return PlatoOrden(
      id: map['id'] as int?,
      ordenId: map['orden_id'] as int,
      platoId: map['plato_id'] as int,
      nombre: map['nombre'] as String,
      precio: map['precio'] as double,
      cantidad: map['cantidad'] as int,
    );
  }

  double get subtotal => precio * cantidad;

  PlatoOrden copyWith({
    int? id,
    int? ordenId,
    int? platoId,
    String? nombre,
    double? precio,
    int? cantidad,
  }) {
    return PlatoOrden(
      id: id ?? this.id,
      ordenId: ordenId ?? this.ordenId,
      platoId: platoId ?? this.platoId,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  @override
  String toString() {
    return 'PlatoOrden{id: $id, platoId: $platoId, nombre: $nombre, precio: $precio, cantidad: $cantidad}';
  }
}