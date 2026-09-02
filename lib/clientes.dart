import 'package:flutter/material.dart';

import 'database.dart';

import 'presupuesto_imagen.dart';

// ============================================================
// CLIENTES - LUNIALES
// ============================================================

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  List<Map<String, dynamic>> clientes = [];

  bool cargando = true;

  final buscadorController = TextEditingController();

  @override
  void initState() {
    super.initState();

    cargarClientes();
  }

  @override
  void dispose() {
    buscadorController.dispose();

    super.dispose();
  }

  // ==========================================================
  // CARGAR CLIENTES
  // ==========================================================

  Future<void> cargarClientes() async {
    setState(() {
      cargando = true;
    });

    final texto = buscadorController.text.trim();

    final resultado = texto.isEmpty
        ? await EferDatabase.instance.obtenerClientes()
        : await EferDatabase.instance.buscarClientes(texto);

    if (!mounted) {
      return;
    }

    setState(() {
      clientes = resultado;
      cargando = false;
    });
  }

  // ==========================================================
  // FORMATO DINERO
  // ==========================================================

  String dinero(double valor) {
    return '\$${valor.toStringAsFixed(0)}'.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );
  }

  // ==========================================================
  // NUEVO CLIENTE
  // ==========================================================

  Future<void> nuevoCliente() async {
    final resultado = await mostrarFormularioCliente();

    if (resultado == null) {
      return;
    }

    await EferDatabase.instance.crearCliente(
      nombre: resultado['nombre']!,
      telefono: resultado['telefono'],
      correo: resultado['correo'],
      direccion: resultado['direccion'],
    );

    await cargarClientes();
  }

  // ==========================================================
  // EDITAR CLIENTE
  // ==========================================================

  Future<void> editarCliente(Map<String, dynamic> cliente) async {
    final resultado = await mostrarFormularioCliente(cliente: cliente);

    if (resultado == null) {
      return;
    }

    await EferDatabase.instance.actualizarCliente(
      clienteId: cliente['id'] as int,
      nombre: resultado['nombre']!,
      telefono: resultado['telefono'],
      correo: resultado['correo'],
      direccion: resultado['direccion'],
    );

    await cargarClientes();
  }

  // ==========================================================
  // DESACTIVAR CLIENTE
  // ==========================================================

  Future<void> desactivarCliente(Map<String, dynamic> cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Desactivar cliente'),

          content: Text(
            '¿Quieres desactivar a ${cliente['nombre']}?\n\n'
            'Su historial de presupuestos se conservará.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('CANCELAR'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('DESACTIVAR'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await EferDatabase.instance.eliminarCliente(cliente['id'] as int);

    await cargarClientes();
  }

  // ==========================================================
  // FORMULARIO CLIENTE
  // ==========================================================

  Future<Map<String, String>?> mostrarFormularioCliente({
    Map<String, dynamic>? cliente,
  }) async {
    final nombreController = TextEditingController(
      text: cliente?['nombre']?.toString() ?? '',
    );

    final telefonoController = TextEditingController(
      text: cliente?['telefono']?.toString() ?? '',
    );

    final correoController = TextEditingController(
      text: cliente?['correo']?.toString() ?? '',
    );

    final direccionController = TextEditingController(
      text: cliente?['direccion']?.toString() ?? '',
    );

    final resultado = await showDialog<Map<String, String>>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: Text(cliente == null ? 'Nuevo cliente' : 'Editar cliente'),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre *',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: direccionController,
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCELAR'),
            ),

            ElevatedButton(
              onPressed: () {
                final nombre = nombreController.text.trim();

                if (nombre.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, {
                  'nombre': nombre,
                  'telefono': telefonoController.text.trim(),
                  'correo': correoController.text.trim(),
                  'direccion': direccionController.text.trim(),
                });
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A35A8),
                foregroundColor: Colors.white,
              ),

              child: Text(cliente == null ? 'GUARDAR' : 'ACTUALIZAR'),
            ),
          ],
        );
      },
    );

    nombreController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    direccionController.dispose();

    return resultado;
  }

  // ==========================================================
  // FICHA DEL CLIENTE
  // ==========================================================

  Future<void> abrirFicha(Map<String, dynamic> cliente) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FichaClientePage(clienteId: cliente['id'] as int),
      ),
    );

    await cargarClientes();
  }

  // ==========================================================
  // PANTALLA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FA),

      appBar: AppBar(
        title: const Text(
          'Clientes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // ==================================================
          // BUSCADOR
          // ==================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),

            child: TextField(
              controller: buscadorController,

              onChanged: (_) {
                cargarClientes();
              },

              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: const Icon(Icons.search),

                suffixIcon: buscadorController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          buscadorController.clear();
                          cargarClientes();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ==================================================
          // LISTA
          // ==================================================
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : clientes.isEmpty
                ? construirVacio()
                : RefreshIndicator(
                    onRefresh: cargarClientes,

                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 5, 18, 25),

                      itemCount: clientes.length,

                      itemBuilder: (context, index) {
                        return construirCliente(clientes[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),

      // ======================================================
      // BOTON NUEVO
      // ======================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: nuevoCliente,

        backgroundColor: const Color(0xFF6A35A8),
        foregroundColor: Colors.white,

        icon: const Icon(Icons.person_add),

        label: const Text(
          'NUEVO CLIENTE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ==========================================================
  // TARJETA CLIENTE
  // ==========================================================

  Widget construirCliente(Map<String, dynamic> cliente) {
    return FutureBuilder<double>(
      future: EferDatabase.instance.totalVentasCliente(cliente['id'] as int),

      builder: (context, snapshotVentas) {
        final ventas = snapshotVentas.data ?? 0;

        return FutureBuilder<int>(
          future: EferDatabase.instance.cantidadVentasCliente(
            cliente['id'] as int,
          ),

          builder: (context, snapshotCantidad) {
            final cantidad = snapshotCantidad.data ?? 0;

            return Card(
              color: Colors.white,

              elevation: 1,

              margin: const EdgeInsets.only(bottom: 10),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),

              child: InkWell(
                borderRadius: BorderRadius.circular(17),

                onTap: () {
                  abrirFicha(cliente);
                },

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Row(
                    children: [
                      // --------------------------------------
                      // ICONO
                      // --------------------------------------

                      Container(
                        width: 52,
                        height: 52,

                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EAF7),
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF6A35A8),
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 13),

                      // --------------------------------------
                      // DATOS
                      // --------------------------------------
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              cliente['nombre']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F245F),
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '$cantidad venta${cantidad == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              dinero(ventas),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A35A8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --------------------------------------
                      // MENU
                      // --------------------------------------
                      PopupMenuButton<String>(
                        onSelected: (valor) {
                          if (valor == 'editar') {
                            editarCliente(cliente);
                          }

                          if (valor == 'desactivar') {
                            desactivarCliente(cliente);
                          }
                        },

                        itemBuilder: (context) {
                          return const [
                            PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),

                            PopupMenuItem(
                              value: 'desactivar',
                              child: Text('Desactivar'),
                            ),
                          ];
                        },
                      ),

                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // SIN CLIENTES
  // ==========================================================

  Widget construirVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 80,
              height: 80,

              decoration: BoxDecoration(
                color: const Color(0xFFF0EAF7),
                borderRadius: BorderRadius.circular(25),
              ),

              child: const Icon(
                Icons.people_outline,
                size: 42,
                color: Color(0xFF6A35A8),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Todavía no hay clientes',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F245F),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Agrega tu primer cliente para comenzar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: nuevoCliente,

              icon: const Icon(Icons.person_add),

              label: const Text('AGREGAR CLIENTE'),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A35A8),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FICHA DEL CLIENTE
// ============================================================

class FichaClientePage extends StatefulWidget {
  final int clienteId;

  const FichaClientePage({super.key, required this.clienteId});

  @override
  State<FichaClientePage> createState() => _FichaClientePageState();
}

class _FichaClientePageState extends State<FichaClientePage> {
  Map<String, dynamic>? cliente;

  List<Map<String, dynamic>> presupuestos = [];

  double totalVentas = 0;

  int cantidadVentas = 0;

  bool cargando = true;

  @override
  void initState() {
    super.initState();

    cargarFicha();
  }

  // ==========================================================
  // CARGAR FICHA
  // ==========================================================

  Future<void> cargarFicha() async {
    final clienteActual = await EferDatabase.instance.obtenerCliente(
      widget.clienteId,
    );

    final historial = await EferDatabase.instance.obtenerPresupuestosCliente(
      widget.clienteId,
    );

    final ventas = await EferDatabase.instance.totalVentasCliente(
      widget.clienteId,
    );

    final cantidad = await EferDatabase.instance.cantidadVentasCliente(
      widget.clienteId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      cliente = clienteActual;
      presupuestos = historial;
      totalVentas = ventas;
      cantidadVentas = cantidad;
      cargando = false;
    });
  }

  // ==========================================================
  // FORMATO DINERO
  // ==========================================================

  String dinero(double valor) {
    return '\$${valor.toStringAsFixed(0)}'.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );
  }

  // ==========================================================
  // ABRIR PRESUPUESTO
  // ==========================================================

  Future<void> abrirPresupuesto(Map<String, dynamic> presupuesto) async {
    try {
      final id = presupuesto['id'] as int;

      final productos = await EferDatabase.instance.obtenerProductos(id);

      if (!mounted) {
        return;
      }

      final lista = productos.map((producto) {
        return ProductoImagen(
          producto: producto['producto'] as String,
          ancho: (producto['ancho'] as num).toDouble(),
          alto: (producto['alto'] as num).toDouble(),
          ancho2: ((producto['ancho2'] ?? 0) as num).toDouble(),
          cantidad: (producto['cantidad'] as num).toDouble(),
          metrosCuadrados: (producto['metrosCuadrados'] as num).toDouble(),
          precioM2: (producto['precioM2'] as num).toDouble(),
          total: (producto['total'] as num).toDouble(),
        );
      }).toList();

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PresupuestoImagen(
            numero: presupuesto['numero'] as int,
            fecha: presupuesto['fecha'] as String,
            hora: presupuesto['hora'] as String,
            nombreCliente: presupuesto['nombreCliente'] as String,
            telefono: (presupuesto['telefono'] as String?) ?? '',
            correo: (presupuesto['correo'] as String?) ?? '',
            direccion: (presupuesto['direccion'] as String?) ?? '',
            subtotal: (presupuesto['subtotal'] as num).toDouble(),
            iva: (presupuesto['iva'] as num).toDouble(),
            total: (presupuesto['total'] as num).toDouble(),
            productos: lista,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el presupuesto: $e')),
      );
    }
  }

  // ==========================================================
  // PANTALLA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (cliente == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cliente')),

        body: const Center(child: Text('Cliente no encontrado')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FA),

      appBar: AppBar(
        title: const Text(
          'Ficha del cliente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // ENCABEZADO
            // ==================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,

                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EAF7),
                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: const Icon(
                      Icons.person,
                      size: 38,
                      color: Color(0xFF6A35A8),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    cliente!['nombre']?.toString() ?? '',
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F245F),
                    ),
                  ),

                  if ((cliente!['telefono'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 7),

                    Text(
                      cliente!['telefono'].toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],

                  if ((cliente!['correo'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 3),

                    Text(
                      cliente!['correo'].toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],

                  if ((cliente!['direccion'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 3),

                    Text(
                      cliente!['direccion'].toString(),
                      textAlign: TextAlign.center,

                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // RESUMEN DE VENTAS
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: resumen(
                    titulo: 'VENTAS',
                    valor: dinero(totalVentas),
                    icono: Icons.attach_money,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: resumen(
                    titulo: 'COMPRAS',
                    valor: '$cantidadVentas',
                    icono: Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // HISTORIAL
            // ==================================================
            const Text(
              'HISTORIAL DE PRESUPUESTOS',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F245F),
              ),
            ),

            const SizedBox(height: 12),

            if (presupuestos.isEmpty)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                ),

                child: const Text(
                  'Este cliente todavía no tiene presupuestos.',
                  textAlign: TextAlign.center,

                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...presupuestos.map((presupuesto) {
                final aceptado = (presupuesto['aceptado'] ?? 0) == 1;

                final total = (presupuesto['total'] as num?)?.toDouble() ?? 0;

                return Card(
                  color: Colors.white,

                  elevation: 1,

                  margin: const EdgeInsets.only(bottom: 9),

                  child: ListTile(
                    onTap: () {
                      abrirPresupuesto(presupuesto);
                    },
                    leading: CircleAvatar(
                      backgroundColor: aceptado
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF0EAF7),

                      child: Icon(
                        aceptado ? Icons.check : Icons.receipt_long,
                        color: aceptado
                            ? Colors.green
                            : const Color(0xFF6A35A8),
                      ),
                    ),

                    title: Text(
                      'Presupuesto Nº ${presupuesto['numero']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      '${presupuesto['fecha'] ?? ''} • '
                      '${aceptado ? 'ACEPTADO' : 'PENDIENTE'}',
                    ),

                    trailing: Text(
                      dinero(total),

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A35A8),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // RESUMEN
  // ==========================================================

  Widget resumen({
    required String titulo,
    required String valor,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(17),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icono, color: const Color(0xFF6A35A8), size: 25),

          const SizedBox(height: 10),

          Text(
            titulo,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            valor,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F245F),
            ),
          ),
        ],
      ),
    );
  }
}
