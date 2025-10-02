import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../database/database_helper.dart';
import 'agregar_usuario_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Usuario> _usuarios = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final usuarios = await _databaseHelper.getAllUsuarios();
    setState(() {
      _usuarios = usuarios;
    });
  }

  Future<void> _buscarUsuarios(String query) async {
    if (query.isEmpty) {
      _cargarUsuarios();
    } else {
      final usuarios = await _databaseHelper.searchUsuarios(query);
      setState(() {
        _usuarios = usuarios;
      });
    }
  }

  Future<void> _eliminarUsuario(int id) async {
    await _databaseHelper.deleteUsuario(id);
    _cargarUsuarios();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado')),
      );
    }
  }

  void _mostrarDialogoEliminar(Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar a ${usuario.nombre}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarUsuario(usuario.id!);
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _buscarUsuarios,
              decoration: const InputDecoration(
                hintText: 'Buscar usuarios...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _usuarios.isEmpty
                ? const Center(
                    child: Text(
                      'No hay usuarios registrados',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: _usuarios.length,
                    itemBuilder: (context, index) {
                      final usuario = _usuarios[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(usuario.nombre[0].toUpperCase()),
                          ),
                          title: Text(usuario.nombre),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(usuario.email),
                              const SizedBox(height: 4),
                              Text(
                                'Registrado: ${usuario.fechaCreacion.day}/${usuario.fechaCreacion.month}/${usuario.fechaCreacion.year}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              if (value == 'editar') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AgregarUsuarioScreen(usuario: usuario),
                                  ),
                                ).then((_) => _cargarUsuarios());
                              } else if (value == 'eliminar') {
                                _mostrarDialogoEliminar(usuario);
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(
                                value: 'editar',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Editar'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'eliminar',
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Eliminar'),
                                ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarUsuarioScreen(),
            ),
          ).then((_) => _cargarUsuarios());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}