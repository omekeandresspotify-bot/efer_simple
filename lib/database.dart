import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class EferDatabase {
  static final EferDatabase instance = EferDatabase._init();

  static Database? _database;

  EferDatabase._init();

  // ==========================================================
  // BASE DE DATOS
  // ==========================================================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB();

    return _database!;
  }

  // ==========================================================
  // ABRIR / CREAR BASE
  // ==========================================================

  Future<Database> _initDB() async {
    if (kIsWeb) {
      return await databaseFactoryFfiWeb.openDatabase(
        'efer_persistente.db',
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: _createDB,
          onUpgrade: _upgradeDB,
        ),
      );
    }

    final dbPath = await getDatabasesPath();

    final path = join(dbPath, 'efer.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // ==========================================================
  // CREAR BASE DE DATOS
  // ==========================================================

  Future<void> _createDB(Database db, int version) async {
    // --------------------------------------------------------
    // PRESUPUESTOS
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE presupuestos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero INTEGER NOT NULL UNIQUE,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        nombreCliente TEXT NOT NULL,
        telefono TEXT,
        correo TEXT,
        direccion TEXT,
        color TEXT NOT NULL DEFAULT 'MATE',
        subtotal REAL NOT NULL,
        iva REAL NOT NULL,
        total REAL NOT NULL,
        aceptado INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // --------------------------------------------------------
    // PRODUCTOS
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE productos_presupuesto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        presupuestoId INTEGER NOT NULL,
        producto TEXT NOT NULL,
        ancho REAL NOT NULL,
        alto REAL NOT NULL,
        cantidad REAL NOT NULL,
        metrosCuadrados REAL NOT NULL,
        precioM2 REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (presupuestoId)
          REFERENCES presupuestos (id)
          ON DELETE CASCADE
      )
    ''');
  }

  // ==========================================================
  // ACTUALIZAR BASE EXISTENTE
  // ==========================================================

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // --------------------------------------------------------
    // VERSION 1 → 2
    // --------------------------------------------------------

    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE productos_presupuesto (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          presupuestoId INTEGER NOT NULL,
          producto TEXT NOT NULL,
          ancho REAL NOT NULL,
          alto REAL NOT NULL,
          cantidad REAL NOT NULL,
          metrosCuadrados REAL NOT NULL,
          precioM2 REAL NOT NULL,
          total REAL NOT NULL,
          FOREIGN KEY (presupuestoId)
            REFERENCES presupuestos (id)
            ON DELETE CASCADE
        )
      ''');
    }

    // --------------------------------------------------------
    // VERSION 2 → 3
    // --------------------------------------------------------

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE presupuestos
        ADD COLUMN aceptado INTEGER NOT NULL DEFAULT 0
      ''');
    }

    // --------------------------------------------------------
    // VERSION 3 → 4
    // Agregar color general del presupuesto
    // --------------------------------------------------------

    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE presupuestos
        ADD COLUMN color TEXT NOT NULL DEFAULT 'MATE'
      ''');
    }
  }

  // ==========================================================
  // SIGUIENTE NUMERO
  // ==========================================================

  Future<int> obtenerSiguienteNumero() async {
    final db = await database;

    final resultado = await db.rawQuery(
      'SELECT MAX(numero) as maximo FROM presupuestos',
    );

    final maximo = resultado.first['maximo'] as int?;

    if (maximo == null || maximo < 905) {
      return 905;
    }

    return maximo + 1;
  }

  // ==========================================================
  // GUARDAR PRESUPUESTO COMPLETO
  // ==========================================================

  Future<int> guardarPresupuestoCompleto({
    required int numero,
    required String fecha,
    required String hora,
    required String nombreCliente,
    String? telefono,
    String? correo,
    String? direccion,
    required String color,
    required double subtotal,
    required double iva,
    required double total,
    required List<Map<String, dynamic>> productos,
  }) async {
    final db = await database;

    return await db.transaction((txn) async {
      final presupuestoId = await txn.insert('presupuestos', {
        'numero': numero,
        'fecha': fecha,
        'hora': hora,
        'nombreCliente': nombreCliente,
        'telefono': telefono,
        'correo': correo,
        'direccion': direccion,
        'color': color,
        'subtotal': subtotal,
        'iva': iva,
        'total': total,
        'aceptado': 0,
      });

      for (final producto in productos) {
        await txn.insert('productos_presupuesto', {
          'presupuestoId': presupuestoId,
          'producto': producto['producto'],
          'ancho': producto['ancho'],
          'alto': producto['alto'],
          'cantidad': producto['cantidad'],
          'metrosCuadrados': producto['metrosCuadrados'],
          'precioM2': producto['precioM2'],
          'total': producto['total'],
        });
      }

      return presupuestoId;
    });
  }

  // ==========================================================
  // OBTENER HISTORIAL
  // ==========================================================

  Future<List<Map<String, dynamic>>> obtenerPresupuestos() async {
    final db = await database;

    return await db.query('presupuestos', orderBy: 'numero DESC');
  }

  // ==========================================================
  // MARCAR ACEPTADO
  // ==========================================================

  Future<void> marcarAceptado(int numero) async {
    final db = await database;

    await db.update(
      'presupuestos',
      {'aceptado': 1},
      where: 'numero = ?',
      whereArgs: [numero],
    );
  }

  // ==========================================================
  // MARCAR PENDIENTE
  // ==========================================================

  Future<void> marcarPendiente(int numero) async {
    final db = await database;

    await db.update(
      'presupuestos',
      {'aceptado': 0},
      where: 'numero = ?',
      whereArgs: [numero],
    );
  }

  // ==========================================================
  // ESTADO
  // ==========================================================

  Future<bool> estaAceptado(int numero) async {
    final presupuesto = await obtenerPresupuesto(numero);

    if (presupuesto == null) {
      return false;
    }

    return (presupuesto['aceptado'] ?? 0) == 1;
  }

  // ==========================================================
  // OBTENER UN PRESUPUESTO
  // ==========================================================

  Future<Map<String, dynamic>?> obtenerPresupuesto(int numero) async {
    final db = await database;

    final resultado = await db.query(
      'presupuestos',
      where: 'numero = ?',
      whereArgs: [numero],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  // ==========================================================
  // OBTENER PRODUCTOS
  // ==========================================================

  Future<List<Map<String, dynamic>>> obtenerProductos(int presupuestoId) async {
    final db = await database;

    return await db.query(
      'productos_presupuesto',
      where: 'presupuestoId = ?',
      whereArgs: [presupuestoId],
      orderBy: 'id ASC',
    );
  }

  // ==========================================================
  // ELIMINAR PRESUPUESTO
  // ==========================================================

  Future<void> eliminarPresupuesto(int numero) async {
    final db = await database;

    await db.delete('presupuestos', where: 'numero = ?', whereArgs: [numero]);
  }

  // ==========================================================
  // CERRAR BASE
  // ==========================================================

  Future<void> cerrar() async {
    if (_database == null) {
      return;
    }

    await _database!.close();

    _database = null;
  }
}
