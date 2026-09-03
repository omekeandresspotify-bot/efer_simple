import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

// ============================================================
// MODELO DEL PRODUCTO PARA LA IMAGEN
// ============================================================

class ProductoImagen {
  final String producto;
  final double ancho;
  final double ancho2;
  final double alto;
  final double cantidad;
  final double metrosCuadrados;
  final double precioM2;
  final double total;

  ProductoImagen({
    required this.producto,
    required this.ancho,
    required this.ancho2,
    required this.alto,
    required this.cantidad,
    required this.metrosCuadrados,
    required this.precioM2,
    required this.total,
  });
}

// ============================================================
// PANTALLA PRESUPUESTO
// ============================================================

class PresupuestoImagen extends StatefulWidget {
  final int numero;
  final String fecha;
  final String hora;

  final String nombreCliente;
  final String telefono;
  final String correo;
  final String direccion;
  final String color;

  final double subtotal;
  final double descuento;
  final String descuentoTipo;
  final double neto;
  final bool aplicarIva;
  final double iva;
  final double total;
  final String observacionesAdicionales;

  final List<ProductoImagen> productos;

  const PresupuestoImagen({
    super.key,
    required this.numero,
    required this.fecha,
    required this.hora,
    required this.nombreCliente,
    required this.telefono,
    required this.correo,
    required this.direccion,
    this.color = 'MATE',
    required this.subtotal,
    this.descuento = 0,
    this.descuentoTipo = 'NINGUNO',
    this.neto = 0,
    this.aplicarIva = true,
    required this.iva,
    required this.total,
    this.observacionesAdicionales = '',
    required this.productos,
  });

  @override
  State<PresupuestoImagen> createState() => _PresupuestoImagenState();
}

class _PresupuestoImagenState extends State<PresupuestoImagen> {
  final GlobalKey _imagenKey = GlobalKey();

  bool generando = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        generarImagen();
      }
    });
  }

  // ==========================================================
  // FORMATO DINERO
  // ==========================================================

  String dinero(double valor) {
    final absoluto = valor.abs();
    final texto = '\$${absoluto.toStringAsFixed(0)}'.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );

    return valor < 0 ? '-$texto' : texto;
  }

  // ==========================================================
  // CAPTURAR DOCUMENTO COMO PNG
  // ==========================================================

  Future<Uint8List?> capturarImagen() async {
    try {
      // Esperar a que Flutter termine de pintar completamente
      await WidgetsBinding.instance.endOfFrame;

      // Dar un pequeño margen adicional para iOS
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) {
        debugPrint('La pantalla ya no está montada');
        return null;
      }

      final renderObject = _imagenKey.currentContext?.findRenderObject();

      if (renderObject == null) {
        debugPrint('No se encontró el RenderObject de la imagen');
        return null;
      }

      if (renderObject is! RenderRepaintBoundary) {
        debugPrint('El objeto no es RenderRepaintBoundary');
        return null;
      }

      final boundary = renderObject;

      // Esperar hasta que el widget esté pintado
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final image = await boundary.toImage(pixelRatio: 2.0);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      image.dispose();

      if (byteData == null) {
        debugPrint('No se pudo obtener PNG');
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e, stackTrace) {
      debugPrint('Error generando imagen: $e');
      debugPrint('$stackTrace');

      return null;
    }
  }

  // ==========================================================
  // COMPARTIR
  // ==========================================================

  Future<void> compartirImagen() async {
    if (generando) return;

    setState(() {
      generando = true;
    });

    try {
      final bytes = await capturarImagen();

      if (bytes == null) {
        throw Exception('No se pudo generar la imagen');
      }

      final archivo = XFile.fromData(
        bytes,
        mimeType: 'image/png',
        name: 'Presupuesto_EFER_${widget.numero}.png',
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [archivo],
          title: 'Presupuesto EFER Nº ${widget.numero}',
          text: 'Presupuesto EFER Nº ${widget.numero}',
          fileNameOverrides: ['Presupuesto_EFER_${widget.numero}.png'],
          downloadFallbackEnabled: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo compartir: $e')));
    }

    if (!mounted) return;

    setState(() {
      generando = false;
    });
  }

  // ==========================================================
  // GENERAR IMAGEN
  // ==========================================================

  Future<void> generarImagen() async {
    if (generando) return;

    setState(() {
      generando = true;
    });

    try {
      final bytes = await capturarImagen();

      if (bytes == null) {
        throw Exception('No se pudo generar la imagen');
      }

      final archivo = XFile.fromData(
        bytes,
        mimeType: 'image/png',
        name: 'Presupuesto_EFER_${widget.numero}.png',
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [archivo],
          title: 'Presupuesto EFER Nº ${widget.numero}',
          fileNameOverrides: ['Presupuesto_EFER_${widget.numero}.png'],
          downloadFallbackEnabled: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error generando imagen: $e')));
    }

    if (!mounted) return;

    setState(() {
      generando = false;
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7E9),

      appBar: AppBar(
        backgroundColor: const Color(0xFF123B5D),

        foregroundColor: Colors.white,

        title: const Text(
          'Presupuesto EFER',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // ==================================================
          // VISTA PREVIA
          // ==================================================

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),

              child: LayoutBuilder(
                builder: (context, constraints) {
                  final anchoPantalla = constraints.maxWidth;

                  if (anchoPantalla < 850) {
                    return Center(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter,
                        child: RepaintBoundary(
                          key: _imagenKey,
                          child: Container(
                            width: 800,
                            color: Colors.white,
                            child: _documento(),
                          ),
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: RepaintBoundary(
                      key: _imagenKey,
                      child: Container(
                        width: 800,
                        color: Colors.white,
                        child: _documento(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ==================================================
          // BOTONES
          // ==================================================
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),

            decoration: const BoxDecoration(
              color: Colors.white,

              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),

            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: generando
                          ? null
                          : () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },

                      icon: const Icon(Icons.home),

                      label: const Text('INICIO'),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF123B5D),

                        side: const BorderSide(
                          color: Color(0xFF123B5D),
                          width: 1.5,
                        ),

                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: generando ? null : compartirImagen,

                      icon: generando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.share),

                      label: Text(
                        generando ? 'GENERANDO...' : 'ENVIAR POR WHATSAPP',
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF123B5D),

                        foregroundColor: Colors.white,

                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DOCUMENTO COMPLETO
  // ==========================================================

  Widget _documento() {
    return Column(
      children: [
        // ======================================================
        // ENCABEZADO
        // ======================================================

        Container(
          height: 245,

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,

              colors: [Color(0xFFF8FAFC), Color(0xFFEAF2F8)],
            ),
          ),

          child: Row(
            children: [
              // ------------------------------------------------
              // MARCA EFER
              // ------------------------------------------------

              Expanded(
                flex: 5,

                child: Padding(
                  padding: const EdgeInsets.only(left: 38),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Container(
                            width: 75,
                            height: 75,

                            decoration: BoxDecoration(
                              color: const Color(0xFF123B5D),

                              borderRadius: BorderRadius.circular(8),
                            ),

                            child: const Icon(
                              Icons.window,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),

                          const SizedBox(width: 16),

                          const Text(
                            'EFER',
                            style: TextStyle(
                              fontSize: 58,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF123B5D),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      const Padding(
                        padding: EdgeInsets.only(left: 91),

                        child: Text(
                          'VIDRIOS & ALUMINIOS',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF123B5D),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      const Padding(
                        padding: EdgeInsets.only(left: 91),

                        child: Text(
                          'CALIDAD  •  DISEÑO  •  CONFIANZA',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2F80C0),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ------------------------------------------------
              // IMAGEN DECORATIVA
              // ------------------------------------------------
              Expanded(
                flex: 4,

                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 18,
                  ),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),

                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,

                      end: Alignment.bottomRight,

                      colors: [Color(0xFF123B5D), Color(0xFF2F80C0)],
                    ),
                  ),

                  child: const Center(
                    child: Icon(Icons.home_work, color: Colors.white, size: 90),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // TITULO PRESUPUESTO
        // ======================================================
        Container(
          height: 70,

          padding: const EdgeInsets.symmetric(horizontal: 30),

          color: const Color(0xFF123B5D),

          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'PRESUPUESTO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),

                child: Text(
                  'Nº ${widget.numero}',
                  style: const TextStyle(
                    color: Color(0xFF123B5D),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),

                child: Text(
                  'COLOR: ${widget.color}',
                  style: const TextStyle(
                    color: Color(0xFF123B5D),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Text(
                'FECHA: ${widget.fecha}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // DATOS
        // ======================================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: _bloqueDatos(
                  titulo: 'DATOS DEL CLIENTE',

                  icono: Icons.person,

                  datos: [
                    'Nombre: ${widget.nombreCliente}',
                    'Teléfono: ${widget.telefono}',
                    'Correo: ${widget.correo}',
                    'Dirección: ${widget.direccion}',
                  ],
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: _bloqueDatos(
                  titulo: 'PROYECTO / OBRA',

                  icono: Icons.home,

                  datos: [
                    'Dirección: ${widget.direccion}',
                    'Referencia: Presupuesto Nº ${widget.numero}',
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ======================================================
        // TABLA
        // ======================================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),

                color: const Color(0xFF123B5D),

                child: const Row(
                  children: [
                    SizedBox(width: 35, child: Text('Nº', style: _headerStyle)),

                    Expanded(
                      flex: 4,
                      child: Text('DESCRIPCIÓN', style: _headerStyle),
                    ),

                    Expanded(
                      flex: 3,
                      child: Text(
                        'MEDIDA / CARACTERÍSTICAS',
                        style: _headerStyle,
                      ),
                    ),

                    SizedBox(
                      width: 55,
                      child: Text(
                        'CANT.',
                        textAlign: TextAlign.center,
                        style: _headerStyle,
                      ),
                    ),

                    SizedBox(
                      width: 105,
                      child: Text(
                        'VALOR UNIT.',
                        textAlign: TextAlign.right,
                        style: _headerStyle,
                      ),
                    ),

                    SizedBox(
                      width: 115,
                      child: Text(
                        'VALOR TOTAL',
                        textAlign: TextAlign.right,
                        style: _headerStyle,
                      ),
                    ),
                  ],
                ),
              ),

              ...List.generate(
                widget.productos.length,
                (index) => _filaProducto(index, widget.productos[index]),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ======================================================
        // OBSERVACIONES + TOTALES
        // ======================================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(child: _observaciones()),

              const SizedBox(width: 18),

              SizedBox(width: 310, child: _totales()),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // ======================================================
        // INFORMACION COMERCIAL
        // ======================================================
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),

          padding: const EdgeInsets.only(top: 18, bottom: 20),

          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFD1D9DF))),
          ),

          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: _ListaInformacion(
                  titulo: 'INCLUYE',
                  icono: Icons.check_circle,
                  items: [
                    'Medición y asesoría técnica.',
                    'Fabricación e instalación.',
                    'Materiales de primera calidad.',
                    'Terminaciones profesionales.',
                  ],
                ),
              ),

              Expanded(
                child: _ListaInformacion(
                  titulo: 'NUESTROS TRABAJOS',
                  icono: Icons.grid_view,
                  items: [
                    'Ventanas y puertas de aluminio.',
                    'Termopanel.',
                    'Mamparas y barandas de vidrio.',
                    'Cierres de terrazas.',
                    'Vidrios a medida.',
                  ],
                ),
              ),

              Expanded(
                child: _ListaInformacion(
                  titulo: 'CONDICIONES',
                  icono: Icons.description,
                  items: [
                    'Validez del presupuesto: 30 días.',
                    'Plazo de ejecución: A coordinar.',
                    'Forma de pago: A convenir.',
                    'Garantía según instalación.',
                  ],
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // ACEPTACION
        // ======================================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),

          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.handshake,
                          color: Color(0xFF123B5D),
                          size: 25,
                        ),

                        SizedBox(width: 8),

                        Text(
                          'ACEPTACIÓN DEL CLIENTE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF123B5D),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Container(height: 1, color: const Color(0xFF9DAAB4)),

                    const SizedBox(height: 6),

                    const Text(
                      'Nombre, Firma y Fecha',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 70),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    SizedBox(height: 50),

                    Text(
                      'EFER Vidrios & Aluminios',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF123B5D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // PIE AZUL
        // ======================================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),

          decoration: const BoxDecoration(
            color: Color(0xFF123B5D),

            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),

          child: Row(
            children: [
              const Expanded(
                child: _Contacto(icono: Icons.phone, texto: '+56 9 4516 5621'),
              ),

              const Expanded(
                child: _Contacto(
                  icono: Icons.camera_alt,
                  texto: 'efer_vidrios_y_aluminios',
                ),
              ),

              const Expanded(
                child: _Contacto(
                  icono: Icons.location_on,
                  texto: 'Pumanque, Chile',
                ),
              ),

              const Text(
                'Tu proyecto,\nen las mejores manos.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // BLOQUE CLIENTE
  // ==========================================================

  Widget _bloqueDatos({
    required String titulo,
    required IconData icono,
    required List<String> datos,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FA),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: const Color(0xFFD4DDE4)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(icono, color: const Color(0xFF123B5D), size: 23),

              const SizedBox(width: 8),

              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123B5D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...datos.map(
            (dato) => Padding(
              padding: const EdgeInsets.only(bottom: 7),

              child: Text(
                dato,
                style: const TextStyle(fontSize: 13, color: Color(0xFF263746)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILA PRODUCTO
  // ==========================================================

  Widget _filaProducto(int index, ProductoImagen producto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 13),

      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFF6F8FA),

        border: const Border(
          left: BorderSide(color: Color(0xFFD4DDE4)),
          right: BorderSide(color: Color(0xFFD4DDE4)),
          bottom: BorderSide(color: Color(0xFFD4DDE4)),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 35,

            child: Text(
              '${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),

          Expanded(
            flex: 4,

            child: Text(
              producto.producto,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263746),
              ),
            ),
          ),

          Expanded(
            flex: 3,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  (producto.producto == 'Shower Door Esquinero' ||
                          producto.producto == 'Shower Door 2 hojas con fijo')
                      ? '${producto.ancho.toStringAsFixed(0)} × '
                            '${producto.ancho2.toStringAsFixed(0)} × '
                            '${producto.alto.toStringAsFixed(0)} mm'
                      : '${producto.ancho.toStringAsFixed(0)} × '
                            '${producto.alto.toStringAsFixed(0)} mm',

                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${producto.metrosCuadrados.toStringAsFixed(2)} m²',

                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 55,

            child: Text(
              producto.cantidad.toStringAsFixed(0),

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 13),
            ),
          ),

          SizedBox(
            width: 105,

            child: Text(
              dinero(
                producto.cantidad > 0
                    ? producto.total / producto.cantidad
                    : producto.total,
              ),

              textAlign: TextAlign.right,

              style: const TextStyle(fontSize: 12),
            ),
          ),

          SizedBox(
            width: 115,

            child: Text(
              dinero(producto.total),

              textAlign: TextAlign.right,

              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B5D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // OBSERVACIONES
  // ==========================================================

  Widget _observaciones() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FA),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: const Color(0xFFD4DDE4)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Row(
            children: [
              Icon(Icons.assignment, color: Color(0xFF123B5D), size: 23),

              SizedBox(width: 8),

              Text(
                'OBSERVACIONES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123B5D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text(
            '• Medidas rectificadas en terreno.',
            style: TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 7),

          const Text(
            '• Precios expresados en pesos chilenos.',
            style: TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 7),

          const Text(
            '• Presupuesto sujeto a confirmación.',
            style: TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 7),

          const Text(
            '• Cualquier modificación puede alterar '
            'los valores indicados.',
            style: TextStyle(fontSize: 12),
          ),

          if (widget.observacionesAdicionales.trim().isNotEmpty) ...[
            const SizedBox(height: 12),

            const Text(
              'OBSERVACIONES ADICIONALES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B5D),
              ),
            ),

            const SizedBox(height: 6),

            ...widget.observacionesAdicionales
                .trim()
                .split(RegExp(r'\r?\n'))
                .where((linea) => linea.trim().isNotEmpty)
                .map(
                  (linea) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '• ${linea.trim()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // TOTALES
  // ==========================================================

  Widget _totales() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2F8),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                _lineaTotal('SUBTOTAL', widget.subtotal),

                if (widget.descuento > 0) ...[
                  const SizedBox(height: 9),
                  _lineaTotal('DESCUENTO', -widget.descuento),
                  const SizedBox(height: 9),
                  _lineaTotal('NETO', widget.neto),
                ],

                const SizedBox(height: 9),

                _lineaTotal(
                  widget.aplicarIva ? 'IVA 19%' : 'IVA NO APLICADO',
                  widget.iva,
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

            decoration: const BoxDecoration(
              color: Color(0xFF123B5D),

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  dinero(widget.total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LINEA TOTAL
  // ==========================================================

  Widget _lineaTotal(String titulo, double valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF263746),
          ),
        ),

        Text(
          dinero(valor),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ============================================================
// ESTILO ENCABEZADO TABLA
// ============================================================

const TextStyle _headerStyle = TextStyle(
  color: Colors.white,
  fontSize: 10,
  fontWeight: FontWeight.bold,
);

// ============================================================
// LISTA INFORMACION
// ============================================================

class _ListaInformacion extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<String> items;

  const _ListaInformacion({
    required this.titulo,
    required this.icono,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(icono, color: const Color(0xFF123B5D), size: 22),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF123B5D),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),

              child: Text(
                '✓ $item',
                style: const TextStyle(fontSize: 10, color: Color(0xFF263746)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CONTACTO PIE
// ============================================================

class _Contacto extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _Contacto({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Colors.white, size: 20),

        const SizedBox(width: 8),

        Flexible(
          child: Text(
            texto,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
