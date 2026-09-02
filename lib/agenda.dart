import 'package:flutter/material.dart';

import 'database.dart';

// ============================================================
// AGENDA
// ============================================================

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  List<Map<String, dynamic>> instalaciones = [];
  List<Map<String, dynamic>> trabajos = [];

  bool cargando = true;

  DateTime fechaSeleccionada = DateTime.now();

  int vistaActual = 0;

  @override
  void initState() {
    super.initState();

    cargarAgenda();
  }

  // ==========================================================
  // CARGAR AGENDA
  // ==========================================================

  Future<void> cargarAgenda() async {
    setState(() {
      cargando = true;
    });

    final listaInstalaciones = await EferDatabase.instance
        .obtenerInstalaciones();

    final listaTrabajos = await EferDatabase.instance.obtenerTrabajos();

    if (!mounted) {
      return;
    }

    setState(() {
      instalaciones = listaInstalaciones;
      trabajos = listaTrabajos;
      cargando = false;
    });
  }

  // ==========================================================
  // FORMATO FECHA
  // ==========================================================

  String fechaBase(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();

    return '$anio-$mes-$dia';
  }

  // ==========================================================
  // FECHA PARA MOSTRAR
  // ==========================================================

  String fechaLarga(DateTime fecha) {
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${dias[fecha.weekday - 1]} '
        '${fecha.day} de '
        '${meses[fecha.month - 1]} '
        '${fecha.year}';
  }

  // ==========================================================
  // MES Y AÑO
  // ==========================================================

  String nombreMes(DateTime fecha) {
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return '${meses[fecha.month - 1]} ${fecha.year}';
  }

  // ==========================================================
  // DINERO
  // ==========================================================

  String dinero(double valor) {
    return '\$${valor.toStringAsFixed(0)}'.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );
  }

  // ==========================================================
  // COLOR ESTADO
  // ==========================================================

  Color colorEstado(String estado) {
    switch (estado) {
      case 'COMPLETADA':
        return const Color(0xFF2E7D32);

      case 'PENDIENTE':
      default:
        return const Color(0xFF6A35A8);
    }
  }

  // ==========================================================
  // INSTALACIONES DEL DÍA
  // ==========================================================

  List<Map<String, dynamic>> instalacionesDelDia(DateTime fecha) {
    final fechaTexto = fechaBase(fecha);

    final resultado = instalaciones.where((instalacion) {
      return instalacion['fecha'].toString() == fechaTexto;
    }).toList();

    resultado.sort((a, b) {
      return a['hora'].toString().compareTo(b['hora'].toString());
    });

    return resultado;
  }

  // ==========================================================
  // TIENE INSTALACIONES
  // ==========================================================

  bool tieneInstalaciones(DateTime fecha) {
    return instalacionesDelDia(fecha).isNotEmpty;
  }

  // ==========================================================
  // CAMBIAR DÍA
  // ==========================================================

  void cambiarDia(int cantidad) {
    setState(() {
      fechaSeleccionada = DateTime(
        fechaSeleccionada.year,
        fechaSeleccionada.month,
        fechaSeleccionada.day + cantidad,
      );
    });
  }

  // ==========================================================
  // CAMBIAR MES
  // ==========================================================

  void cambiarMes(int cantidad) {
    setState(() {
      fechaSeleccionada = DateTime(
        fechaSeleccionada.year,
        fechaSeleccionada.month + cantidad,
        1,
      );
    });
  }

  // ==========================================================
  // CREAR INSTALACIÓN
  // ==========================================================

  Future<void> nuevaInstalacion() async {
    final trabajosDisponibles = trabajos.where((trabajo) {
      final estado = (trabajo['estado'] ?? '').toString();

      return estado != 'FINALIZADO';
    }).toList();

    if (trabajosDisponibles.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay trabajos disponibles para programar.'),
        ),
      );

      return;
    }

    await showDialog(
      context: context,
      builder: (_) {
        return _SeleccionarTrabajoDialog(
          trabajos: trabajosDisponibles,
          onSeleccionar: (trabajo) async {
            Navigator.pop(context);

            await abrirFormularioInstalacion(trabajo);
          },
        );
      },
    );
  }

  // ==========================================================
  // FORMULARIO NUEVA INSTALACIÓN
  // ==========================================================

  Future<void> abrirFormularioInstalacion(Map<String, dynamic> trabajo) async {
    DateTime fecha = fechaSeleccionada;

    TimeOfDay hora = const TimeOfDay(hour: 9, minute: 0);

    final responsableController = TextEditingController();

    final notasController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Programar instalación',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F245F),
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _datoTrabajoDialog(
                      'CLIENTE',
                      (trabajo['nombreCliente'] ?? 'Cliente sin nombre')
                          .toString(),
                    ),

                    _datoTrabajoDialog(
                      'PRESUPUESTO',
                      'Nº ${trabajo['numeroPresupuesto']}',
                    ),

                    const SizedBox(height: 15),

                    ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF6A35A8),
                      ),

                      title: const Text('Fecha'),

                      subtitle: Text(fechaLarga(fecha)),

                      onTap: () async {
                        final seleccion = await showDatePicker(
                          context: context,
                          initialDate: fecha,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime(DateTime.now().year + 5),
                        );

                        if (seleccion != null) {
                          setDialogState(() {
                            fecha = seleccion;
                          });
                        }
                      },
                    ),

                    ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: const Icon(
                        Icons.access_time,
                        color: Color(0xFF6A35A8),
                      ),

                      title: const Text('Hora'),

                      subtitle: Text(hora.format(context)),

                      onTap: () async {
                        final seleccion = await showTimePicker(
                          context: context,
                          initialTime: hora,
                        );

                        if (seleccion != null) {
                          setDialogState(() {
                            hora = seleccion;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: responsableController,
                      decoration: const InputDecoration(
                        labelText: 'Responsable',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: notasController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notas',
                        prefixIcon: Icon(Icons.notes_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final fechaTexto = fechaBase(fecha);

                    final horaTexto =
                        '${hora.hour.toString().padLeft(2, '0')}:'
                        '${hora.minute.toString().padLeft(2, '0')}';

                    await EferDatabase.instance.crearInstalacion(
                      trabajoId: trabajo['id'] as int,
                      fecha: fechaTexto,
                      hora: horaTexto,
                      responsable: responsableController.text.trim(),
                      notas: notasController.text.trim(),
                    );

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context);

                    await cargarAgenda();
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A35A8),
                    foregroundColor: Colors.white,
                  ),

                  child: const Text('Programar instalación'),
                ),
              ],
            );
          },
        );
      },
    );

    responsableController.dispose();
    notasController.dispose();
  }

  // ==========================================================
  // DETALLE INSTALACIÓN
  // ==========================================================

  Future<void> abrirDetalle(Map<String, dynamic> instalacion) async {
    final actualizada = await EferDatabase.instance.obtenerInstalacion(
      instalacion['id'] as int,
    );

    if (!mounted || actualizada == null) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (_) {
        return _DetalleInstalacion(
          instalacion: actualizada,
          onEditar: () async {
            Navigator.pop(context);

            await editarInstalacion(actualizada);
          },
          onCompletar: () async {
            Navigator.pop(context);

            await EferDatabase.instance.completarInstalacion(
              actualizada['id'] as int,
            );

            await cargarAgenda();
          },
        );
      },
    );
  }

  // ==========================================================
  // EDITAR INSTALACIÓN
  // ==========================================================

  Future<void> editarInstalacion(Map<String, dynamic> instalacion) async {
    DateTime fecha =
        DateTime.tryParse(instalacion['fecha'].toString()) ?? fechaSeleccionada;

    final partesHora = instalacion['hora'].toString().split(':');

    TimeOfDay hora = TimeOfDay(
      hour: int.tryParse(partesHora.first) ?? 9,
      minute: int.tryParse(partesHora.length > 1 ? partesHora[1] : '0') ?? 0,
    );

    final responsableController = TextEditingController(
      text: (instalacion['responsable'] ?? '').toString(),
    );

    final notasController = TextEditingController(
      text: (instalacion['notas'] ?? '').toString(),
    );

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Editar instalación',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F245F),
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF6A35A8),
                      ),

                      title: const Text('Fecha'),

                      subtitle: Text(fechaLarga(fecha)),

                      onTap: () async {
                        final seleccion = await showDatePicker(
                          context: context,
                          initialDate: fecha,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime(DateTime.now().year + 5),
                        );

                        if (seleccion != null) {
                          setDialogState(() {
                            fecha = seleccion;
                          });
                        }
                      },
                    ),

                    ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: const Icon(
                        Icons.access_time,
                        color: Color(0xFF6A35A8),
                      ),

                      title: const Text('Hora'),

                      subtitle: Text(hora.format(context)),

                      onTap: () async {
                        final seleccion = await showTimePicker(
                          context: context,
                          initialTime: hora,
                        );

                        if (seleccion != null) {
                          setDialogState(() {
                            hora = seleccion;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: responsableController,
                      decoration: const InputDecoration(
                        labelText: 'Responsable',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: notasController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notas',
                        prefixIcon: Icon(Icons.notes_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final fechaTexto = fechaBase(fecha);

                    final horaTexto =
                        '${hora.hour.toString().padLeft(2, '0')}:'
                        '${hora.minute.toString().padLeft(2, '0')}';

                    await EferDatabase.instance.actualizarInstalacion(
                      instalacionId: instalacion['id'] as int,
                      fecha: fechaTexto,
                      hora: horaTexto,
                      responsable: responsableController.text.trim(),
                      notas: notasController.text.trim(),
                    );

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context);

                    await cargarAgenda();
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A35A8),
                    foregroundColor: Colors.white,
                  ),

                  child: const Text('Guardar cambios'),
                ),
              ],
            );
          },
        );
      },
    );

    responsableController.dispose();
    notasController.dispose();
  }

  // ==========================================================
  // VISTA DÍA
  // ==========================================================

  Widget vistaDia() {
    final lista = instalacionesDelDia(fechaSeleccionada);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),

          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  cambiarDia(-1);
                },
                icon: const Icon(Icons.chevron_left, color: Color(0xFF3F245F)),
              ),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE3DCEB)),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF6A35A8),
                        size: 20,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        fechaLarga(fechaSeleccionada),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F245F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  cambiarDia(1);
                },
                icon: const Icon(Icons.chevron_right, color: Color(0xFF3F245F)),
              ),
            ],
          ),
        ),

        Expanded(
          child: lista.isEmpty
              ? _SinInstalaciones(
                  fecha: fechaSeleccionada,
                  onAgregar: nuevaInstalacion,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 5, 14, 100),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    return _TarjetaInstalacion(
                      instalacion: lista[index],
                      onTap: () {
                        abrirDetalle(lista[index]);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================================
  // VISTA CALENDARIO
  // ==========================================================

  Widget vistaCalendario() {
    final primerDia = DateTime(
      fechaSeleccionada.year,
      fechaSeleccionada.month,
      1,
    );

    final ultimoDia = DateTime(
      fechaSeleccionada.year,
      fechaSeleccionada.month + 1,
      0,
    );

    final cantidadDias = ultimoDia.day;

    final desplazamiento = primerDia.weekday - 1;

    final totalCeldas = ((desplazamiento + cantidadDias) / 7).ceil() * 7;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),

      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  cambiarMes(-1);
                },
                icon: const Icon(Icons.chevron_left),
              ),

              Text(
                nombreMes(fechaSeleccionada),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A35A8),
                ),
              ),

              IconButton(
                onPressed: () {
                  cambiarMes(1);
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE3DCEB)),
            ),

            child: Column(
              children: [
                Row(
                  children: const [
                    _NombreDia('LUN'),
                    _NombreDia('MAR'),
                    _NombreDia('MIÉ'),
                    _NombreDia('JUE'),
                    _NombreDia('VIE'),
                    _NombreDia('SÁB'),
                    _NombreDia('DOM'),
                  ],
                ),

                const SizedBox(height: 8),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: totalCeldas,

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 5,
                  ),

                  itemBuilder: (context, index) {
                    final numero = index - desplazamiento + 1;

                    if (numero < 1 || numero > cantidadDias) {
                      return const SizedBox();
                    }

                    final fecha = DateTime(
                      fechaSeleccionada.year,
                      fechaSeleccionada.month,
                      numero,
                    );

                    final seleccionado =
                        fecha.year == fechaSeleccionada.year &&
                        fecha.month == fechaSeleccionada.month &&
                        fecha.day == fechaSeleccionada.day;

                    final tiene = tieneInstalaciones(fecha);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          fechaSeleccionada = fecha;
                          vistaActual = 0;
                        });
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          color: seleccionado
                              ? const Color(0xFF6A35A8)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Text(
                              '$numero',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: seleccionado
                                    ? Colors.white
                                    : const Color(0xFF3F245F),
                              ),
                            ),

                            const SizedBox(height: 3),

                            if (tiene)
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: seleccionado
                                      ? Colors.white
                                      : const Color(0xFF6A35A8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Próximas instalaciones',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A35A8),
              ),
            ),
          ),

          const SizedBox(height: 10),

          ...proximasInstalaciones()
              .take(5)
              .map(
                (instalacion) => _TarjetaProxima(
                  instalacion: instalacion,
                  onTap: () {
                    abrirDetalle(instalacion);
                  },
                ),
              ),
        ],
      ),
    );
  }

  // ==========================================================
  // PRÓXIMAS INSTALACIONES
  // ==========================================================

  List<Map<String, dynamic>> proximasInstalaciones() {
    final hoy = DateTime.now();

    final lista = instalaciones.where((instalacion) {
      final fecha = DateTime.tryParse(instalacion['fecha'].toString());

      if (fecha == null) {
        return false;
      }

      return !fecha.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
    }).toList();

    lista.sort((a, b) {
      final fechaA = '${a['fecha']} ${a['hora']}';

      final fechaB = '${b['fecha']} ${b['hora']}';

      return fechaA.compareTo(fechaB);
    });

    return lista;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6A35A8),

        foregroundColor: Colors.white,

        title: const Text(
          'AGENDA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(onPressed: cargarAgenda, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),

                  padding: const EdgeInsets.all(4),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE3DCEB)),
                  ),

                  child: Row(
                    children: [
                      _BotonVista(
                        titulo: 'Día',
                        seleccionado: vistaActual == 0,
                        onTap: () {
                          setState(() {
                            vistaActual = 0;
                          });
                        },
                      ),

                      _BotonVista(
                        titulo: 'Calendario',
                        seleccionado: vistaActual == 1,
                        onTap: () {
                          setState(() {
                            vistaActual = 1;
                          });
                        },
                      ),

                      _BotonVista(
                        titulo: 'Próximas',
                        seleccionado: vistaActual == 2,
                        onTap: () {
                          setState(() {
                            vistaActual = 2;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                Expanded(
                  child: vistaActual == 0
                      ? vistaDia()
                      : vistaActual == 1
                      ? vistaCalendario()
                      : vistaProximas(),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: nuevaInstalacion,

        backgroundColor: const Color(0xFF6A35A8),

        foregroundColor: Colors.white,

        child: const Icon(Icons.add),
      ),
    );
  }

  // ==========================================================
  // VISTA PRÓXIMAS
  // ==========================================================

  Widget vistaProximas() {
    final lista = proximasInstalaciones();

    if (lista.isEmpty) {
      return const _SinProximas();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),

      itemCount: lista.length,

      itemBuilder: (context, index) {
        return _TarjetaProxima(
          instalacion: lista[index],
          onTap: () {
            abrirDetalle(lista[index]);
          },
        );
      },
    );
  }

  Widget _datoTrabajoDialog(String titulo, String valor) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 8),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFFF5F0FA),
        borderRadius: BorderRadius.circular(10),
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
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F245F),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTÓN VISTA
// ============================================================

class _BotonVista extends StatelessWidget {
  final String titulo;
  final bool seleccionado;
  final VoidCallback onTap;

  const _BotonVista({
    required this.titulo,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),

          decoration: BoxDecoration(
            color: seleccionado ? Colors.white : Colors.transparent,

            borderRadius: BorderRadius.circular(11),

            boxShadow: seleccionado
                ? const [
                    BoxShadow(
                      blurRadius: 5,
                      offset: Offset(0, 2),
                      color: Color(0x18000000),
                    ),
                  ]
                : null,
          ),

          child: Text(
            titulo,
            textAlign: TextAlign.center,

            style: TextStyle(
              fontWeight: FontWeight.bold,

              color: seleccionado ? const Color(0xFF3F245F) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NOMBRE DÍA
// ============================================================

class _NombreDia extends StatelessWidget {
  final String texto;

  const _NombreDia(this.texto);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF746B7D),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TARJETA INSTALACIÓN
// ============================================================

class _TarjetaInstalacion extends StatelessWidget {
  final Map<String, dynamic> instalacion;
  final VoidCallback onTap;

  const _TarjetaInstalacion({required this.instalacion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nombre = (instalacion['nombreCliente'] ?? 'Cliente sin nombre')
        .toString();

    final numero = instalacion['numeroPresupuesto'];

    final direccion = (instalacion['direccionCliente'] ?? 'Sin dirección')
        .toString();

    final responsable = (instalacion['responsable'] ?? 'Sin responsable')
        .toString();

    final telefono = (instalacion['telefonoCliente'] ?? 'Sin teléfono')
        .toString();

    final notas = (instalacion['notas'] ?? '').toString();

    final hora = instalacion['hora'].toString();

    final completada = instalacion['estado'] == 'COMPLETADA';

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
        onTap: onTap,

        borderRadius: BorderRadius.circular(16),

        child: Padding(
          padding: const EdgeInsets.all(15),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(
                    width: 58,

                    child: Text(
                      hora,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A35A8),
                      ),
                    ),
                  ),

                  Container(
                    width: 45,
                    height: 45,

                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E8F8),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(Icons.home, color: Color(0xFF6A35A8)),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3F245F),
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),

                              decoration: BoxDecoration(
                                color: completada
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFF0E8F8),
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Text(
                                completada ? 'COMPLETADA' : 'INSTALACIÓN',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: completada
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFF6A35A8),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'Presupuesto Nº $numero',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6A35A8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              _LineaDato(icono: Icons.location_on_outlined, texto: direccion),

              _LineaDato(icono: Icons.person_outline, texto: responsable),

              _LineaDato(icono: Icons.phone_outlined, texto: telefono),

              if (notas.isNotEmpty)
                _LineaDato(icono: Icons.notes_outlined, texto: notas),

              const SizedBox(height: 5),

              const Align(
                alignment: Alignment.centerRight,

                child: Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LÍNEA DATO
// ============================================================

class _LineaDato extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _LineaDato({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),

      child: Row(
        children: [
          Icon(icono, size: 17, color: const Color(0xFF6A35A8)),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4F4657)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TARJETA PRÓXIMA
// ============================================================

class _TarjetaProxima extends StatelessWidget {
  final Map<String, dynamic> instalacion;
  final VoidCallback onTap;

  const _TarjetaProxima({required this.instalacion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fecha = DateTime.tryParse(instalacion['fecha'].toString());

    final nombre = (instalacion['nombreCliente'] ?? 'Cliente sin nombre')
        .toString();

    final numero = instalacion['numeroPresupuesto'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: const Color(0xFFE3DCEB)),
      ),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(14),

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [
              Container(
                width: 55,
                padding: const EdgeInsets.symmetric(vertical: 7),

                decoration: BoxDecoration(
                  color: const Color(0xFFF0E8F8),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Column(
                  children: [
                    Text(
                      fecha == null ? '--' : '${fecha.day}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A35A8),
                      ),
                    ),

                    Text(
                      fecha == null ? '' : _mesCorto(fecha.month),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A35A8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      instalacion['hora'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F245F),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F245F),
                      ),
                    ),

                    Text(
                      'Presupuesto Nº $numero',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6A35A8),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
            ],
          ),
        ),
      ),
    );
  }

  String _mesCorto(int mes) {
    const meses = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
    ];

    return meses[mes - 1];
  }
}

// ============================================================
// DETALLE INSTALACIÓN
// ============================================================

class _DetalleInstalacion extends StatelessWidget {
  final Map<String, dynamic> instalacion;
  final VoidCallback onEditar;
  final VoidCallback onCompletar;

  const _DetalleInstalacion({
    required this.instalacion,
    required this.onEditar,
    required this.onCompletar,
  });

  @override
  Widget build(BuildContext context) {
    final completada = instalacion['estado'] == 'COMPLETADA';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),

      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0CBD5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.home, color: Color(0xFF6A35A8)),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Detalle de instalación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A35A8),
                        ),
                      ),

                      Text(
                        (instalacion['nombreCliente'] ?? 'Cliente').toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F245F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _DetalleLinea(
              icono: Icons.description_outlined,
              titulo: 'Presupuesto',
              valor: 'Nº ${instalacion['numeroPresupuesto']}',
            ),

            _DetalleLinea(
              icono: Icons.calendar_month,
              titulo: 'Fecha',
              valor: instalacion['fecha'].toString(),
            ),

            _DetalleLinea(
              icono: Icons.access_time,
              titulo: 'Horario',
              valor: instalacion['hora'].toString(),
            ),

            _DetalleLinea(
              icono: Icons.person_outline,
              titulo: 'Responsable',
              valor: (instalacion['responsable'] ?? 'Sin responsable')
                  .toString(),
            ),

            _DetalleLinea(
              icono: Icons.location_on_outlined,
              titulo: 'Dirección',
              valor: (instalacion['direccionCliente'] ?? 'Sin dirección')
                  .toString(),
            ),

            _DetalleLinea(
              icono: Icons.phone_outlined,
              titulo: 'Teléfono',
              valor: (instalacion['telefonoCliente'] ?? 'Sin teléfono')
                  .toString(),
            ),

            _DetalleLinea(
              icono: Icons.notes_outlined,
              titulo: 'Notas',
              valor: (instalacion['notas'] ?? 'Sin notas').toString(),
            ),

            const SizedBox(height: 20),

            if (!completada)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEditar,

                      icon: const Icon(Icons.edit),

                      label: const Text('Editar'),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6A35A8),
                        side: const BorderSide(color: Color(0xFF6A35A8)),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCompletar,

                      icon: const Icon(Icons.check),

                      label: const Text('Completar'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A35A8),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(vertical: 14),

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF2E7D32)),

                    SizedBox(width: 8),

                    Text(
                      'Instalación completada',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DETALLE LÍNEA
// ============================================================

class _DetalleLinea extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _DetalleLinea({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icono, size: 19, color: const Color(0xFF6A35A8)),

          const SizedBox(width: 10),

          SizedBox(
            width: 90,

            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF3F245F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SELECCIONAR TRABAJO
// ============================================================

class _SeleccionarTrabajoDialog extends StatelessWidget {
  final List<Map<String, dynamic>> trabajos;
  final Function(Map<String, dynamic>) onSeleccionar;

  const _SeleccionarTrabajoDialog({
    required this.trabajos,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Seleccionar trabajo',
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3F245F)),
      ),

      content: SizedBox(
        width: double.maxFinite,

        child: ListView.builder(
          shrinkWrap: true,
          itemCount: trabajos.length,

          itemBuilder: (context, index) {
            final trabajo = trabajos[index];

            final nombre = (trabajo['nombreCliente'] ?? 'Cliente sin nombre')
                .toString();

            final estado = (trabajo['estado'] ?? 'PENDIENTE').toString();

            return Container(
              margin: const EdgeInsets.only(bottom: 8),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE3DCEB)),
              ),

              child: ListTile(
                onTap: () {
                  onSeleccionar(trabajo);
                },

                leading: Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E8F8),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: const Icon(
                    Icons.construction,
                    color: Color(0xFF6A35A8),
                  ),
                ),

                title: Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F245F),
                  ),
                ),

                subtitle: Text(
                  'Presupuesto Nº '
                  '${trabajo['numeroPresupuesto']}'
                  '\n$estado',
                ),

                isThreeLine: true,

                trailing: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            );
          },
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

// ============================================================
// SIN INSTALACIONES
// ============================================================

class _SinInstalaciones extends StatelessWidget {
  final DateTime fecha;
  final VoidCallback onAgregar;

  const _SinInstalaciones({required this.fecha, required this.onAgregar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 65,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            const Text(
              'No hay instalaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F245F),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'No tienes instalaciones '
              'programadas para este día.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: onAgregar,

              icon: const Icon(Icons.add),

              label: const Text('Programar instalación'),

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
// SIN PRÓXIMAS
// ============================================================

class _SinProximas extends StatelessWidget {
  const _SinProximas();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.event_available, size: 65, color: Color(0xFFD0CBD5)),

            SizedBox(height: 16),

            Text(
              'No hay próximas instalaciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F245F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
