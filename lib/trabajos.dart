import 'package:flutter/material.dart';

import 'database.dart';

class TrabajosPage extends StatefulWidget {
  const TrabajosPage({super.key});

  @override
  State<TrabajosPage> createState() => _TrabajosPageState();
}

class _TrabajosPageState extends State<TrabajosPage> {
  List<Map<String, dynamic>> trabajos = [];

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

    final lista = await EferDatabase.instance.obtenerTrabajos();

    if (!mounted) {
      return;
    }

    setState(() {
      trabajos = lista;
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
  // COLOR DEL ESTADO
  // ==========================================================

  Color colorEstado(String estado) {
    switch (estado) {
      case 'FABRICACIÓN':
        return const Color(0xFF6A35A8);

      case 'INSTALACIÓN PROGRAMADA':
        return const Color(0xFF1976D2);

      case 'FINALIZADO':
        return const Color(0xFF2E7D32);

      case 'PENDIENTE':
      default:
        return const Color(0xFFE69100);
    }
  }

  // ==========================================================
  // ICONO DEL ESTADO
  // ==========================================================

  IconData iconoEstado(String estado) {
    switch (estado) {
      case 'FABRICACIÓN':
        return Icons.precision_manufacturing_outlined;

      case 'INSTALACIÓN PROGRAMADA':
        return Icons.event_available_outlined;

      case 'FINALIZADO':
        return Icons.check_circle_outline;

      case 'PENDIENTE':
      default:
        return Icons.pending_actions_outlined;
    }
  }

  // ==========================================================
  // CAMBIAR ESTADO
  // ==========================================================

  Future<void> cambiarEstado(Map<String, dynamic> trabajo) async {
    final estados = [
      'PENDIENTE',
      'FABRICACIÓN',
      'INSTALACIÓN PROGRAMADA',
      'FINALIZADO',
    ];

    final estadoActual = trabajo['estado'] as String;

    final indiceActual = estados.indexOf(estadoActual);

    final siguienteEstado =
        indiceActual >= 0 && indiceActual < estados.length - 1
        ? estados[indiceActual + 1]
        : null;

    if (siguienteEstado == null) {
      return;
    }

    await EferDatabase.instance.actualizarEstadoTrabajo(
      trabajoId: trabajo['id'] as int,
      estado: siguienteEstado,
    );

    await cargarTrabajos();
  }

  // ==========================================================
  // FICHA DEL TRABAJO
  // ==========================================================

  void abrirTrabajo(Map<String, dynamic> trabajo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrabajoDetallePage(trabajoId: trabajo['id'] as int),
      ),
    ).then((_) {
      cargarTrabajos();
    });
  }

  // ==========================================================
  // PANTALLA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6A35A8),
        foregroundColor: Colors.white,
        title: const Text(
          'Trabajos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: cargarTrabajos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : trabajos.isEmpty
          ? const _SinTrabajos()
          : RefreshIndicator(
              onRefresh: cargarTrabajos,

              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),

                itemCount: trabajos.length,

                itemBuilder: (context, index) {
                  final trabajo = trabajos[index];

                  final estado = (trabajo['estado'] ?? 'PENDIENTE').toString();

                  final nombreCliente =
                      (trabajo['nombreCliente'] ?? 'Cliente sin nombre')
                          .toString();

                  final numeroPresupuesto = trabajo['numeroPresupuesto'];

                  final total =
                      (trabajo['totalPresupuesto'] as num?)?.toDouble() ?? 0;

                  final color = colorEstado(estado);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(color: const Color(0xFFE3DCEB)),

                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 3,
                          offset: Offset(0, 2),
                          color: Color(0x12000000),
                        ),
                      ],
                    ),

                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),

                      onTap: () {
                        abrirTrabajo(trabajo);
                      },

                      child: Padding(
                        padding: const EdgeInsets.all(15),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,

                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.10),

                                    borderRadius: BorderRadius.circular(13),
                                  ),

                                  child: Icon(
                                    Icons.construction_outlined,
                                    color: color,
                                    size: 25,
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        nombreCliente,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3F245F),
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        'Presupuesto Nº $numeroPresupuesto',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Icon(
                                  iconoEstado(estado),
                                  color: color,
                                  size: 18,
                                ),

                                const SizedBox(width: 7),

                                Expanded(
                                  child: Text(
                                    estado,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),

                                Text(
                                  dinero(total),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6A35A8),
                                  ),
                                ),
                              ],
                            ),

                            if (estado != 'FINALIZADO') ...[
                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,

                                child: OutlinedButton(
                                  onPressed: () {
                                    cambiarEstado(trabajo);
                                  },

                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: color,
                                    side: BorderSide(color: color),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),

                                  child: Text('Avanzar a siguiente estado'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ============================================================
// SIN TRABAJOS
// ============================================================

class _SinTrabajos extends StatelessWidget {
  const _SinTrabajos();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.construction_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 18),

            const Text(
              'No hay trabajos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF154568),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Los trabajos creados aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DETALLE DEL TRABAJO
// ============================================================

class TrabajoDetallePage extends StatefulWidget {
  final int trabajoId;

  const TrabajoDetallePage({super.key, required this.trabajoId});

  @override
  State<TrabajoDetallePage> createState() => _TrabajoDetallePageState();
}

class _TrabajoDetallePageState extends State<TrabajoDetallePage> {
  Map<String, dynamic>? trabajo;

  List<Map<String, dynamic>> historialEstados = [];

  bool cargando = true;
  @override
  void initState() {
    super.initState();

    cargarTrabajo();
  }

  Future<void> cargarTrabajo() async {
    final resultado = await EferDatabase.instance.obtenerTrabajo(
      widget.trabajoId,
    );

    final historial = await EferDatabase.instance.obtenerHistorialEstados(
      widget.trabajoId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      trabajo = resultado;
      historialEstados = historial;
      cargando = false;
    });
  }

  String dinero(double valor) {
    return '\$${valor.toStringAsFixed(0)}'.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );
  }

  Color colorEstado(String estado) {
    switch (estado) {
      case 'FABRICACIÓN':
        return const Color(0xFF6A35A8);

      case 'INSTALACIÓN PROGRAMADA':
        return const Color(0xFF1976D2);

      case 'FINALIZADO':
        return const Color(0xFF2E7D32);

      case 'PENDIENTE':
      default:
        return const Color(0xFFE69100);
    }
  }

  // ==========================================================
  // ESTADOS DEL TRABAJO
  // ==========================================================

  static const List<String> estadosTrabajo = [
    'PENDIENTE',
    'FABRICACIÓN',
    'INSTALACIÓN PROGRAMADA',
    'FINALIZADO',
  ];

  // ==========================================================
  // FORMATO FECHA
  // ==========================================================

  String formatoFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(fecha);

      final dia = date.day.toString().padLeft(2, '0');
      final mes = date.month.toString().padLeft(2, '0');
      final anio = date.year.toString();

      final hora = date.hour.toString().padLeft(2, '0');
      final minuto = date.minute.toString().padLeft(2, '0');

      return '$dia/$mes/$anio - $hora:$minuto';
    } catch (_) {
      return '';
    }
  }

  // ==========================================================
  // FECHA DE CADA ESTADO
  // ==========================================================

  String fechaEstado(String estado) {
    for (final registro in historialEstados) {
      if (registro['estado'] == estado) {
        return formatoFecha(registro['fecha']?.toString());
      }
    }

    return '';
  }

  // ==========================================================
  // COLOR DEL ESTADO
  // ==========================================================

  Color colorEstadoTimeline(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return const Color(0xFFE69100);

      case 'FABRICACIÓN':
        return const Color(0xFF6A35A8);

      case 'INSTALACIÓN PROGRAMADA':
        return const Color(0xFF1976D2);

      case 'FINALIZADO':
        return const Color(0xFF2E7D32);

      default:
        return Colors.grey;
    }
  }

  // ==========================================================
  // ICONO DEL ESTADO
  // ==========================================================

  IconData iconoEstadoTimeline(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Icons.hourglass_empty;

      case 'FABRICACIÓN':
        return Icons.precision_manufacturing;

      case 'INSTALACIÓN PROGRAMADA':
        return Icons.calendar_month;

      case 'FINALIZADO':
        return Icons.check;

      default:
        return Icons.circle;
    }
  }

  // ==========================================================
  // ESTADO ACTUAL
  // ==========================================================

  int indiceEstadoActual() {
    final actual = (trabajo?['estado'] ?? 'PENDIENTE').toString();

    final indice = estadosTrabajo.indexOf(actual);

    return indice < 0 ? 0 : indice;
  }

  // ==========================================================
  // TIMELINE DEL TRABAJO
  // ==========================================================

  Widget timelineTrabajo() {
    final indiceActual = indiceEstadoActual();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3DCEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTADO DEL TRABAJO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            estadosTrabajo[indiceActual],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorEstadoTimeline(estadosTrabajo[indiceActual]),
            ),
          ),

          const SizedBox(height: 25),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: SizedBox(
              width: 850,

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: List.generate(estadosTrabajo.length, (index) {
                  final estado = estadosTrabajo[index];

                  final completado = index < indiceActual;
                  final actual = index == indiceActual;

                  final color = completado
                      ? const Color(0xFF2E7D32)
                      : actual
                      ? colorEstadoTimeline(estado)
                      : const Color(0xFFD8D3DF);

                  return Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,

                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),

                                child: Icon(
                                  completado
                                      ? Icons.check
                                      : iconoEstadoTimeline(estado),
                                  color: Colors.white,
                                  size: 23,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                estado,
                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                fechaEstado(estado),
                                textAlign: TextAlign.center,

                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (index < estadosTrabajo.length - 1)
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(top: 23),

                              height: 3,

                              color: index < indiceActual
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFD8D3DF),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 22),

          if (indiceActual < estadosTrabajo.length - 1)
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: avanzarEstado,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A35A8),
                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(vertical: 14),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  'Avanzar estado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(vertical: 13),

              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    'Trabajo finalizado',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),

                  SizedBox(width: 8),

                  Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                ],
              ),
            ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: const Color(0xFFF5F0FA),
              borderRadius: BorderRadius.circular(10),
            ),

            child: const Row(
              children: [
                Icon(Icons.info, color: Color(0xFF6A35A8), size: 20),

                SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Cada vez que avances de estado, '
                    'quedará registrada la fecha y hora '
                    'en que se realizó el cambio.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF5E5368)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> avanzarEstado() async {
    if (trabajo == null) {
      return;
    }

    const estados = [
      'PENDIENTE',
      'FABRICACIÓN',
      'INSTALACIÓN PROGRAMADA',
      'FINALIZADO',
    ];

    final actual = (trabajo!['estado'] ?? 'PENDIENTE').toString();

    final indice = estados.indexOf(actual);

    if (indice < 0 || indice >= estados.length - 1) {
      return;
    }

    await EferDatabase.instance.actualizarEstadoTrabajo(
      trabajoId: widget.trabajoId,
      estado: estados[indice + 1],
    );

    await cargarTrabajo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6A35A8),
        foregroundColor: Colors.white,
        title: const Text(
          'Detalle del trabajo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : trabajo == null
          ? const Center(child: Text('No se encontró el trabajo.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(18),

                      border: Border.all(color: const Color(0xFFE3DCEB)),
                    ),

                    child: Column(
                      children: [
                        const Icon(
                          Icons.construction_outlined,
                          size: 50,
                          color: Color(0xFF6A35A8),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          (trabajo!['nombreCliente'] ?? 'Cliente sin nombre')
                              .toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F245F),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Presupuesto Nº ${trabajo!['numeroPresupuesto']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  _dato(
                    'TOTAL',
                    dinero(
                      (trabajo!['totalPresupuesto'] as num?)?.toDouble() ?? 0,
                    ),
                  ),

                  _dato(
                    'TELÉFONO',
                    (trabajo!['telefonoCliente'] ?? 'Sin teléfono').toString(),
                  ),

                  _dato(
                    'CORREO',
                    (trabajo!['correoCliente'] ?? 'Sin correo').toString(),
                  ),

                  _dato(
                    'DIRECCIÓN',
                    (trabajo!['direccionCliente'] ?? 'Sin dirección')
                        .toString(),
                  ),

                  const SizedBox(height: 15),

                  timelineTrabajo(),
                ],
              ),
            ),
    );
  }

  Widget _dato(String titulo, String valor) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: const Color(0xFFE3DCEB)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            valor,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3F245F),
            ),
          ),
        ],
      ),
    );
  }
}
