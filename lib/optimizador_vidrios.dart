import 'package:flutter/material.dart';

// ==========================================================
// PIEZA DE VIDRIO PARA OPTIMIZAR
// ==========================================================

class PiezaVidrio {
  final String tipo;
  final int ancho;
  final int alto;
  final int cantidad;

  const PiezaVidrio({
    required this.tipo,
    required this.ancho,
    required this.alto,
    required this.cantidad,
  });
}

// ==========================================================
// RECTANGULO LIBRE
// ==========================================================

class RectanguloLibre {
  final int x;
  final int y;
  final int ancho;
  final int alto;

  const RectanguloLibre({
    required this.x,
    required this.y,
    required this.ancho,
    required this.alto,
  });
}

// ==========================================================
// PIEZA COLOCADA
// ==========================================================

class PiezaColocada {
  final String tipo;
  final int x;
  final int y;
  final int ancho;
  final int alto;

  const PiezaColocada({
    required this.tipo,
    required this.x,
    required this.y,
    required this.ancho,
    required this.alto,
  });
}

// ==========================================================
// PLANCHA OPTIMIZADA
// ==========================================================

class PlanchaVidrio {
  final String tipoPlancha;
  final int ancho;
  final int alto;

  final List<PiezaColocada> piezas;

  PlanchaVidrio({
    required this.tipoPlancha,
    required this.ancho,
    required this.alto,
    required this.piezas,
  });

  int get areaTotal => ancho * alto;

  int get areaUtilizada {
    return piezas.fold(0, (total, pieza) => total + pieza.ancho * pieza.alto);
  }

  int get areaDesperdicio {
    return areaTotal - areaUtilizada;
  }

  double get aprovechamiento {
    if (areaTotal == 0) {
      return 0;
    }

    return (areaUtilizada / areaTotal) * 100;
  }
}

// ==========================================================
// RESULTADO GENERAL
// ==========================================================

class ResultadoOptimizacion {
  final String tipoVidrio;
  final List<PlanchaVidrio> planchas;

  ResultadoOptimizacion({required this.tipoVidrio, required this.planchas});

  int get areaTotal {
    return planchas.fold(0, (total, plancha) => total + plancha.areaTotal);
  }

  int get areaUtilizada {
    return planchas.fold(0, (total, plancha) => total + plancha.areaUtilizada);
  }

  int get areaDesperdicio {
    return areaTotal - areaUtilizada;
  }

  double get aprovechamiento {
    if (areaTotal == 0) {
      return 0;
    }

    return (areaUtilizada / areaTotal) * 100;
  }
}

// ==========================================================
// OPTIMIZADOR DE VIDRIOS
// ==========================================================

class OptimizadorVidrios {
  // ========================================================
  // OPTIMIZAR
  // ========================================================

  static ResultadoOptimizacion optimizar({
    required String tipoVidrio,
    required int anchoPlancha,
    required int altoPlancha,
    required List<PiezaVidrio> piezas,
  }) {
    final piezasExpandida = <PiezaVidrio>[];

    for (final pieza in piezas) {
      for (int i = 0; i < pieza.cantidad; i++) {
        piezasExpandida.add(
          PiezaVidrio(
            tipo: pieza.tipo,
            ancho: pieza.ancho,
            alto: pieza.alto,
            cantidad: 1,
          ),
        );
      }
    }

    // Primero colocamos las piezas más grandes.
    piezasExpandida.sort((a, b) {
      final areaA = a.ancho * a.alto;
      final areaB = b.ancho * b.alto;

      return areaB.compareTo(areaA);
    });

    final planchas = <PlanchaVidrio>[];

    for (final pieza in piezasExpandida) {
      bool colocada = false;

      // Intentar colocar en una plancha existente.
      for (final plancha in planchas) {
        if (_intentarColocar(plancha, pieza)) {
          colocada = true;
          break;
        }
      }

      // Si no cabe en ninguna, crear una nueva.
      if (!colocada) {
        final nueva = PlanchaVidrio(
          tipoPlancha: tipoVidrio,
          ancho: anchoPlancha,
          alto: altoPlancha,
          piezas: [],
        );

        final pudoColocar = _intentarColocar(nueva, pieza);

        if (!pudoColocar) {
          throw ArgumentError(
            'La pieza ${pieza.ancho} × ${pieza.alto} '
            'no cabe en una plancha de '
            '$anchoPlancha × $altoPlancha mm.',
          );
        }

        planchas.add(nueva);
      }
    }

    return ResultadoOptimizacion(tipoVidrio: tipoVidrio, planchas: planchas);
  }

  // ========================================================
  // INTENTAR COLOCAR
  // ========================================================

  static bool _intentarColocar(PlanchaVidrio plancha, PiezaVidrio pieza) {
    // ======================================================
    // ORIENTACIONES POSIBLES
    // ======================================================

    final orientaciones = <List<int>>[
      [pieza.ancho, pieza.alto],
      [pieza.alto, pieza.ancho],
    ];

    // Evitar probar dos veces la misma orientación
    // cuando ancho y alto son iguales.
    final orientacionesUnicas = <String>{};

    for (final orientacion in orientaciones) {
      final ancho = orientacion[0];
      final alto = orientacion[1];

      final clave = '$ancho|$alto';

      if (!orientacionesUnicas.add(clave)) {
        continue;
      }

      // ====================================================
      // COMPROBAR QUE LA PIEZA CABE EN LA PLANCHA
      // ====================================================

      if (ancho > plancha.ancho || alto > plancha.alto) {
        continue;
      }

      // ====================================================
      // POSICIONES CANDIDATAS
      // ====================================================

      final posiciones = <List<int>>[
        [0, 0],
      ];

      // Probar a la derecha y debajo de cada pieza
      // que ya esté colocada.
      for (final existente in plancha.piezas) {
        posiciones.add([existente.x + existente.ancho, existente.y]);

        posiciones.add([existente.x, existente.y + existente.alto]);
      }

      // ====================================================
      // PROBAR CADA POSICIÓN
      // ====================================================

      for (final posicion in posiciones) {
        final x = posicion[0];
        final y = posicion[1];

        // -----------------------------------------------
        // COMPROBAR LÍMITES DE LA PLANCHA
        // -----------------------------------------------

        if (x < 0 || y < 0) {
          continue;
        }

        if (x + ancho > plancha.ancho) {
          continue;
        }

        if (y + alto > plancha.alto) {
          continue;
        }

        // -----------------------------------------------
        // COMPROBAR SUPERPOSICIÓN
        // -----------------------------------------------

        bool seSuperpone = false;

        for (final existente in plancha.piezas) {
          final intersecta =
              x < existente.x + existente.ancho &&
              x + ancho > existente.x &&
              y < existente.y + existente.alto &&
              y + alto > existente.y;

          if (intersecta) {
            seSuperpone = true;
            break;
          }
        }

        if (seSuperpone) {
          continue;
        }

        // =================================================
        // ENCONTRAMOS UNA POSICIÓN VÁLIDA
        // =================================================

        plancha.piezas.add(
          PiezaColocada(tipo: pieza.tipo, x: x, y: y, ancho: ancho, alto: alto),
        );

        return true;
      }
    }

    return false;
  }
}
// ==========================================================
// PANTALLA OPTIMIZADOR DE VIDRIOS
// ==========================================================

class OptimizadorVidriosPage extends StatefulWidget {
  final int numero;
  final String nombreCliente;
  final List<PiezaVidrio> piezas;

  const OptimizadorVidriosPage({
    super.key,
    required this.numero,
    required this.nombreCliente,
    required this.piezas,
  });

  @override
  State<OptimizadorVidriosPage> createState() => _OptimizadorVidriosPageState();
}

class _OptimizadorVidriosPageState extends State<OptimizadorVidriosPage> {
  String formatoSeleccionado = '2500 × 1800';

  ResultadoOptimizacion? resultado;

  int get anchoPlancha {
    switch (formatoSeleccionado) {
      case '2500 × 3600':
        return 2500;
      case '1600 × 2500':
        return 1600;
      default:
        return 2500;
    }
  }

  int get altoPlancha {
    switch (formatoSeleccionado) {
      case '2500 × 3600':
        return 3600;
      case '1600 × 2500':
        return 2500;
      default:
        return 1800;
    }
  }

  void optimizar() {
    try {
      final nuevoResultado = OptimizadorVidrios.optimizar(
        tipoVidrio: widget.piezas.first.tipo,
        anchoPlancha: anchoPlancha,
        altoPlancha: altoPlancha,
        piezas: widget.piezas,
      );

      setState(() {
        resultado = nuevoResultado;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo optimizar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Optimizar cortes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF123B5D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRESUPUESTO Nº ${widget.numero}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B5D),
              ),
            ),

            const SizedBox(height: 5),

            Text(widget.nombreCliente, style: const TextStyle(fontSize: 15)),

            const SizedBox(height: 25),

            const Text(
              'FORMATO DE PLANCHA',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B5D),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: formatoSeleccionado,
              decoration: InputDecoration(
                labelText: 'Plancha de vidrio',
                prefixIcon: const Icon(Icons.crop_square),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: '2500 × 1800',
                  child: Text('2500 × 1800 mm'),
                ),
                DropdownMenuItem(
                  value: '2500 × 3600',
                  child: Text('2500 × 3600 mm'),
                ),
                DropdownMenuItem(
                  value: '1600 × 2500',
                  child: Text('1600 × 2500 mm'),
                ),
              ],
              onChanged: (valor) {
                if (valor == null) return;

                setState(() {
                  formatoSeleccionado = valor;
                  resultado = null;
                });
              },
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: optimizar,
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  'OPTIMIZAR CORTES',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF123B5D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'VIDRIOS A CORTAR',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B5D),
              ),
            ),

            const SizedBox(height: 10),

            ...widget.piezas.map((pieza) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.window),
                  title: Text(pieza.tipo),
                  subtitle: Text('${pieza.ancho} × ${pieza.alto} mm'),
                  trailing: Text(
                    '× ${pieza.cantidad}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }),

            if (resultado != null) ...[
              const SizedBox(height: 25),

              const Text(
                'RESULTADO',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123B5D),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Planchas necesarias'),
                          Text(
                            '${resultado!.planchas.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Aprovechamiento'),
                          Text(
                            '${resultado!.aprovechamiento.toStringAsFixed(1)} %',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Desperdicio'),
                          Text(
                            '${resultado!.areaDesperdicio} mm²',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              ...List.generate(resultado!.planchas.length, (index) {
                final plancha = resultado!.planchas[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PLANCHA ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF123B5D),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          '${plancha.ancho} × '
                          '${plancha.alto} mm',
                        ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,
                          height: 300,
                          child: CustomPaint(
                            painter: PlanchaVidrioPainter(plancha: plancha),
                          ),
                        ),

                        const SizedBox(height: 15),

                        const SizedBox(height: 8),

                        Text(
                          'Aprovechamiento: '
                          '${plancha.aprovechamiento.toStringAsFixed(1)} %',
                        ),

                        const SizedBox(height: 10),

                        ...plancha.piezas.map((pieza) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(
                              '• ${pieza.tipo} — '
                              '${pieza.ancho} × '
                              '${pieza.alto} mm '
                              '(${pieza.x}, ${pieza.y})',
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
// ==========================================================
// DIBUJO DE PLANCHA DE VIDRIO
// ==========================================================

class PlanchaVidrioPainter extends CustomPainter {
  final PlanchaVidrio plancha;

  PlanchaVidrioPainter({required this.plancha});

  @override
  void paint(Canvas canvas, Size size) {
    // ======================================================
    // ESCALA PARA QUE LA PLANCHA ENTRE COMPLETA
    // ======================================================

    final escalaX = size.width / plancha.ancho;
    final escalaY = size.height / plancha.alto;

    final escala = escalaX < escalaY ? escalaX : escalaY;

    final anchoPlancha = plancha.ancho * escala;
    final altoPlancha = plancha.alto * escala;

    final offsetX = (size.width - anchoPlancha) / 2;
    final offsetY = (size.height - altoPlancha) / 2;

    // ======================================================
    // FONDO DE LA PLANCHA
    // ======================================================

    final fondoPlancha = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE9EEF2);

    final bordePlancha = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF123B5D);

    final rectPlancha = Rect.fromLTWH(
      offsetX,
      offsetY,
      anchoPlancha,
      altoPlancha,
    );

    canvas.drawRect(rectPlancha, fondoPlancha);

    canvas.drawRect(rectPlancha, bordePlancha);

    // ======================================================
    // DIBUJAR CADA VIDRIO
    // ======================================================

    for (int i = 0; i < plancha.piezas.length; i++) {
      final pieza = plancha.piezas[i];

      final x = offsetX + pieza.x * escala;
      final y = offsetY + pieza.y * escala;

      final ancho = pieza.ancho * escala;
      final alto = pieza.alto * escala;

      final rectVidrio = Rect.fromLTWH(x, y, ancho, alto);

      // -----------------------------------------------
      // VIDRIO
      // -----------------------------------------------

      final fondoVidrio = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFDDECF5);

      final bordeVidrio = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF123B5D);

      canvas.drawRect(rectVidrio, fondoVidrio);

      canvas.drawRect(rectVidrio, bordeVidrio);

      // =================================================
      // NÚMERO DE PIEZA
      // =================================================

      final textoNumero = '#${i + 1}';

      final painterNumero = TextPainter(
        text: TextSpan(
          text: textoNumero,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF123B5D),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      painterNumero.layout();

      if (ancho > 35 && alto > 25) {
        painterNumero.paint(canvas, Offset(x + 5, y + 5));
      }

      // =================================================
      // MEDIDA DEL VIDRIO
      // =================================================

      if (ancho > 90 && alto > 45) {
        final textoMedida = '${pieza.ancho} × ${pieza.alto}';

        final painterMedida = TextPainter(
          text: TextSpan(
            text: textoMedida,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123B5D),
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        painterMedida.layout();

        painterMedida.paint(
          canvas,
          Offset(
            x + (ancho - painterMedida.width) / 2,
            y + (alto - painterMedida.height) / 2,
          ),
        );
      }
    }

    // ======================================================
    // MEDIDA DE LA PLANCHA
    // ======================================================

    final textoPlancha = '${plancha.ancho} × ${plancha.alto} mm';

    final painterPlancha = TextPainter(
      text: TextSpan(
        text: textoPlancha,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF123B5D),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painterPlancha.layout();

    painterPlancha.paint(canvas, Offset(offsetX, offsetY + altoPlancha + 8));
  }

  @override
  bool shouldRepaint(covariant PlanchaVidrioPainter oldDelegate) {
    return oldDelegate.plancha != plancha;
  }
}
