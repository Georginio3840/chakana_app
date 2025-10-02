import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/usuario.dart';
import '../models/plato.dart';
import '../models/orden.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'restaurante.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        fecha_creacion INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE platos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        fecha_creacion INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ordenes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha_creacion INTEGER NOT NULL,
        estado INTEGER NOT NULL DEFAULT 0,
        total REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE orden_platos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orden_id INTEGER NOT NULL,
        plato_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        cantidad INTEGER NOT NULL,
        FOREIGN KEY (orden_id) REFERENCES ordenes (id) ON DELETE CASCADE,
        FOREIGN KEY (plato_id) REFERENCES platos (id)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE platos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          precio REAL NOT NULL,
          fecha_creacion INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE ordenes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fecha_creacion INTEGER NOT NULL,
          estado INTEGER NOT NULL DEFAULT 0,
          total REAL NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE orden_platos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          orden_id INTEGER NOT NULL,
          plato_id INTEGER NOT NULL,
          nombre TEXT NOT NULL,
          precio REAL NOT NULL,
          cantidad INTEGER NOT NULL,
          FOREIGN KEY (orden_id) REFERENCES ordenes (id) ON DELETE CASCADE,
          FOREIGN KEY (plato_id) REFERENCES platos (id)
        )
      ''');
    }
  }

  Future<int> insertUsuario(Usuario usuario) async {
    final db = await database;
    return await db.insert('usuarios', usuario.toMap());
  }

  Future<List<Usuario>> getAllUsuarios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('usuarios');

    return List.generate(maps.length, (i) {
      return Usuario.fromMap(maps[i]);
    });
  }

  Future<Usuario?> getUsuario(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUsuario(Usuario usuario) async {
    final db = await database;
    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<int> deleteUsuario(int id) async {
    final db = await database;
    return await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Usuario>> searchUsuarios(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'nombre LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Usuario.fromMap(maps[i]);
    });
  }

  Future close() async {
    final db = await database;
    db.close();
  }

  // MÉTODOS PARA PLATOS
  Future<int> insertPlato(Plato plato) async {
    final db = await database;
    return await db.insert('platos', plato.toMap());
  }

  Future<List<Plato>> getAllPlatos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('platos');

    return List.generate(maps.length, (i) {
      return Plato.fromMap(maps[i]);
    });
  }

  Future<Plato?> getPlato(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'platos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Plato.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePlato(Plato plato) async {
    final db = await database;
    return await db.update(
      'platos',
      plato.toMap(),
      where: 'id = ?',
      whereArgs: [plato.id],
    );
  }

  Future<int> deletePlato(int id) async {
    final db = await database;
    return await db.delete(
      'platos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Plato>> searchPlatos(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'platos',
      where: 'nombre LIKE ?',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Plato.fromMap(maps[i]);
    });
  }

  // MÉTODOS PARA ÓRDENES
  Future<int> insertOrden(Orden orden) async {
    final db = await database;

    return await db.transaction((txn) async {
      int ordenId = await txn.insert('ordenes', orden.toMap());

      for (PlatoOrden platoOrden in orden.platos) {
        await txn.insert('orden_platos', platoOrden.copyWith(ordenId: ordenId).toMap());
      }

      return ordenId;
    });
  }

  Future<List<Orden>> getAllOrdenes() async {
    final db = await database;
    final List<Map<String, dynamic>> ordenMaps = await db.query('ordenes', orderBy: 'fecha_creacion DESC');

    List<Orden> ordenes = [];
    for (Map<String, dynamic> ordenMap in ordenMaps) {
      final List<Map<String, dynamic>> platoMaps = await db.query(
        'orden_platos',
        where: 'orden_id = ?',
        whereArgs: [ordenMap['id']],
      );

      List<PlatoOrden> platos = platoMaps.map((map) => PlatoOrden.fromMap(map)).toList();
      ordenes.add(Orden.fromMap(ordenMap, platos));
    }

    return ordenes;
  }

  Future<Orden?> getOrden(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> ordenMaps = await db.query(
      'ordenes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (ordenMaps.isNotEmpty) {
      final List<Map<String, dynamic>> platoMaps = await db.query(
        'orden_platos',
        where: 'orden_id = ?',
        whereArgs: [id],
      );

      List<PlatoOrden> platos = platoMaps.map((map) => PlatoOrden.fromMap(map)).toList();
      return Orden.fromMap(ordenMaps.first, platos);
    }
    return null;
  }

  Future<int> updateOrden(Orden orden) async {
    final db = await database;

    return await db.transaction((txn) async {
      int result = await txn.update(
        'ordenes',
        orden.toMap(),
        where: 'id = ?',
        whereArgs: [orden.id],
      );

      await txn.delete('orden_platos', where: 'orden_id = ?', whereArgs: [orden.id]);

      for (PlatoOrden platoOrden in orden.platos) {
        await txn.insert('orden_platos', platoOrden.toMap());
      }

      return result;
    });
  }

  Future<int> updateEstadoOrden(int ordenId, EstadoOrden estado) async {
    final db = await database;
    return await db.update(
      'ordenes',
      {'estado': estado.index},
      where: 'id = ?',
      whereArgs: [ordenId],
    );
  }

  Future<int> deleteOrden(int id) async {
    final db = await database;
    return await db.delete(
      'ordenes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}