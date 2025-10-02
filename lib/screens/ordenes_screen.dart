import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/orden.dart';
import 'crear_orden_screen.dart';
import 'detalle_orden_screen.dart';

class OrdenesScreen extends StatefulWidget {
  const OrdenesScreen({super.key});

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Orden> _ordenes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarOrdenes();
  }

  Future<void> _cargarOrdenes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ordenes = await _databaseHelper.getAllOrdenes();
      setState(() {
        _ordenes = ordenes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar órdenes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cambiarEstadoOrden(Orden orden) async {
    final nuevoEstado = orden.estado == EstadoOrden.enPreparacion
        ? EstadoOrden.entregado
        : EstadoOrden.enPreparacion;

    try {
      await _databaseHelper.updateEstadoOrden(orden.id!, nuevoEstado);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado a: ${nuevoEstado.nombre}'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _cargarOrdenes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarOrden(Orden orden) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar la orden #${orden.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _databaseHelper.deleteOrden(orden.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Orden eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _cargarOrdenes();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar orden: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildEstadoChip(EstadoOrden estado) {
    Color color;
    IconData icon;

    switch (estado) {
      case EstadoOrden.enPreparacion:
        color = Colors.orange;
        icon = Icons.restaurant;
        break;
      case EstadoOrden.entregado:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
    }

    return Chip(
      label: Text(
        estado.nombre,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      avatar: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ordenes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay órdenes registradas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea tu primera orden usando el botón +',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarOrdenes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _ordenes.length,
                    itemBuilder: (context, index) {
                      final orden = _ordenes[index];
                      final fechaFormateada =
                          '${orden.fechaCreacion.day}/${orden.fechaCreacion.month}/${orden.fechaCreacion.year} ${orden.fechaCreacion.hour}:${orden.fechaCreacion.minute.toString().padLeft(2, '0')}';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleOrdenScreen(orden: orden),
                              ),
                            );
                            _cargarOrdenes();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Orden #${orden.id}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    _buildEstadoChip(orden.estado),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      fechaFormateada,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${orden.platos.length} plato(s)',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total: \$${orden.total.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () => _cambiarEstadoOrden(orden),
                                          icon: Icon(
                                            orden.estado == EstadoOrden.enPreparacion
                                                ? Icons.check_circle_outline
                                                : Icons.restaurant_outlined,
                                          ),
                                          tooltip: orden.estado == EstadoOrden.enPreparacion
                                              ? 'Marcar como entregado'
                                              : 'Marcar como en preparación',
                                          color: orden.estado == EstadoOrden.enPreparacion
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                        IconButton(
                                          onPressed: () => _eliminarOrden(orden),
                                          icon: const Icon(Icons.delete_outline),
                                          tooltip: 'Eliminar',
                                          color: Colors.red[400],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const CrearOrdenScreen(),
            ),
          );

          if (resultado == true) {
            _cargarOrdenes();
          }
        },
        tooltip: 'Nueva Orden',
        child: const Icon(Icons.add),
      ),
    );
  }
}