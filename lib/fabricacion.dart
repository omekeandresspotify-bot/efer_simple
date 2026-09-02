import 'package:flutter/material.dart';

import 'database.dart';

import 'pauta_fabricacion.dart';

class FabricacionPage extends StatefulWidget {
  const FabricacionPage({super.key});

  @override
  State<FabricacionPage> createState() => _FabricacionPageState();
}

class _FabricacionPageState extends State<FabricacionPage> {
  final EferDatabase db = EferDatabase.instance;

  List<Map<String, dynamic>> trabajos = [];

  String filtro = 'PENDIENTES';

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarTrabajos();
  }

  // ==========================================================
  // CARGAR TRABAJOS
  // ==========================================================

  Future<void> cargarTrabajos() async {
    setState(() {
      cargando = true;
    });

    try {
      final datos = await db.obtenerTrabajos();

      if (!mounted) return;

      setState(() {
        trabajos = datos;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los trabajos: $e')),
      );
    }
  }

  // ==========================================================
  // FILTRAR
  // ==========================================================

  List<Map<String, dynamic>> get trabajosFiltrados {
    if (filtro == 'PENDIENTES') {
      return trabajos.where((trabajo) {
        return trabajo['estado'] == 'PENDIENTE';
      }).toList();
    }

    if (filtro == 'EN FABRICACIÓN') {
      return trabajos.where((trabajo) {
        return trabajo['estado'] == 'FABRICACIÓN';
      }).toList();
    }

    if (filtro == 'TERMINADOS') {
      return trabajos.where((trabajo) {
        return trabajo['estado'] == 'FINALIZADO';
      }).toList();
    }

    return trabajos;
  }

  // ==========================================================
  // COLOR ESTADO
  // ==========================================================

  Color colorEstado(String estado) {
    switch (estado) {
      case 'FABRICACIÓN':
        return const Color(0xFF7B1FA2);

      case 'FINALIZADO':
        return const Color(0xFF2E7D32);

      case 'PENDIENTE':
      default:
        return const Color(0xFFF57C00);
    }
  }

  // ==========================================================
  // TEXTO ESTADO
  // ==========================================================

  String textoEstado(String estado) {
    switch (estado) {
      case 'FABRICACIÓN':
        return 'EN FABRICACIÓN';

      case 'FINALIZADO':
        return 'TERMINADO';

      case 'PENDIENTE':
      default:
        return 'PENDIENTE';
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final lista = trabajosFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Fabricación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: cargarTrabajos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),

      body: Column(
        children: [
          // ==================================================
          // CABECERA
          // ==================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            decoration: const BoxDecoration(
              color: Color(0xFF6A1B9A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONTROL DE FABRICACIÓN',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${lista.length} trabajos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                // ==========================================
                // FILTROS
                // ==========================================
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _botonFiltro('PENDIENTES', Icons.schedule),
                      const SizedBox(width: 8),
                      _botonFiltro(
                        'EN FABRICACIÓN',
                        Icons.precision_manufacturing,
                      ),
                      const SizedBox(width: 8),
                      _botonFiltro('TERMINADOS', Icons.check_circle_outline),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // CONTENIDO
          // ==================================================
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: cargarTrabajos,
                    child: lista.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),

                              Icon(
                                Icons.precision_manufacturing_outlined,
                                size: 70,
                                color: Colors.grey.shade400,
                              ),

                              const SizedBox(height: 18),

                              Center(
                                child: Text(
                                  'No hay trabajos ${filtro.toLowerCase()}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: lista.length,
                            itemBuilder: (context, index) {
                              return _tarjetaTrabajo(lista[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BOTÓN FILTRO
  // ==========================================================

  Widget _botonFiltro(String texto, IconData icono) {
    final seleccionado = filtro == texto;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        setState(() {
          filtro = texto;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: seleccionado
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              size: 17,
              color: seleccionado ? const Color(0xFF6A1B9A) : Colors.white,
            ),

            const SizedBox(width: 7),

            Text(
              texto,
              style: TextStyle(
                color: seleccionado ? const Color(0xFF6A1B9A) : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TARJETA DE TRABAJO
  // ==========================================================

  Widget _tarjetaTrabajo(Map<String, dynamic> trabajo) {
    final estado = trabajo['estado']?.toString() ?? 'PENDIENTE';

    final nombreCliente = trabajo['nombreCliente']?.toString() ?? 'Sin cliente';

    final numeroPresupuesto = trabajo['numeroPresupuesto']?.toString() ?? '-';

    final idTrabajo = trabajo['id']?.toString() ?? '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _abrirFicha(trabajo);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================================
              // CABECERA TARJETA
              // ==============================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E5F5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRESUPUESTO Nº $numeroPresupuesto',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          nombreCliente,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado(estado).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      textoEstado(estado),
                      style: TextStyle(
                        color: colorEstado(estado),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Divider(height: 1),

              const SizedBox(height: 14),

              // ==============================================
              // INFORMACIÓN
              // ==============================================
              Row(
                children: [
                  Expanded(
                    child: _dato(
                      Icons.receipt_long,
                      'Presupuesto',
                      '#$numeroPresupuesto',
                    ),
                  ),

                  Expanded(child: _dato(Icons.build, 'Trabajo', '#$idTrabajo')),
                ],
              ),

              const SizedBox(height: 14),

              // ==============================================
              // BOTÓN
              // ==============================================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _abrirFicha(trabajo);
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text(
                    'VER FICHA DE FABRICACIÓN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6A1B9A),
                    side: const BorderSide(color: Color(0xFF6A1B9A)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DATO
  // ==========================================================

  Widget _dato(IconData icono, String titulo, String valor) {
    return Row(
      children: [
        Icon(icono, size: 18, color: const Color(0xFF6A1B9A)),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 2),

              Text(
                valor,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // ABRIR FICHA
  // ==========================================================

  void _abrirFicha(Map<String, dynamic> trabajo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FichaFabricacionPage(trabajo: trabajo)),
    );
  }
}

// ============================================================
// FICHA DE FABRICACIÓN
// ============================================================

class FichaFabricacionPage extends StatefulWidget {
  final Map<String, dynamic> trabajo;

  const FichaFabricacionPage({super.key, required this.trabajo});

  @override
  State<FichaFabricacionPage> createState() => _FichaFabricacionPageState();
}

class _FichaFabricacionPageState extends State<FichaFabricacionPage> {
  final EferDatabase db = EferDatabase.instance;

  List<Map<String, dynamic>> productos = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  // ==========================================================
  // CARGAR PRODUCTOS DEL PRESUPUESTO
  // ==========================================================

  Future<void> cargarProductos() async {
    final presupuestoId = widget.trabajo['presupuestoId'];

    if (presupuestoId == null) {
      setState(() {
        cargando = false;
      });
      return;
    }

    try {
      final datos = await db.obtenerProductos(presupuestoId as int);

      if (!mounted) return;

      setState(() {
        productos = datos;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los elementos: $e')),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final numeroPresupuesto =
        widget.trabajo['numeroPresupuesto']?.toString() ?? '-';

    final nombreCliente =
        widget.trabajo['nombreCliente']?.toString() ?? 'Sin cliente';

    final estado = widget.trabajo['estado']?.toString() ?? 'PENDIENTE';

    final trabajoId = widget.trabajo['id']?.toString() ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        title: const Text(
          'Ficha de fabricación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: cargarProductos,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // IDENTIFICACIÓN
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B9A),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'FABRICACIÓN',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'PRESUPUESTO Nº $numeroPresupuesto',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      nombreCliente,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // ESTADO
              // ==================================================
              _seccionTitulo('ESTADO'),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.sync, color: Color(0xFF6A1B9A)),

                  title: const Text(
                    'Estado actual',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(estado),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // INFORMACIÓN GENERAL
              // ==================================================
              _seccionTitulo('INFORMACIÓN GENERAL'),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    children: [
                      _fila('ID Trabajo', '#$trabajoId'),

                      const Divider(),

                      _fila('Presupuesto', '#$numeroPresupuesto'),

                      const Divider(),

                      _fila('Cliente', nombreCliente),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // ELEMENTOS A FABRICAR
              // ==================================================
              _seccionTitulo('ELEMENTOS A FABRICAR'),

              if (cargando)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (productos.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Este presupuesto no tiene elementos registrados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...List.generate(productos.length, (index) {
                  return _tarjetaProducto(productos[index], index);
                }),

              const SizedBox(height: 20),

              // ==================================================
              // FABRICACIÓN
              // ==================================================
              _seccionTitulo('FABRICACIÓN'),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.content_cut,
                        color: Color(0xFF6A1B9A),
                      ),

                      title: const Text(
                        'Pauta de corte',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: const Text('Perfiles, vidrios y accesorios'),

                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PautaFabricacionGeneralPage(
                              productos: productos,
                            ),
                          ),
                        );
                      },
                    ),

                    const Divider(height: 1),

                    ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Color(0xFF6A1B9A),
                      ),

                      title: const Text(
                        'Imprimir fabricación',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: const Text('Preparar documento de fabricación'),

                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'La impresión la conectaremos después.',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TARJETA PRODUCTO
  // ==========================================================

  Widget _tarjetaProducto(Map<String, dynamic> producto, int index) {
    final nombre = producto['producto']?.toString() ?? 'Producto';

    final ancho = producto['ancho']?.toString() ?? '-';

    final ancho2 = producto['ancho2'];

    final alto = producto['alto']?.toString() ?? '-';

    final cantidad = producto['cantidad']?.toString() ?? '1';

    String medidas;

    if (ancho2 != null &&
        ancho2.toString().isNotEmpty &&
        ancho2.toString() != '0') {
      medidas = '$ancho × $ancho2 × $alto mm';
    } else {
      medidas = '$ancho × $alto mm';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Icon(
                    Icons.window_outlined,
                    color: Color(0xFF6A1B9A),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'ELEMENTO ${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Text(
                    '× $cantidad',
                    style: const TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Divider(),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.straighten,
                  size: 18,
                  color: Color(0xFF6A1B9A),
                ),

                const SizedBox(width: 8),

                Text(
                  medidas,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TÍTULO SECCIÓN
  // ==========================================================

  Widget _seccionTitulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),

      child: Text(
        texto,

        style: const TextStyle(
          color: Color(0xFF6A1B9A),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ==========================================================
  // FILA
  // ==========================================================

  Widget _fila(String titulo, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(titulo, style: TextStyle(color: Colors.grey.shade600)),

        Flexible(
          child: Text(
            valor,

            textAlign: TextAlign.right,

            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
// ============================================================
// PAUTA GENERAL DE FABRICACIÓN
// ============================================================

class PautaFabricacionGeneralPage extends StatelessWidget {
  final List<Map<String, dynamic>> productos;

  const PautaFabricacionGeneralPage({super.key, required this.productos});

  @override
  Widget build(BuildContext context) {
    final resultados = <ResultadoFabricacion>[];

    final errores = <String>[];

    for (final producto in productos) {
      final nombre = producto['producto']?.toString() ?? 'Producto';

      final ancho = double.tryParse(producto['ancho']?.toString() ?? '') ?? 0;

      final ancho2 = double.tryParse(producto['ancho2']?.toString() ?? '');

      final alto = double.tryParse(producto['alto']?.toString() ?? '') ?? 0;

      final cantidad =
          int.tryParse(producto['cantidad']?.toString() ?? '') ?? 1;

      try {
        final resultado = PautaFabricacion.generar(
          producto: nombre,
          ancho: ancho,
          ancho2: ancho2,
          alto: alto,
          cantidadVentanas: cantidad,
        );

        resultados.add(resultado);
      } catch (_) {
        errores.add(nombre);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,

        title: const Text(
          'Pauta de corte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: resultados.isEmpty
          ? _sinResultados(errores)
          : SingleChildScrollView(
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
                      color: const Color(0xFF6A1B9A),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'PAUTA DE FABRICACIÓN',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          '${resultados.length} elementos',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Detalle completo de cortes',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // RESUMEN
                  // ==================================================
                  const Text(
                    'RESUMEN',
                    style: TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Row(
                        children: [
                          Expanded(
                            child: _resumenDato(
                              Icons.window_outlined,
                              'Elementos',
                              '${resultados.length}',
                            ),
                          ),

                          Expanded(
                            child: _resumenDato(
                              Icons.content_cut,
                              'Cortes',
                              '${resultados.fold<int>(0, (total, resultado) => total + resultado.cortes.length)}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // ELEMENTOS
                  // ==================================================
                  const Text(
                    'DETALLE DE FABRICACIÓN',
                    style: TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...resultados.map((resultado) {
                    return _tarjetaResultado(resultado);
                  }),

                  // ==================================================
                  // PRODUCTOS SIN PAUTA
                  // ==================================================
                  if (errores.isNotEmpty) ...[
                    const SizedBox(height: 20),

                    const Text(
                      'ELEMENTOS SIN PAUTA',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'Estos elementos todavía no tienen una pauta de fabricación configurada:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),

                            const SizedBox(height: 10),

                            ...errores.map((nombre) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text('• $nombre'),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),

                  // ==================================================
                  // IMPRIMIR
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'La impresión de fabricación la conectaremos en el siguiente paso.',
                            ),
                          ),
                        );
                      },

                      icon: const Icon(Icons.print),

                      label: const Text(
                        'IMPRIMIR FABRICACIÓN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),

                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
    );
  }

  // ==========================================================
  // SIN RESULTADOS
  // ==========================================================

  Widget _sinResultados(List<String> errores) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.content_cut, size: 60, color: Colors.grey.shade400),

            const SizedBox(height: 15),

            const Text(
              'No se pudieron generar pautas.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            if (errores.isNotEmpty) ...[
              const SizedBox(height: 10),

              Text(
                errores.join('\n'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DATO RESUMEN
  // ==========================================================

  Widget _resumenDato(IconData icono, String titulo, String valor) {
    return Column(
      children: [
        Icon(icono, color: const Color(0xFF6A1B9A), size: 25),

        const SizedBox(height: 6),

        Text(
          valor,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),

        Text(
          titulo,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
      ],
    );
  }

  // ==========================================================
  // TARJETA RESULTADO
  // ==========================================================

  Widget _tarjetaResultado(ResultadoFabricacion resultado) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: ExpansionTile(
        leading: Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: const Color(0xFFF0E5F5),
            borderRadius: BorderRadius.circular(12),
          ),

          child: const Icon(Icons.window_outlined, color: Color(0xFF6A1B9A)),
        ),

        title: Text(
          resultado.producto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        subtitle: Text(
          '${resultado.anchoVentana.toStringAsFixed(0)} × '
          '${resultado.altoVentana.toStringAsFixed(0)} mm'
          ' • × ${resultado.cantidadVentanas}',
        ),

        children: [
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),

            child: Column(
              children: [
                ...resultado.cortes.map((corte) {
                  String medida;

                  if (corte.ancho != null && corte.alto != null) {
                    medida =
                        '${corte.ancho!.toStringAsFixed(0)} × '
                        '${corte.alto!.toStringAsFixed(0)} mm';
                  } else if (corte.ancho != null) {
                    medida = '${corte.ancho!.toStringAsFixed(0)} mm';
                  } else if (corte.alto != null) {
                    medida = '${corte.alto!.toStringAsFixed(0)} mm';
                  } else {
                    medida = '-';
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),

                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            corte.pieza,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),

                        Text(
                          medida,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          '×${corte.cantidad}',
                          style: const TextStyle(
                            color: Color(0xFF6A1B9A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
