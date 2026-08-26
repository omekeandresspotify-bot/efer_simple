import 'package:flutter/material.dart';

import 'pauta_fabricacion.dart';

class PruebaFabricacionPage extends StatelessWidget {
  const PruebaFabricacionPage({super.key});

  String mostrarMedida(double? ancho, double? alto) {
    if (ancho != null && alto != null) {
      return '${ancho.toStringAsFixed(0)} × '
          '${alto.toStringAsFixed(0)} mm';
    }

    if (ancho != null) {
      return '${ancho.toStringAsFixed(0)} mm';
    }

    if (alto != null) {
      return '${alto.toStringAsFixed(0)} mm';
    }

    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final resultado = PautaFabricacion.generar(
      producto: 'Corredera 2 hojas 25 mono',
      ancho: 1200,
      alto: 1200,
      cantidadVentanas: 3,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF123B5D),
        foregroundColor: Colors.white,
        title: const Text(
          'Prueba de fabricación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF123B5D),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FICHA DE FABRICACIÓN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    resultado.producto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Medida: '
                    '${resultado.anchoVentana.toStringAsFixed(0)} × '
                    '${resultado.altoVentana.toStringAsFixed(0)} mm',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Cantidad: ${resultado.cantidadVentanas}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF2F8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'PIEZA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF123B5D),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'CORTE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF123B5D),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text(
                            'CANT.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF123B5D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ...resultado.cortes.map(
                    (corte) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE1E6EA)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              corte.pieza,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF263746),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(mostrarMedida(corte.ancho, corte.alto)),
                          ),
                          SizedBox(
                            width: 70,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${corte.cantidad}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFB7DDB9)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Prueba: Corredera 2 hojas 25 mono, '
                      '1200 × 1200 mm, cantidad 3.',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
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
