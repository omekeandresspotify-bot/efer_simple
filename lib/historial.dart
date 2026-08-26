import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'database.dart';
import 'presupuesto_imagen.dart';
import 'pauta_fabricacion.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  List<Map<String, dynamic>> presupuestos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  // ==========================================================
  // CARGAR HISTORIAL
  // ==========================================================

  Future<void> cargarHistorial() async {
    try {
      final datos = await EferDatabase.instance.obtenerPresupuestos();

      if (!mounted) return;

      setState(() {
        presupuestos = datos;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando historial: $e')));
    }
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
  // MEDIDA
  // ==========================================================

  String medida(double? ancho, double? alto) {
    if (ancho != null && alto != null) {
      return '${ancho.toStringAsFixed(0)} × '
          '${alto.toStringAsFixed(0)}';
    }

    if (ancho != null) {
      return ancho.toStringAsFixed(0);
    }

    if (alto != null) {
      return alto.toStringAsFixed(0);
    }

    return '-';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),

      appBar: AppBar(
        backgroundColor: const Color(0xFF123B5D),
        foregroundColor: Colors.white,

        title: const Text(
          'Historial',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: cargarHistorial,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : presupuestos.isEmpty
          ? _sinPresupuestos()
          : RefreshIndicator(
              onRefresh: cargarHistorial,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: presupuestos.length,
                itemBuilder: (context, index) {
                  return _tarjeta(presupuestos[index]);
                },
              ),
            ),
    );
  }

  // ==========================================================
  // SIN PRESUPUESTOS
  // ==========================================================

  Widget _sinPresupuestos() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),

            const SizedBox(height: 20),

            const Text(
              'No hay presupuestos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B5D),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Los presupuestos que generes '
              'aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TARJETA HISTORIAL
  // ==========================================================

  Widget _tarjeta(Map<String, dynamic> presupuesto) {
    final numero = presupuesto['numero'] as int;

    final nombre = presupuesto['nombreCliente'] as String;

    final color = (presupuesto['color'] as String?) ?? 'MATE';

    final fecha = presupuesto['fecha'] as String;

    final hora = presupuesto['hora'] as String;

    final total = (presupuesto['total'] as num).toDouble();

    final aceptado = (presupuesto['aceptado'] ?? 0) == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),

      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: () {
          abrirPresupuesto(presupuesto);
        },

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,

                    decoration: BoxDecoration(
                      color: aceptado
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFEAF2F8),

                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Icon(
                      aceptado ? Icons.check_circle : Icons.receipt_long,

                      color: aceptado
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF123B5D),

                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'PRESUPUESTO Nº $numero',

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF123B5D),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          nombre,

                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'COLOR: $color',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF123B5D),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '$fecha • $hora',

                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),

              const SizedBox(height: 15),

              const Divider(height: 1),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: aceptado
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF3CD),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [
                        Icon(
                          aceptado
                              ? Icons.check_circle
                              : Icons.pending_outlined,

                          size: 17,

                          color: aceptado
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF9A7200),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          aceptado ? 'ACEPTADO' : 'PENDIENTE',

                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: aceptado
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF9A7200),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    dinero(total),

                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123B5D),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (!aceptado)
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      marcarComoAceptado(numero);
                    },

                    icon: const Icon(Icons.check_circle_outline),

                    label: const Text(
                      'MARCAR COMO ACEPTADO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 14),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              if (aceptado) ...[
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(vertical: 13),

                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: const Color(0xFFB7DDB9)),
                  ),

                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF2E7D32)),

                      SizedBox(width: 8),

                      Text(
                        'PRESUPUESTO ACEPTADO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      abrirFichaFabricacion(presupuesto);
                    },

                    icon: const Icon(Icons.precision_manufacturing),

                    label: const Text(
                      'FICHA DE FABRICACIÓN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF123B5D),

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 14),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MARCAR ACEPTADO
  // ==========================================================

  Future<void> marcarComoAceptado(int numero) async {
    try {
      await EferDatabase.instance.marcarAceptado(numero);

      if (!mounted) return;

      await cargarHistorial();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2E7D32),

          content: Text(
            'Presupuesto Nº $numero '
            'marcado como ACEPTADO.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ==========================================================
  // ABRIR PRESUPUESTO
  // ==========================================================

  Future<void> abrirPresupuesto(Map<String, dynamic> presupuesto) async {
    try {
      final id = presupuesto['id'] as int;

      final productos = await EferDatabase.instance.obtenerProductos(id);

      if (!mounted) return;

      final lista = productos.map((producto) {
        return ProductoImagen(
          producto: producto['producto'] as String,

          ancho: (producto['ancho'] as num).toDouble(),

          alto: (producto['alto'] as num).toDouble(),

          cantidad: (producto['cantidad'] as num).toDouble(),

          metrosCuadrados: (producto['metrosCuadrados'] as num).toDouble(),

          precioM2: (producto['precioM2'] as num).toDouble(),

          total: (producto['total'] as num).toDouble(),
        );
      }).toList();

      if (!mounted) return;

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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el presupuesto: $e')),
      );
    }
  }

  // ==========================================================
  // ABRIR FICHA DE FABRICACIÓN
  // ==========================================================

  Future<void> abrirFichaFabricacion(Map<String, dynamic> presupuesto) async {
    try {
      final id = presupuesto['id'] as int;

      final productos = await EferDatabase.instance.obtenerProductos(id);

      if (!mounted) return;

      final resultados = <ResultadoFabricacion>[];

      for (final producto in productos) {
        final nombre = producto['producto'] as String;

        final ancho = (producto['ancho'] as num).toDouble();

        final alto = (producto['alto'] as num).toDouble();

        final cantidad = (producto['cantidad'] as num).round();

        try {
          final resultado = PautaFabricacion.generar(
            producto: nombre,
            ancho: ancho,
            alto: alto,
            cantidadVentanas: cantidad,
          );

          resultados.add(resultado);
        } catch (_) {
          // Producto sin pauta.
        }
      }

      if (!mounted) return;

      if (resultados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No hay pautas de fabricación '
              'disponibles para este presupuesto.',
            ),
          ),
        );

        return;
      }

      Navigator.push(
        context,

        MaterialPageRoute(
          builder: (_) => FichaFabricacionPage(
            numero: presupuesto['numero'] as int,

            fecha: presupuesto['fecha'] as String,

            nombreCliente: presupuesto['nombreCliente'] as String,

            color: (presupuesto['color'] as String?) ?? 'MATE',

            resultados: resultados,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo generar la ficha: $e')),
      );
    }
  }
}

// ============================================================
// FICHA DE FABRICACIÓN
// ============================================================

class FichaFabricacionPage extends StatelessWidget {
  final int numero;
  final String fecha;
  final String nombreCliente;
  final String color;
  final List<ResultadoFabricacion> resultados;

  const FichaFabricacionPage({
    super.key,
    required this.numero,
    required this.fecha,
    required this.nombreCliente,
    required this.color,
    required this.resultados,
  });

  // ==========================================================
  // MEDIDA
  // ==========================================================

  String medida(double? ancho, double? alto) {
    if (ancho != null && alto != null) {
      return '${ancho.toStringAsFixed(0)} × '
          '${alto.toStringAsFixed(0)}';
    }

    if (ancho != null) {
      return ancho.toStringAsFixed(0);
    }

    if (alto != null) {
      return alto.toStringAsFixed(0);
    }

    return '-';
  }

  // ==========================================================
  // TEXTO PARA COMPARTIR
  // ==========================================================

  String textoCompartir() {
    final buffer = StringBuffer();

    buffer.writeln('EFER - FICHA DE FABRICACIÓN');

    buffer.writeln('Presupuesto Nº $numero');

    buffer.writeln('Cliente: $nombreCliente');

    buffer.writeln('Color: $color');

    buffer.writeln('Fecha: $fecha');

    buffer.writeln();
    buffer.writeln('================================');

    for (final resultado in resultados) {
      buffer.writeln();
      buffer.writeln(resultado.producto.toUpperCase());

      buffer.writeln(
        'Medida: '
        '${resultado.anchoVentana.toStringAsFixed(0)}'
        ' x '
        '${resultado.altoVentana.toStringAsFixed(0)} mm',
      );

      buffer.writeln(
        'Cantidad: '
        '${resultado.cantidadVentanas}',
      );

      buffer.writeln();
      buffer.writeln('PIEZA | CORTE | CANT.');

      buffer.writeln('--------------------------------');

      for (final corte in resultado.cortes) {
        final corteMedida = medida(corte.ancho, corte.alto);

        buffer.writeln(
          '${corte.pieza} | '
          '$corteMedida mm | '
          '${corte.cantidad}',
        );
      }

      buffer.writeln('================================');
    }

    return buffer.toString();
  }

  // ==========================================================
  // COMPARTIR
  // ==========================================================

  Future<void> compartirFicha(BuildContext context) async {
    try {
      final texto = textoCompartir();

      await SharePlus.instance.share(
        ShareParams(text: texto, subject: 'Ficha de fabricación Nº $numero'),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo compartir la ficha: $e')),
      );
    }
  }

  // ==========================================================
  // CELDA PDF
  // ==========================================================

  pw.Widget celdaPdf(
    String texto, {
    bool negrita = false,
    bool centrado = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),

      child: pw.Text(
        texto,

        textAlign: centrado ? pw.TextAlign.center : pw.TextAlign.left,

        style: pw.TextStyle(
          fontSize: 8,

          fontWeight: negrita ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ==========================================================
  // IMPRIMIR CARTA
  // ==========================================================

  Future<void> imprimirFicha(BuildContext context) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.letter,

          margin: const pw.EdgeInsets.fromLTRB(28, 25, 28, 25),

          header: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 8),

              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                children: [
                  pw.Text(
                    'EFER',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.Text(
                    'FICHA DE FABRICACIÓN',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },

          footer: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.only(top: 8),

              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                children: [
                  pw.Text(
                    'Presupuesto Nº $numero',

                    style: const pw.TextStyle(fontSize: 8),
                  ),

                  pw.Text(
                    'Página ${context.pageNumber}',

                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            );
          },

          build: (context) {
            return [
              // ============================================
              // DATOS PRINCIPALES
              // ============================================

              pw.Container(
                padding: const pw.EdgeInsets.all(8),

                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.8),

                  borderRadius: pw.BorderRadius.circular(5),
                ),

                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,

                        children: [
                          pw.Text(
                            'COLOR: $color',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'CLIENTE',

                            style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),

                          pw.SizedBox(height: 2),

                          pw.Text(
                            nombreCliente,

                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),

                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,

                      children: [
                        pw.Text(
                          'FECHA',

                          style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.SizedBox(height: 2),

                        pw.Text(fecha, style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ============================================
              // VENTANAS
              // ============================================
              ...resultados.map((resultado) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 9),

                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,

                    children: [
                      // ----------------------------------
                      // ENCABEZADO VENTANA
                      // ----------------------------------

                      pw.Container(
                        width: double.infinity,

                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),

                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.7),

                          borderRadius: pw.BorderRadius.only(
                            topLeft: pw.Radius.circular(4),

                            topRight: pw.Radius.circular(4),
                          ),
                        ),

                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                resultado.producto.toUpperCase(),

                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),

                            pw.Text(
                              '${resultado.anchoVentana.toStringAsFixed(0)}'
                              ' × '
                              '${resultado.altoVentana.toStringAsFixed(0)} mm',

                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),

                            pw.SizedBox(width: 10),

                            pw.Text(
                              'CANT: '
                              '${resultado.cantidadVentanas}',

                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ----------------------------------
                      // TABLA
                      // ----------------------------------
                      pw.Table(
                        border: pw.TableBorder.all(width: 0.5),

                        columnWidths: const {
                          0: pw.FlexColumnWidth(3),
                          1: pw.FlexColumnWidth(3),
                          2: pw.FixedColumnWidth(45),
                        },

                        children: [
                          pw.TableRow(
                            children: [
                              celdaPdf('PIEZA', negrita: true),

                              celdaPdf('CORTE (mm)', negrita: true),

                              celdaPdf('CANT.', negrita: true, centrado: true),
                            ],
                          ),

                          ...resultado.cortes.map((corte) {
                            return pw.TableRow(
                              children: [
                                celdaPdf(corte.pieza, negrita: true),

                                celdaPdf(medida(corte.ancho, corte.alto)),

                                celdaPdf(
                                  '${corte.cantidad}',
                                  centrado: true,
                                  negrita: true,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async {
          return pdf.save();
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo preparar la impresión: $e')),
      );
    }
  }

  // ==========================================================
  // BUILD FICHA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),

      appBar: AppBar(
        backgroundColor: const Color(0xFF123B5D),

        foregroundColor: Colors.white,

        title: const Text(
          'Ficha de fabricación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),

        children: [
          // ==================================================
          // ENCABEZADO
          // ==================================================

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

            decoration: BoxDecoration(
              color: const Color(0xFF123B5D),

              borderRadius: BorderRadius.circular(10),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.precision_manufacturing,
                  color: Colors.white,
                  size: 28,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'FICHA DE FABRICACIÓN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Nº $numero  •  $nombreCliente  •  COLOR: $color',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        fecha,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ==================================================
          // COMPARTIR
          // ==================================================
          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: () {
                compartirFicha(context);
              },

              icon: const Icon(Icons.share),

              label: const Text(
                'COMPARTIR FICHA',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),

                foregroundColor: Colors.white,

                padding: const EdgeInsets.symmetric(vertical: 13),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ==================================================
          // IMPRIMIR CARTA
          // ==================================================
          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: () {
                imprimirFicha(context);
              },

              icon: const Icon(Icons.print),

              label: const Text(
                'IMPRIMIR CARTA',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF123B5D),

                foregroundColor: Colors.white,

                padding: const EdgeInsets.symmetric(vertical: 13),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ==================================================
          // PRODUCTOS
          // ==================================================
          ...resultados.map((resultado) => _producto(resultado)),
        ],
      ),
    );
  }

  // ==========================================================
  // PRODUCTO COMPACTO
  // ==========================================================

  Widget _producto(ResultadoFabricacion resultado) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border.all(color: const Color(0xFFD8E0E6)),

        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        children: [
          // =================================================
          // NOMBRE + MEDIDA
          // =================================================

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),

            decoration: const BoxDecoration(
              color: Color(0xFFEAF2F8),

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),

                topRight: Radius.circular(10),
              ),
            ),

            child: Row(
              children: [
                Expanded(
                  child: Text(
                    resultado.producto,

                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123B5D),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  '${resultado.anchoVentana.toStringAsFixed(0)}'
                  ' × '
                  '${resultado.altoVentana.toStringAsFixed(0)}',

                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF123B5D),
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(6),
                  ),

                  child: Text(
                    '×${resultado.cantidadVentanas}',

                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =================================================
          // CABECERA TABLA
          // =================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),

            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFD8E0E6))),
            ),

            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'PIEZA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123B5D),
                    ),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Text(
                    'CORTE (mm)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123B5D),
                    ),
                  ),
                ),

                SizedBox(
                  width: 45,
                  child: Text(
                    'CANT.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123B5D),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =================================================
          // CORTES
          // =================================================
          ...resultado.cortes.map((corte) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),

              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE8EDF0))),
              ),

              child: Row(
                children: [
                  Expanded(
                    flex: 3,

                    child: Text(
                      corte.pieza,

                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 3,

                    child: Text(
                      medida(corte.ancho, corte.alto),

                      style: const TextStyle(fontSize: 11),
                    ),
                  ),

                  SizedBox(
                    width: 45,

                    child: Text(
                      '${corte.cantidad}',

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
