import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/plato.dart';
import '../models/orden.dart';

class CrearOrdenScreen extends StatefulWidget {
  const CrearOrdenScreen({super.key});

  @override
  State<CrearOrdenScreen> createState() => _CrearOrdenScreenState();
}

class _CrearOrdenScreenState extends State<CrearOrdenScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Plato> _platos = [];
  Map<int, int> _platosSeleccionados = {};
  bool _isLoading = true;
  bool _isGuardando = false;

  @override
  void initState() {
    super.initState();
    _cargarPlatos();
  }

  Future<void> _cargarPlatos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final platos = await _databaseHelper.getAllPlatos();
      setState(() {
        _platos = platos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar platos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _agregarPlato(Plato plato) {
    setState(() {
      _platosSeleccionados[plato.id!] = (_platosSeleccionados[plato.id!] ?? 0) + 1;
    });
  }

  void _quitarPlato(Plato plato) {
    setState(() {
      final cantidad = _platosSeleccionados[plato.id!] ?? 0;
      if (cantidad > 1) {
        _platosSeleccionados[plato.id!] = cantidad - 1;
      } else {
        _platosSeleccionados.remove(plato.id!);
      }
    });
  }

  double _calcularTotal() {
    double total = 0;
    for (final plato in _platos) {
      final cantidad = _platosSeleccionados[plato.id!] ?? 0;
      total += plato.precio * cantidad;
    }
    return total;
  }

  int get _totalPlatos {
    return _platosSeleccionados.values.fold(0, (sum, cantidad) => sum + cantidad);
  }

  Future<void> _crearOrden() async {
    if (_platosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un plato para crear la orden'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGuardando = true;
    });

    try {
      final List<PlatoOrden> platosOrden = [];

      for (final plato in _platos) {
        final cantidad = _platosSeleccionados[plato.id!];
        if (cantidad != null && cantidad > 0) {
          platosOrden.add(
            PlatoOrden(
              ordenId: 0,
              platoId: plato.id!,
              nombre: plato.nombre,
              precio: plato.precio,
              cantidad: cantidad,
            ),
          );
        }
      }

      final orden = Orden(
        total: _calcularTotal(),
        platos: platosOrden,
      );

      await _databaseHelper.insertOrden(orden);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orden creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear orden: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGuardando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _calcularTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Orden'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_totalPlatos > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platos seleccionados: $_totalPlatos',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Total: \$${total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _isGuardando ? null : _crearOrden,
                    icon: _isGuardando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.shopping_cart),
                    label: Text(_isGuardando ? 'Creando...' : 'Crear Orden'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _platos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay platos disponibles',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Primero debes agregar platos en la sección de Platos',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _platos.length,
                        itemBuilder: (context, index) {
                          final plato = _platos[index];
                          final cantidad = _platosSeleccionados[plato.id!] ?? 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.restaurant_menu,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plato.nombre,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${plato.precio.toStringAsFixed(2)}',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (cantidad > 0) ...[
                                    IconButton(
                                      onPressed: () => _quitarPlato(plato),
                                      icon: const Icon(Icons.remove_circle_outline),
                                      color: Colors.red[400],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        cantidad.toString(),
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                  IconButton(
                                    onPressed: () => _agregarPlato(plato),
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}