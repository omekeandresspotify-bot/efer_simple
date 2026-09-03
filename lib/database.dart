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
        'efer.db',
        options: OpenDatabaseOptions(
          version: 9,
          onCreate: _createDB,
          onUpgrade: _upgradeDB,
        ),
      );
    }

    final dbPath = await getDatabasesPath();

    final path = join(dbPath, 'efer.db');

    return await openDatabase(
      path,
      version: 9,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // ==========================================================
  // CREAR BASE DE DATOS NUEVA
  // ==========================================================

  Future<void> _createDB(Database db, int version) async {
    // --------------------------------------------------------
    // EMPRESAS
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE empresas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        rut TEXT,
        telefono TEXT,
        correo TEXT,
        direccion TEXT,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // --------------------------------------------------------
    // USUARIOS
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresaId INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        correo TEXT,
        rol TEXT NOT NULL DEFAULT 'VENDEDOR',
        activo INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (empresaId)
          REFERENCES empresas (id)
          ON DELETE CASCADE
      )
    ''');

    // --------------------------------------------------------
    // CLIENTES
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresaId INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        telefono TEXT,
        correo TEXT,
        direccion TEXT,
        fechaCreacion TEXT,
        activo INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (empresaId)
          REFERENCES empresas (id)
          ON DELETE CASCADE
      )
    ''');

    // --------------------------------------------------------
    // PRESUPUESTOS
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE presupuestos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresaId INTEGER NOT NULL,
        clienteId INTEGER,
        vendedorId INTEGER,
        numero INTEGER NOT NULL UNIQUE,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        nombreCliente TEXT NOT NULL,
        telefono TEXT,
        correo TEXT,
        direccion TEXT,
        color TEXT NOT NULL DEFAULT 'MATE',

        subtotalOriginal REAL NOT NULL DEFAULT 0,
        descuento REAL NOT NULL DEFAULT 0,
        descuentoTipo TEXT NOT NULL DEFAULT 'NINGUNO',

        subtotal REAL NOT NULL,
        iva REAL NOT NULL,
        total REAL NOT NULL,
        observacionesAdicionales TEXT NOT NULL DEFAULT '',

        aceptado INTEGER NOT NULL DEFAULT 0,
        estado TEXT NOT NULL DEFAULT 'PENDIENTE',

        FOREIGN KEY (empresaId)
          REFERENCES empresas (id)
          ON DELETE CASCADE,

        FOREIGN KEY (clienteId)
          REFERENCES clientes (id)
          ON DELETE SET NULL,

        FOREIGN KEY (vendedorId)
          REFERENCES usuarios (id)
          ON DELETE SET NULL
      )
    ''');

    // --------------------------------------------------------
    // PRODUCTOS DEL PRESUPUESTO
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE productos_presupuesto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        presupuestoId INTEGER NOT NULL,
        producto TEXT NOT NULL,
        ancho REAL NOT NULL,
        ancho2 REAL NOT NULL DEFAULT 0,
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

    // --------------------------------------------------------
    // TRABAJOS
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE trabajos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresaId INTEGER NOT NULL,
        presupuestoId INTEGER NOT NULL,
        clienteId INTEGER,
        estado TEXT NOT NULL DEFAULT 'PENDIENTE',
        fechaCreacion TEXT NOT NULL,
        notas TEXT,

        FOREIGN KEY (empresaId)
          REFERENCES empresas (id)
          ON DELETE CASCADE,

        FOREIGN KEY (presupuestoId)
          REFERENCES presupuestos (id)
          ON DELETE CASCADE,

        FOREIGN KEY (clienteId)
          REFERENCES clientes (id)
          ON DELETE SET NULL
      )
    ''');

    // --------------------------------------------------------
    // HISTORIAL DE ESTADOS DE TRABAJOS
    // --------------------------------------------------------

    await db.execute('''
  CREATE TABLE historial_estados_trabajo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trabajoId INTEGER NOT NULL,
    estado TEXT NOT NULL,
    fecha TEXT NOT NULL,

    FOREIGN KEY (trabajoId)
      REFERENCES trabajos (id)
      ON DELETE CASCADE
  )
''');

    // --------------------------------------------------------
    // INSTALACIONES
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE instalaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresaId INTEGER NOT NULL,
        trabajoId INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        responsable TEXT,
        estado TEXT NOT NULL DEFAULT 'PENDIENTE',
        notas TEXT,

        FOREIGN KEY (empresaId)
          REFERENCES empresas (id)
          ON DELETE CASCADE,

        FOREIGN KEY (trabajoId)
          REFERENCES trabajos (id)
          ON DELETE CASCADE
      )
    ''');

    // --------------------------------------------------------
    // PAGOS
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE pagos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresaId INTEGER NOT NULL,
        trabajoId INTEGER NOT NULL,
        monto REAL NOT NULL,
        fecha TEXT NOT NULL,
        metodo TEXT,
        estado TEXT NOT NULL DEFAULT 'PAGADO',
        notas TEXT,

        FOREIGN KEY (empresaId)
          REFERENCES empresas (id)
          ON DELETE CASCADE,

        FOREIGN KEY (trabajoId)
          REFERENCES trabajos (id)
          ON DELETE CASCADE
      )
    ''');

    // --------------------------------------------------------
    // FACTURACIÓN
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE facturas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresaId INTEGER NOT NULL,
        trabajoId INTEGER NOT NULL,
        numero TEXT,
        fecha TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'PENDIENTE',
        montoNeto REAL NOT NULL DEFAULT 0,
        iva REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL DEFAULT 0,
        notas TEXT,

        FOREIGN KEY (empresaId)
          REFERENCES empresas (id)
          ON DELETE CASCADE,

        FOREIGN KEY (trabajoId)
          REFERENCES trabajos (id)
          ON DELETE CASCADE
      )
    ''');

    // --------------------------------------------------------
    // PRECIOS POR M2
    // --------------------------------------------------------

    await db.execute('''
  CREATE TABLE precios_m2 (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    empresaId INTEGER NOT NULL,
    producto TEXT NOT NULL,
    precioM2 REAL NOT NULL DEFAULT 0,
    activo INTEGER NOT NULL DEFAULT 1,

    FOREIGN KEY (empresaId)
      REFERENCES empresas (id)
      ON DELETE CASCADE,

    UNIQUE (empresaId, producto)
  )
''');

    // --------------------------------------------------------
    // EMPRESA INICIAL
    // --------------------------------------------------------

    await db.insert('empresas', {'nombre': 'EFER', 'activo': 1});
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
          ancho2 REAL NOT NULL DEFAULT 0,
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
    // --------------------------------------------------------

    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE presupuestos
        ADD COLUMN color TEXT NOT NULL DEFAULT 'MATE'
      ''');
    }

    // --------------------------------------------------------
    // VERSION 4 → 5
    // ESTRUCTURA LUNIALES
    // --------------------------------------------------------

    if (oldVersion < 5) {
      // ======================================================
      // EMPRESAS
      // ======================================================

      await db.execute('''
        CREATE TABLE empresas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          rut TEXT,
          telefono TEXT,
          correo TEXT,
          direccion TEXT,
          activo INTEGER NOT NULL DEFAULT 1
        )
      ''');

      // Empresa inicial.
      await db.insert('empresas', {'nombre': 'EFER', 'activo': 1});

      // ======================================================
      // USUARIOS
      // ======================================================

      await db.execute('''
        CREATE TABLE usuarios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          empresaId INTEGER NOT NULL,
          nombre TEXT NOT NULL,
          correo TEXT,
          rol TEXT NOT NULL DEFAULT 'VENDEDOR',
          activo INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (empresaId)
            REFERENCES empresas (id)
            ON DELETE CASCADE
        )
      ''');

      // ======================================================
      // CLIENTES
      // ======================================================

      await db.execute('''
        CREATE TABLE clientes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          empresaId INTEGER NOT NULL,
          nombre TEXT NOT NULL,
          telefono TEXT,
          correo TEXT,
          direccion TEXT,
          fechaCreacion TEXT,
          activo INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (empresaId)
            REFERENCES empresas (id)
            ON DELETE CASCADE
        )
      ''');

      // ======================================================
      // NUEVOS CAMPOS PRESUPUESTOS
      // ======================================================

      await db.execute('''
        ALTER TABLE presupuestos
        ADD COLUMN empresaId INTEGER NOT NULL DEFAULT 1
      ''');

      await db.execute('''
        ALTER TABLE presupuestos
        ADD COLUMN clienteId INTEGER
      ''');

      await db.execute('''
        ALTER TABLE presupuestos
        ADD COLUMN vendedorId INTEGER
      ''');

      await db.execute('''
        ALTER TABLE presupuestos
        ADD COLUMN subtotalOriginal REAL NOT NULL DEFAULT 0
      ''');

      await db.execute('''
        ALTER TABLE presupuestos
        ADD COLUMN descuento REAL NOT NULL DEFAULT 0
      ''');

      await db.execute('''
        ALTER TABLE presupuestos
        ADD COLUMN descuentoTipo TEXT NOT NULL DEFAULT 'NINGUNO'
      ''');

      await db.execute('''
        ALTER TABLE presupuestos
        ADD COLUMN estado TEXT NOT NULL DEFAULT 'PENDIENTE'
      ''');

      // ======================================================
      // RESPALDAR SUBTOTAL ORIGINAL
      // ======================================================

      await db.execute('''
        UPDATE presupuestos
        SET subtotalOriginal = subtotal
        WHERE subtotalOriginal = 0
      ''');

      // ======================================================
      // ACTUALIZAR ESTADOS EXISTENTES
      // ======================================================

      await db.execute('''
        UPDATE presupuestos
        SET estado = 'ACEPTADO'
        WHERE aceptado = 1
      ''');

      // ======================================================
      // TRABAJOS
      // ======================================================

      await db.execute('''
        CREATE TABLE trabajos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          empresaId INTEGER NOT NULL,
          presupuestoId INTEGER NOT NULL,
          clienteId INTEGER,
          estado TEXT NOT NULL DEFAULT 'PENDIENTE',
          fechaCreacion TEXT NOT NULL,
          notas TEXT,
          FOREIGN KEY (empresaId)
            REFERENCES empresas (id)
            ON DELETE CASCADE,
          FOREIGN KEY (presupuestoId)
            REFERENCES presupuestos (id)
            ON DELETE CASCADE,
          FOREIGN KEY (clienteId)
            REFERENCES clientes (id)
            ON DELETE SET NULL
        )
      ''');

      // ======================================================
      // INSTALACIONES
      // ======================================================

      await db.execute('''
        CREATE TABLE instalaciones (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          empresaId INTEGER NOT NULL,
          trabajoId INTEGER NOT NULL,
          fecha TEXT NOT NULL,
          hora TEXT NOT NULL,
          responsable TEXT,
          estado TEXT NOT NULL DEFAULT 'PENDIENTE',
          notas TEXT,
          FOREIGN KEY (empresaId)
            REFERENCES empresas (id)
            ON DELETE CASCADE,
          FOREIGN KEY (trabajoId)
            REFERENCES trabajos (id)
            ON DELETE CASCADE
        )
      ''');

      // ======================================================
      // PAGOS
      // ======================================================

      await db.execute('''
        CREATE TABLE pagos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          empresaId INTEGER NOT NULL,
          trabajoId INTEGER NOT NULL,
          monto REAL NOT NULL,
          fecha TEXT NOT NULL,
          metodo TEXT,
          estado TEXT NOT NULL DEFAULT 'PAGADO',
          notas TEXT,
          FOREIGN KEY (empresaId)
            REFERENCES empresas (id)
            ON DELETE CASCADE,
          FOREIGN KEY (trabajoId)
            REFERENCES trabajos (id)
            ON DELETE CASCADE
        )
      ''');

      // ======================================================
      // FACTURACIÓN
      // ======================================================

      await db.execute('''
        CREATE TABLE facturas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          empresaId INTEGER NOT NULL,
          trabajoId INTEGER NOT NULL,
          numero TEXT,
          fecha TEXT NOT NULL,
          estado TEXT NOT NULL DEFAULT 'PENDIENTE',
          montoNeto REAL NOT NULL DEFAULT 0,
          iva REAL NOT NULL DEFAULT 0,
          total REAL NOT NULL DEFAULT 0,
          notas TEXT,
          FOREIGN KEY (empresaId)
            REFERENCES empresas (id)
            ON DELETE CASCADE,
          FOREIGN KEY (trabajoId)
            REFERENCES trabajos (id)
            ON DELETE CASCADE
        )
      ''');
    }

    // --------------------------------------------------------
    // VERSION 5 → 6
    // HISTORIAL DE ESTADOS DE TRABAJOS
    // --------------------------------------------------------

    if (oldVersion < 7) {
      await db.execute('''
    CREATE TABLE historial_estados_trabajo (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      trabajoId INTEGER NOT NULL,
      estado TEXT NOT NULL,
      fecha TEXT NOT NULL,

      FOREIGN KEY (trabajoId)
        REFERENCES trabajos (id)
        ON DELETE CASCADE
    )
  ''');

      // Registrar PENDIENTE para los trabajos existentes.
      final trabajosExistentes = await db.query(
        'trabajos',
        columns: ['id', 'fechaCreacion'],
      );

      for (final trabajo in trabajosExistentes) {
        await db.insert('historial_estados_trabajo', {
          'trabajoId': trabajo['id'],
          'estado': 'PENDIENTE',
          'fecha': trabajo['fechaCreacion'],
        });
      }
      // --------------------------------------------------------
      // VERSION 7 → 8
      // PRECIOS POR M2
      // --------------------------------------------------------

      if (oldVersion < 8) {
        await db.execute('''
    CREATE TABLE precios_m2 (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      empresaId INTEGER NOT NULL,
      producto TEXT NOT NULL,
      precioM2 REAL NOT NULL DEFAULT 0,
      activo INTEGER NOT NULL DEFAULT 1,

      FOREIGN KEY (empresaId)
        REFERENCES empresas (id)
        ON DELETE CASCADE,

      UNIQUE (empresaId, producto)
    )
  ''');
        // --------------------------------------------------------
        // PRECIOS INICIALES DE EFER
        // --------------------------------------------------------

        final preciosIniciales = <Map<String, dynamic>>[
          {'producto': 'Corredera 2 hojas 25 mono', 'precioM2': 90000},
          {'producto': 'Corredera 2 hojas 25 termo', 'precioM2': 130000},
          {'producto': 'Corredera 2 hojas 5000', 'precioM2': 80000},
          {'producto': 'Fija AL42 mono', 'precioM2': 45000},
          {'producto': 'Fija AL42 termo', 'precioM2': 75000},
          {'producto': 'Proyectante AL42 mono', 'precioM2': 70000},
          {'producto': 'Proyectante AL42 termo', 'precioM2': 95000},
          {'producto': 'Corredera 3 hojas 25 mono', 'precioM2': 90000},
          {'producto': 'Corredera 3 hojas 25 termo', 'precioM2': 130000},
          {'producto': 'Corredera 4 hojas 25 mono', 'precioM2': 100000},
          {'producto': 'Corredera 4 hojas 25 termo', 'precioM2': 140000},
          {'producto': 'Shower Door 2 hojas', 'precioM2': 150000},
          {'producto': 'Shower Door Esquinero', 'precioM2': 240000},
          {'producto': 'Shower Door 2 hojas con fijo', 'precioM2': 210000},
          {'producto': 'Puerta AM35', 'precioM2': 170000},
          {'producto': 'Puerta AM35 con placas', 'precioM2': 210000},
          {'producto': 'Vidrio 4 mm', 'precioM2': 25000},
          {'producto': 'Vidrio 5 mm', 'precioM2': 30000},
          {'producto': 'Termopanel', 'precioM2': 45000},
          {'producto': 'Espejo', 'precioM2': 35000},
          {'producto': 'Semilla', 'precioM2': 32000},
        ];

        for (final precio in preciosIniciales) {
          await db.insert('precios_m2', {
            'empresaId': 1,
            'producto': precio['producto'],
            'precioM2': precio['precioM2'],
            'activo': 1,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }

    // --------------------------------------------------------
    // VERSION 8 → 9
    // OBSERVACIONES ADICIONALES
    // --------------------------------------------------------

    if (oldVersion < 9) {
      await db.execute('''
        ALTER TABLE presupuestos
        ADD COLUMN observacionesAdicionales TEXT NOT NULL DEFAULT ''
      ''');
    }
  }

  // ==========================================================
  // TRABAJOS
  // ==========================================================

  // ----------------------------------------------------------
  // CREAR TRABAJO
  // ----------------------------------------------------------

  Future<int> crearTrabajo({
    required int presupuestoId,
    int? clienteId,
    String estado = 'PENDIENTE',
    String? notas,
  }) async {
    final db = await database;

    // --------------------------------------------------------
    // EVITAR TRABAJOS DUPLICADOS
    // --------------------------------------------------------

    final existente = await db.query(
      'trabajos',
      columns: ['id'],
      where: 'presupuestoId = ? AND empresaId = ?',
      whereArgs: [presupuestoId, 1],
      limit: 1,
    );

    if (existente.isNotEmpty) {
      return existente.first['id'] as int;
    }

    // --------------------------------------------------------
    // FECHA DE CREACIÓN
    // --------------------------------------------------------

    final ahora = DateTime.now().toIso8601String();

    // --------------------------------------------------------
    // CREAR TRABAJO + REGISTRAR PRIMER ESTADO
    // --------------------------------------------------------

    return await db.transaction((txn) async {
      final trabajoId = await txn.insert('trabajos', {
        'empresaId': 1,
        'presupuestoId': presupuestoId,
        'clienteId': clienteId,
        'estado': estado,
        'fechaCreacion': ahora,
        'notas': notas,
      });

      await txn.insert('historial_estados_trabajo', {
        'trabajoId': trabajoId,
        'estado': estado,
        'fecha': ahora,
      });

      return trabajoId;
    });
  }

  // ----------------------------------------------------------
  // OBTENER TODOS LOS TRABAJOS
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> obtenerTrabajos() async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT
      trabajos.*,
      clientes.nombre AS nombreCliente,
      presupuestos.numero AS numeroPresupuesto,
      presupuestos.total AS totalPresupuesto
    FROM trabajos
    LEFT JOIN clientes
      ON clientes.id = trabajos.clienteId
    INNER JOIN presupuestos
      ON presupuestos.id = trabajos.presupuestoId
    WHERE trabajos.empresaId = ?
    ORDER BY trabajos.id DESC
  ''',
      [1],
    );
  }

  // ----------------------------------------------------------
  // ACTUALIZAR ESTADO DEL TRABAJO
  // ----------------------------------------------------------

  Future<void> actualizarEstadoTrabajo({
    required int trabajoId,
    required String estado,
  }) async {
    final db = await database;

    final ahora = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.update(
        'trabajos',
        {'estado': estado},
        where: 'id = ? AND empresaId = ?',
        whereArgs: [trabajoId, 1],
      );

      await txn.insert('historial_estados_trabajo', {
        'trabajoId': trabajoId,
        'estado': estado,
        'fecha': ahora,
      });
    });
  }

  // ----------------------------------------------------------
  // OBTENER UN TRABAJO
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> obtenerTrabajo(int trabajoId) async {
    final db = await database;

    final resultado = await db.rawQuery(
      '''
    SELECT
      trabajos.*,
      clientes.nombre AS nombreCliente,
      clientes.telefono AS telefonoCliente,
      clientes.correo AS correoCliente,
      clientes.direccion AS direccionCliente,
      presupuestos.numero AS numeroPresupuesto,
      presupuestos.fecha AS fechaPresupuesto,
      presupuestos.total AS totalPresupuesto
    FROM trabajos
    LEFT JOIN clientes
      ON clientes.id = trabajos.clienteId
    INNER JOIN presupuestos
      ON presupuestos.id = trabajos.presupuestoId
    WHERE trabajos.id = ?
      AND trabajos.empresaId = ?
    LIMIT 1
  ''',
      [trabajoId, 1],
    );

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  // ==========================================================
  // HISTORIAL DE ESTADOS DEL TRABAJO
  // ==========================================================

  Future<List<Map<String, dynamic>>> obtenerHistorialEstados(
    int trabajoId,
  ) async {
    final db = await database;

    return await db.query(
      'historial_estados_trabajo',
      where: 'trabajoId = ?',
      whereArgs: [trabajoId],
      orderBy: 'id ASC',
    );
  }

  // ==========================================================
  // AGENDA / INSTALACIONES
  // ==========================================================

  // ----------------------------------------------------------
  // CREAR INSTALACIÓN
  // ----------------------------------------------------------

  Future<int> crearInstalacion({
    required int trabajoId,
    required String fecha,
    required String hora,
    String? responsable,
    String? notas,
  }) async {
    final db = await database;

    final ahora = DateTime.now().toIso8601String();

    return await db.transaction((txn) async {
      final instalacionId = await txn.insert('instalaciones', {
        'empresaId': 1,
        'trabajoId': trabajoId,
        'fecha': fecha,
        'hora': hora,
        'responsable': responsable,
        'estado': 'PENDIENTE',
        'notas': notas,
      });

      // ------------------------------------------------------
      // CAMBIAR EL TRABAJO A INSTALACIÓN PROGRAMADA
      // ------------------------------------------------------

      await txn.update(
        'trabajos',
        {'estado': 'INSTALACIÓN PROGRAMADA'},
        where: 'id = ? AND empresaId = ?',
        whereArgs: [trabajoId, 1],
      );

      // ------------------------------------------------------
      // REGISTRAR EL CAMBIO EN EL HISTORIAL
      // ------------------------------------------------------

      await txn.insert('historial_estados_trabajo', {
        'trabajoId': trabajoId,
        'estado': 'INSTALACIÓN PROGRAMADA',
        'fecha': ahora,
      });

      return instalacionId;
    });
  }

  // ----------------------------------------------------------
  // OBTENER TODAS LAS INSTALACIONES
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> obtenerInstalaciones() async {
    final db = await database;

    return await db.rawQuery(
      '''
      SELECT
        instalaciones.*,

        trabajos.presupuestoId,

        clientes.nombre AS nombreCliente,
        clientes.telefono AS telefonoCliente,
        clientes.correo AS correoCliente,
        clientes.direccion AS direccionCliente,

        presupuestos.numero AS numeroPresupuesto,
        presupuestos.total AS totalPresupuesto

      FROM instalaciones

      INNER JOIN trabajos
        ON trabajos.id = instalaciones.trabajoId

      LEFT JOIN clientes
        ON clientes.id = trabajos.clienteId

      INNER JOIN presupuestos
        ON presupuestos.id = trabajos.presupuestoId

      WHERE instalaciones.empresaId = ?

      ORDER BY
        instalaciones.fecha ASC,
        instalaciones.hora ASC
      ''',
      [1],
    );
  }

  // ----------------------------------------------------------
  // OBTENER INSTALACIONES DE UNA FECHA
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> obtenerInstalacionesPorFecha(
    String fecha,
  ) async {
    final db = await database;

    return await db.rawQuery(
      '''
      SELECT
        instalaciones.*,

        trabajos.presupuestoId,

        clientes.nombre AS nombreCliente,
        clientes.telefono AS telefonoCliente,
        clientes.correo AS correoCliente,
        clientes.direccion AS direccionCliente,

        presupuestos.numero AS numeroPresupuesto,
        presupuestos.total AS totalPresupuesto

      FROM instalaciones

      INNER JOIN trabajos
        ON trabajos.id = instalaciones.trabajoId

      LEFT JOIN clientes
        ON clientes.id = trabajos.clienteId

      INNER JOIN presupuestos
        ON presupuestos.id = trabajos.presupuestoId

      WHERE instalaciones.empresaId = ?
        AND instalaciones.fecha = ?

      ORDER BY instalaciones.hora ASC
      ''',
      [1, fecha],
    );
  }

  // ----------------------------------------------------------
  // OBTENER UNA INSTALACIÓN
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> obtenerInstalacion(int instalacionId) async {
    final db = await database;

    final resultado = await db.rawQuery(
      '''
      SELECT
        instalaciones.*,

        trabajos.presupuestoId,

        clientes.nombre AS nombreCliente,
        clientes.telefono AS telefonoCliente,
        clientes.correo AS correoCliente,
        clientes.direccion AS direccionCliente,

        presupuestos.numero AS numeroPresupuesto,
        presupuestos.total AS totalPresupuesto

      FROM instalaciones

      INNER JOIN trabajos
        ON trabajos.id = instalaciones.trabajoId

      LEFT JOIN clientes
        ON clientes.id = trabajos.clienteId

      INNER JOIN presupuestos
        ON presupuestos.id = trabajos.presupuestoId

      WHERE instalaciones.id = ?
        AND instalaciones.empresaId = ?

      LIMIT 1
      ''',
      [instalacionId, 1],
    );

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  // ----------------------------------------------------------
  // EDITAR INSTALACIÓN
  // ----------------------------------------------------------

  Future<void> actualizarInstalacion({
    required int instalacionId,
    required String fecha,
    required String hora,
    String? responsable,
    String? notas,
  }) async {
    final db = await database;

    await db.update(
      'instalaciones',
      {
        'fecha': fecha,
        'hora': hora,
        'responsable': responsable,
        'notas': notas,
      },
      where: 'id = ? AND empresaId = ?',
      whereArgs: [instalacionId, 1],
    );
  }

  // ----------------------------------------------------------
  // MARCAR INSTALACIÓN COMO COMPLETADA
  // ----------------------------------------------------------

  Future<void> completarInstalacion(int instalacionId) async {
    final db = await database;

    await db.transaction((txn) async {
      final resultado = await txn.query(
        'instalaciones',
        columns: ['trabajoId'],
        where: 'id = ? AND empresaId = ?',
        whereArgs: [instalacionId, 1],
        limit: 1,
      );

      if (resultado.isEmpty) {
        return;
      }

      final trabajoId = resultado.first['trabajoId'] as int;

      final ahora = DateTime.now().toIso8601String();

      await txn.update(
        'instalaciones',
        {'estado': 'COMPLETADA'},
        where: 'id = ? AND empresaId = ?',
        whereArgs: [instalacionId, 1],
      );

      // ------------------------------------------------------
      // EL TRABAJO PASA A FINALIZADO
      // ------------------------------------------------------

      await txn.update(
        'trabajos',
        {'estado': 'FINALIZADO'},
        where: 'id = ? AND empresaId = ?',
        whereArgs: [trabajoId, 1],
      );

      // ------------------------------------------------------
      // REGISTRAR EN HISTORIAL
      // ------------------------------------------------------

      await txn.insert('historial_estados_trabajo', {
        'trabajoId': trabajoId,
        'estado': 'FINALIZADO',
        'fecha': ahora,
      });
    });
  }

  // ----------------------------------------------------------
  // ELIMINAR INSTALACIÓN
  // ----------------------------------------------------------

  Future<void> eliminarInstalacion(int instalacionId) async {
    final db = await database;

    await db.delete(
      'instalaciones',
      where: 'id = ? AND empresaId = ?',
      whereArgs: [instalacionId, 1],
    );
  }

  // ==========================================================
  // CLIENTES
  // ==========================================================

  // ----------------------------------------------------------
  // CREAR CLIENTE
  // ----------------------------------------------------------

  Future<int> crearCliente({
    required String nombre,
    String? telefono,
    String? correo,
    String? direccion,
  }) async {
    final db = await database;

    return await db.insert('clientes', {
      'empresaId': 1,
      'nombre': nombre.trim(),
      'telefono': telefono?.trim(),
      'correo': correo?.trim(),
      'direccion': direccion?.trim(),
      'fechaCreacion': DateTime.now().toIso8601String(),
      'activo': 1,
    });
  }

  // ----------------------------------------------------------
  // OBTENER TODOS LOS CLIENTES
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> obtenerClientes() async {
    final db = await database;

    return await db.query(
      'clientes',
      where: 'empresaId = ? AND activo = ?',
      whereArgs: [1, 1],
      orderBy: 'nombre ASC',
    );
  }

  // ----------------------------------------------------------
  // BUSCAR CLIENTES
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> buscarClientes(String texto) async {
    final db = await database;

    final busqueda = '%${texto.trim()}%';

    return await db.query(
      'clientes',
      where: '''
        empresaId = ?
        AND activo = ?
        AND (
          nombre LIKE ?
          OR telefono LIKE ?
          OR correo LIKE ?
        )
      ''',
      whereArgs: [1, 1, busqueda, busqueda, busqueda],
      orderBy: 'nombre ASC',
    );
  }

  // ----------------------------------------------------------
  // OBTENER UN CLIENTE
  // ----------------------------------------------------------

  Future<Map<String, dynamic>?> obtenerCliente(int clienteId) async {
    final db = await database;

    final resultado = await db.query(
      'clientes',
      where: 'id = ? AND empresaId = ?',
      whereArgs: [clienteId, 1],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  // ----------------------------------------------------------
  // EDITAR CLIENTE
  // ----------------------------------------------------------

  Future<void> actualizarCliente({
    required int clienteId,
    required String nombre,
    String? telefono,
    String? correo,
    String? direccion,
  }) async {
    final db = await database;

    await db.update(
      'clientes',
      {
        'nombre': nombre.trim(),
        'telefono': telefono?.trim(),
        'correo': correo?.trim(),
        'direccion': direccion?.trim(),
      },
      where: 'id = ? AND empresaId = ?',
      whereArgs: [clienteId, 1],
    );
  }

  // ----------------------------------------------------------
  // DESACTIVAR CLIENTE
  // ----------------------------------------------------------

  Future<void> eliminarCliente(int clienteId) async {
    final db = await database;

    // No eliminamos físicamente el cliente.
    // Lo desactivamos para conservar su historial.
    await db.update(
      'clientes',
      {'activo': 0},
      where: 'id = ? AND empresaId = ?',
      whereArgs: [clienteId, 1],
    );
  }

  // ----------------------------------------------------------
  // VENTAS DEL CLIENTE
  // ----------------------------------------------------------

  Future<double> totalVentasCliente(int clienteId) async {
    final db = await database;

    final resultado = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total), 0) AS totalVentas
      FROM presupuestos
      WHERE clienteId = ?
        AND empresaId = ?
        AND aceptado = 1
      ''',
      [clienteId, 1],
    );

    final valor = resultado.first['totalVentas'];

    if (valor is num) {
      return valor.toDouble();
    }

    return 0;
  }

  // ----------------------------------------------------------
  // CANTIDAD DE VENTAS DEL CLIENTE
  // ----------------------------------------------------------

  Future<int> cantidadVentasCliente(int clienteId) async {
    final db = await database;

    final resultado = await db.rawQuery(
      '''
      SELECT COUNT(*) AS cantidad
      FROM presupuestos
      WHERE clienteId = ?
        AND empresaId = ?
        AND aceptado = 1
      ''',
      [clienteId, 1],
    );

    final valor = resultado.first['cantidad'];

    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.toInt();
    }

    return 0;
  }

  // ----------------------------------------------------------
  // PRESUPUESTOS DEL CLIENTE
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> obtenerPresupuestosCliente(
    int clienteId,
  ) async {
    final db = await database;

    return await db.query(
      'presupuestos',
      where: 'clienteId = ? AND empresaId = ?',
      whereArgs: [clienteId, 1],
      orderBy: 'numero DESC',
    );
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
    int? clienteId,
    String? telefono,
    String? correo,
    String? direccion,
    required String color,
    required double subtotal,
    required double descuento,
    required String descuentoTipo,
    required double neto,
    required bool aplicarIva,
    required double iva,
    required double total,
    required String observacionesAdicionales,
    required List<Map<String, dynamic>> productos,
  }) async {
    final db = await database;

    return await db.transaction((txn) async {
      final presupuestoId = await txn.insert('presupuestos', {
        'empresaId': 1,
        'clienteId': clienteId,
        'vendedorId': null,
        'numero': numero,
        'fecha': fecha,
        'hora': hora,
        'nombreCliente': nombreCliente,
        'telefono': telefono,
        'correo': correo,
        'direccion': direccion,
        'color': color,

        'subtotalOriginal': subtotal,
        'descuento': descuento,
        'descuentoTipo': descuentoTipo,

        'subtotal': neto,
        'iva': aplicarIva ? iva : 0,
        'total': total,
        'observacionesAdicionales': observacionesAdicionales,

        'aceptado': 0,
        'estado': 'PENDIENTE',
      });

      for (final producto in productos) {
        await txn.insert('productos_presupuesto', {
          'presupuestoId': presupuestoId,
          'producto': producto['producto'],
          'ancho': producto['ancho'],
          'ancho2': producto['ancho2'],
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
      {'aceptado': 1, 'estado': 'ACEPTADO'},
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
      {'aceptado': 0, 'estado': 'PENDIENTE'},
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
  // OBTENER UN PRESUPUESTO POR ID
  // ==========================================================

  Future<Map<String, dynamic>?> obtenerPresupuestoPorId(int id) async {
    final db = await database;
    final resultado = await db.query(
      'presupuestos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return resultado.isEmpty ? null : resultado.first;
  }

  // ==========================================================
  // ACTUALIZAR PRESUPUESTO COMPLETO
  // ==========================================================

  Future<void> actualizarPresupuestoCompleto({
    required int presupuestoId,
    required int numero,
    required String fecha,
    required String hora,
    required String nombreCliente,
    int? clienteId,
    String? telefono,
    String? correo,
    String? direccion,
    required String color,
    required double subtotal,
    required double descuento,
    required String descuentoTipo,
    required double neto,
    required bool aplicarIva,
    required double iva,
    required double total,
    required String observacionesAdicionales,
    required List<Map<String, dynamic>> productos,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'presupuestos',
        {
          'clienteId': clienteId,
          'numero': numero,
          'fecha': fecha,
          'hora': hora,
          'nombreCliente': nombreCliente,
          'telefono': telefono,
          'correo': correo,
          'direccion': direccion,
          'color': color,
          'subtotalOriginal': subtotal,
          'descuento': descuento,
          'descuentoTipo': descuentoTipo,
          'subtotal': neto,
          'iva': aplicarIva ? iva : 0,
          'total': total,
          'observacionesAdicionales': observacionesAdicionales,
        },
        where: 'id = ?',
        whereArgs: [presupuestoId],
      );

      await txn.delete(
        'productos_presupuesto',
        where: 'presupuestoId = ?',
        whereArgs: [presupuestoId],
      );

      for (final producto in productos) {
        await txn.insert('productos_presupuesto', {
          'presupuestoId': presupuestoId,
          'producto': producto['producto'],
          'ancho': producto['ancho'],
          'ancho2': producto['ancho2'],
          'alto': producto['alto'],
          'cantidad': producto['cantidad'],
          'metrosCuadrados': producto['metrosCuadrados'],
          'precioM2': producto['precioM2'],
          'total': producto['total'],
        });
      }
    });
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
  // PRECIOS POR M2
  // ==========================================================

  Future<List<Map<String, dynamic>>> obtenerPreciosM2() async {
    final db = await database;

    return await db.query(
      'precios_m2',
      where: 'empresaId = ? AND activo = ?',
      whereArgs: [1, 1],
      orderBy: 'producto ASC',
    );
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
