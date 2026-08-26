// ============================================================
// EFER - PAUTA MAESTRA DE FABRICACIÓN
// ============================================================

class CorteFabricacion {
  final String pieza;
  final double? ancho;
  final double? alto;
  final int cantidad;

  const CorteFabricacion({
    required this.pieza,
    this.ancho,
    this.alto,
    required this.cantidad,
  });
}

class ResultadoFabricacion {
  final String producto;
  final double anchoVentana;
  final double altoVentana;
  final int cantidadVentanas;
  final List<CorteFabricacion> cortes;

  const ResultadoFabricacion({
    required this.producto,
    required this.anchoVentana,
    required this.altoVentana,
    required this.cantidadVentanas,
    required this.cortes,
  });
}

class PautaFabricacion {
  // ==========================================================
  // GENERADOR PRINCIPAL
  // ==========================================================

  static ResultadoFabricacion generar({
    required String producto,
    required double ancho,
    required double alto,
    required int cantidadVentanas,
  }) {
    switch (producto) {
      case 'Corredera 2 hojas 25 mono':
        return _corredera2Mono(ancho, alto, cantidadVentanas);

      case 'Corredera 2 hojas 25 termo':
        return _corredera2Termo(ancho, alto, cantidadVentanas);

      case 'Corredera 2 hojas 5000':
        return _corredera25000(ancho, alto, cantidadVentanas);

      case 'Fija AL42 mono':
        return _fijaMono(ancho, alto, cantidadVentanas);

      case 'Fija AL42 termo':
        return _fijaTermo(ancho, alto, cantidadVentanas);

      case 'Proyectante AL42 mono':
        return _proyectanteMono(ancho, alto, cantidadVentanas);

      case 'Proyectante AL42 termo':
        return _proyectanteTermo(ancho, alto, cantidadVentanas);

      case 'Corredera 3 hojas 25 mono':
        return _corredera3Mono(ancho, alto, cantidadVentanas);

      case 'Corredera 3 hojas 25 termo':
        return _corredera3Termo(ancho, alto, cantidadVentanas);

      case 'Corredera 4 hojas 25 mono':
        return _corredera4Mono(ancho, alto, cantidadVentanas);

      case 'Corredera 4 hojas 25 termo':
        return _corredera4Termo(ancho, alto, cantidadVentanas);

      default:
        throw ArgumentError('Producto sin pauta de fabricación: $producto');
    }
  }

  // ==========================================================
  // CORREDERA 2 HOJAS 25 MONO
  // ==========================================================

  static ResultadoFabricacion _corredera2Mono(double a, double h, int q) {
    return ResultadoFabricacion(
      producto: 'Corredera 2 hojas 25 mono',
      anchoVentana: a,
      altoVentana: h,
      cantidadVentanas: q,
      cortes: [
        _c('RS', a - 16, null, 1, q),
        _c('RI', a - 16, null, 1, q),
        _c('JA', null, h, 2, q),
        _c('CA', a / 2 - 12, null, 2, q),
        _c('ZO', a / 2 - 12, null, 2, q),
        _c('PI', null, h - 35, 2, q),
        _c('TR', null, h - 35, 2, q),
        _c('CRISTAL', a / 2 - 66, h - 127, 2, q),
      ],
    );
  }

  // ==========================================================
  // CORREDERA 2 HOJAS 25 TERMO
  // ==========================================================

  static ResultadoFabricacion _corredera2Termo(double a, double h, int q) {
    return ResultadoFabricacion(
      producto: 'Corredera 2 hojas 25 termo',
      anchoVentana: a,
      altoVentana: h,
      cantidadVentanas: q,
      cortes: [
        _c('RS', a - 16, null, 1, q),
        _c('RI', a - 16, null, 1, q),
        _c('JA', null, h, 2, q),
        _c('CA', a / 2 - 12, null, 2, q),
        _c('ZO', a / 2 - 12, null, 2, q),
        _c('PI', null, h - 35, 2, q),
        _c('TR', null, h - 35, 2, q),
        _c('CRISTAL', a / 2 - 66, h - 130, 2, q),
      ],
    );
  }

  // ==========================================================
  // CORREDERA 2 HOJAS 5000
  // ==========================================================

  static ResultadoFabricacion _corredera25000(double a, double h, int q) {
    return ResultadoFabricacion(
      producto: 'Corredera 2 hojas 5000',
      anchoVentana: a,
      altoVentana: h,
      cantidadVentanas: q,
      cortes: [
        _c('RS', a, null, 1, q),
        _c('RI', a, null, 1, q),
        _c('JA', null, h - 3, 2, q),
        _c('CA', a / 2 - 3, null, 2, q),
        _c('ZO', a / 2 - 3, null, 2, q),
        _c('PI', null, h - 17, 2, q),
        _c('TR', null, h - 17, 2, q),
        _c('CRISTAL', a / 2 - 50, h - 84, 2, q),
      ],
    );
  }

  // ==========================================================
  // FIJA AL42 MONO
  // ==========================================================

  static ResultadoFabricacion _fijaMono(double a, double h, int q) {
    return ResultadoFabricacion(
      producto: 'Fija AL42 mono',
      anchoVentana: a,
      altoVentana: h,
      cantidadVentanas: q,
      cortes: [_c('MARCO', a, h, 2, q), _c('CRISTAL', a - 42, h - 42, 1, q)],
    );
  }

  // ==========================================================
  // FIJA AL42 TERMO
  // ==========================================================

  static ResultadoFabricacion _fijaTermo(double a, double h, int q) {
    return ResultadoFabricacion(
      producto: 'Fija AL42 termo',
      anchoVentana: a,
      altoVentana: h,
      cantidadVentanas: q,
      cortes: [_c('MARCO', a, h, 2, q), _c('CRISTAL', a - 42, h - 42, 1, q)],
    );
  }

  // ==========================================================
  // PROYECTANTE AL42 MONO
  // ==========================================================

  static ResultadoFabricacion _proyectanteMono(double a, double h, int q) {
    return ResultadoFabricacion(
      producto: 'Proyectante AL42 mono',
      anchoVentana: a,
      altoVentana: h,
      cantidadVentanas: q,
      cortes: [
        _c('MARCO', a, h, 2, q),
        _c('HOJA', a - 18, h - 18, 2, q),
        _c('CRISTAL', a - 100, h - 100, 1, q),
      ],
    );
  }

  // ==========================================================
  // PROYECTANTE AL42 TERMO
  // ==========================================================

  static ResultadoFabricacion _proyectanteTermo(double a, double h, int q) {
    return ResultadoFabricacion(
      producto: 'Proyectante AL42 termo',
      anchoVentana: a,
      altoVentana: h,
      cantidadVentanas: q,
      cortes: [
        _c('MARCO', a, h, 2, q),
        _c('HOJA', a - 18, h - 18, 2, q),
        _c('CRISTAL', a - 100, h - 100, 1, q),
      ],
    );
  }

  // ==========================================================
  // CORREDERA 3 HOJAS 25 MONO
  // ==========================================================

  static ResultadoFabricacion _corredera3Mono(double a, double h, int q) {
    return ResultadoFabricacion(
      producto: 'Corredera 3 hojas 25 mono',
      anchoVentana: a,
      altoVentana: h,
      cantidadVentanas: q,
      cortes: [
        _c('RS', a - 16, null, 1, q),
        _c('RI', a - 16, null, 1, q),
        _c('JA', null, h, 2, q),
        _c('CA', (a + 15) / 3, null, 3, q),
        _c('ZO', (a + 15) / 3, null, 3, q),
        _c('PI', null, h - 35, 2, q),
        _c('TR', null, h - 35, 4, q),
        _c('CRISTAL', (a - 144) / 3, h - 127, 3, q),
      ],
    );
  }

  // ==========================================================
  // CORREDERA 3 HOJAS 25 TERMO
  // ==========================================================

  static ResultadoFabricacion _corredera3Termo(double a, double h, int q) {
    return ResultadoFabricacion(
      producto: 'Corredera 3 hojas 25 termo',
      anchoVentana: a,
      altoVentana: h,
      cantidadVentanas: q,
      cortes: [
        _c('RS', a - 16, null, 1, q),
        _c('RI', a - 16, null, 1, q),
        _c('JA', null, h, 2, q),
        _c('CA', (a + 15) / 3, null, 3, q),
        _c('ZO', (a + 15) / 3, null, 3, q),
        _c('PI', null, h - 35, 2, q),
        _c('TR', null, h - 35, 4, q),
        _c('CRISTAL', (a - 144) / 3, h - 130, 3, q),
      ],
    );
  }

  // ==========================================================
  // CORREDERA 4 HOJAS 25 MONO
  // ==========================================================

  static ResultadoFabricacion _corredera4Mono(double a, double h, int q) {
    return ResultadoFabricacion(
      producto: 'Corredera 4 hojas 25 mono',
      anchoVentana: a,
      altoVentana: h,
      cantidadVentanas: q,
      cortes: [
        _c('RS', a - 16, null, 1, q),
        _c('RI', a - 16, null, 1, q),
        _c('JA', null, h, 2, q),
        _c('CA', (a - 32) / 4, null, 4, q),
        _c('ZO', (a - 32) / 4, null, 4, q),
        _c('PI', null, h - 35, 4, q),
        _c('TR', null, h - 35, 4, q),
        _c('CRISTAL', ((a + 20) / 4) - 66, h - 127, 4, q),
      ],
    );
  }

  // ==========================================================
  // CORREDERA 4 HOJAS 25 TERMO
  // ==========================================================

  static ResultadoFabricacion _corredera4Termo(double a, double h, int q) {
    return ResultadoFabricacion(
      producto: 'Corredera 4 hojas 25 termo',
      anchoVentana: a,
      altoVentana: h,
      cantidadVentanas: q,
      cortes: [
        _c('RS', a - 16, null, 1, q),
        _c('RI', a - 16, null, 1, q),
        _c('JA', null, h, 2, q),
        _c('CA', (a - 32) / 4, null, 4, q),
        _c('ZO', (a - 32) / 4, null, 4, q),
        _c('PI', null, h - 35, 4, q),
        _c('TR', null, h - 35, 4, q),
        _c('CRISTAL', ((a + 20) / 4) - 66, h - 130, 4, q),
      ],
    );
  }

  // ==========================================================
  // CANTIDAD FINAL
  // ==========================================================

  static CorteFabricacion _c(
    String pieza,
    double? ancho,
    double? alto,
    int cantidadPauta,
    int cantidadVentanas,
  ) {
    return CorteFabricacion(
      pieza: pieza,
      ancho: ancho,
      alto: alto,
      cantidad: cantidadPauta * cantidadVentanas,
    );
  }
}
