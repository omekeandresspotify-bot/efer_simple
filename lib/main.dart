import 'package:flutter/material.dart';

import 'database.dart';
import 'trabajos.dart' as trabajos;
import 'agenda.dart' as agenda;
import 'fabricacion.dart' as fabricacion;

import 'clientes.dart';

import 'presupuesto_imagen.dart';

import 'historial.dart';

import 'auth_page.dart';
import 'admin_page.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// LUNIALES
// ============================================================

class LUNIALESApp extends StatelessWidget {
  const LUNIALESApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LUNIALES',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F5FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A35A8)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A35A8),
          foregroundColor: Colors.white,
        ),
      ),
      home: const _RootPage(),
    );
  }
}

class _RootPage extends StatelessWidget {
  const _RootPage();

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      onLoginSuccess: (perfil) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => InicioLuniales(
              rol: perfil['rol'] ?? 'VENDEDOR',
              empresaId: perfil['empresa_id'] ?? 1,
            ),
          ),
        );
      },
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kpbmwradjwwjrfyafipv.supabase.co',
    publishableKey: 'sb_publishable_bym8aAe1r9aRIiO_IK7J5g_kqAEHrFR',
  );

  runApp(const LUNIALESApp());
}

// ============================================================
// INICIO LUNIALES
// ============================================================

class InicioLuniales extends StatelessWidget {
  final String rol;
  final int empresaId;

  const InicioLuniales({super.key, this.rol = 'VENDEDOR', this.empresaId = 1});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FA),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // ENCABEZADO
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 25),

              decoration: const BoxDecoration(
                color: Color(0xFF6A35A8),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: Column(
                children: [
                  const Text(
                    'LUNIALES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'GESTIÓN PARA VIDRIERÍAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.business, color: Colors.white, size: 17),

                        SizedBox(width: 7),

                        Text(
                          'EMPRESA: EFER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // TITULO
            // ==================================================
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 15),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  '¿Qué quieres hacer?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F245F),
                  ),
                ),
              ),
            ),

            // ==================================================
            // OPCIONES
            // ==================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),

                child: Column(
                  children: [
                    // ------------------------------------------
                    // NUEVO PRESUPUESTO
                    // ------------------------------------------

                    _botonPrincipal(
                      context,
                      icono: Icons.receipt_long,
                      titulo: 'Nuevo presupuesto',
                      subtitulo: 'Crear una nueva cotización',
                      color: const Color(0xFF6A35A8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NuevoPresupuesto(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------
                    // CLIENTES
                    // ------------------------------------------
                    _botonModulo(
                      icono: Icons.people_alt_outlined,
                      titulo: 'Clientes',
                      subtitulo: 'Clientes y sus compras',
                      disponible: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ClientesPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------
                    // TRABAJOS
                    // ------------------------------------------
                    _botonModulo(
                      icono: Icons.construction_outlined,
                      titulo: 'Trabajos',
                      subtitulo: 'Seguimiento de trabajos',
                      disponible: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const trabajos.TrabajosPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------
                    // AGENDA
                    // ------------------------------------------
                    _botonModulo(
                      icono: Icons.calendar_month_outlined,
                      titulo: 'Agenda',
                      subtitulo: 'Instalaciones y fechas',
                      disponible: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const agenda.AgendaPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------
                    // FABRICACIÓN
                    // ------------------------------------------
                    _botonModulo(
                      icono: Icons.precision_manufacturing_outlined,
                      titulo: 'Fabricación',
                      subtitulo: 'Pautas, vidrios y cortes',
                      disponible: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const fabricacion.FabricacionPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------
                    // FACTURACIÓN
                    // ------------------------------------------
                    _botonModulo(
                      icono: Icons.receipt_long_outlined,
                      titulo: 'Facturación',
                      subtitulo: 'Documentos y pagos',
                      disponible: false,
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------
                    // ADMINISTRACIÓN
                    // ------------------------------------------
                    if (rol == 'ADMIN') ...[
                      _botonModulo(
                        icono: Icons.admin_panel_settings_outlined,
                        titulo: 'Administración EFER',
                        subtitulo: 'Configuración y valores por m²',
                        disponible: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminPage(empresaId: empresaId),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),
                    ],
                    _botonModulo(
                      icono: Icons.bar_chart_outlined,
                      titulo: 'Administración',
                      subtitulo: 'Ventas, costos y ganancias',
                      disponible: false,
                    ),

                    const SizedBox(height: 15),

                    // ------------------------------------------
                    // HISTORIAL ACTUAL
                    // ------------------------------------------
                    SizedBox(
                      width: double.infinity,

                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistorialPage(),
                            ),
                          );
                        },

                        icon: const Icon(
                          Icons.history,
                          color: Color(0xFF6A35A8),
                        ),

                        label: const Text(
                          'HISTORIAL DE PRESUPUESTOS',
                          style: TextStyle(
                            color: Color(0xFF6A35A8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),

                          side: const BorderSide(
                            color: Color(0xFF6A35A8),
                            width: 1.5,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // PIE
            // ==================================================
            const Padding(
              padding: EdgeInsets.only(bottom: 15),

              child: Text(
                'LUNIALES • Gestión para Vidrierías',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BOTON PRINCIPAL
  // ==========================================================

  static Widget _botonPrincipal(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 105,

      child: ElevatedButton(
        onPressed: onTap,

        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,

          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,

              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),

              child: Icon(icono, size: 31, color: Colors.white),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitulo,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, size: 27),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BOTON MODULO
  // ==========================================================

  static Widget _botonModulo({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required bool disponible,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3DCEB)),
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: disponible ? onTap : null,
          borderRadius: BorderRadius.circular(16),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),

            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAF7),
                    borderRadius: BorderRadius.circular(13),
                  ),

                  child: Icon(icono, color: const Color(0xFF6A35A8), size: 25),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F245F),
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        subtitulo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                if (disponible)
                  const Icon(Icons.chevron_right, color: Color(0xFF6A35A8))
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EFF5),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: const Text(
                      'PRÓXIMAMENTE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRECIOS
// ============================================================

final Map<String, double> preciosM2 = {
  // VENTANAS
  'Corredera 2 hojas 25 mono': 90000,
  'Corredera 2 hojas 25 termo': 130000,
  'Corredera 2 hojas 5000': 80000,
  'Fija AL42 mono': 45000,
  'Fija AL42 termo': 75000,
  'Proyectante AL42 mono': 70000,
  'Proyectante AL42 termo': 95000,
  'Corredera 3 hojas 25 mono': 90000,
  'Corredera 3 hojas 25 termo': 130000,
  'Corredera 4 hojas 25 mono': 100000,
  'Corredera 4 hojas 25 termo': 140000,

  // SHOWER DOOR
  'Shower Door 2 hojas': 150000,
  'Shower Door Esquinero': 240000,
  'Shower Door 2 hojas con fijo': 210000,

  // PUERTAS
  'Puerta AM35': 170000,
  'Puerta AM35 con placas': 210000,

  // VIDRIOS
  'Vidrio 4 mm': 25000,
  'Vidrio 5 mm': 30000,
  'Termopanel': 45000,
  'Espejo': 35000,
  'Semilla': 32000,
};

final Map<String, List<String>> productosPorCategoria = {
  'VENTANAS': [
    'Corredera 2 hojas 25 mono',
    'Corredera 2 hojas 25 termo',
    'Corredera 2 hojas 5000',
    'Fija AL42 mono',
    'Fija AL42 termo',
    'Proyectante AL42 mono',
    'Proyectante AL42 termo',
    'Corredera 3 hojas 25 mono',
    'Corredera 3 hojas 25 termo',
    'Corredera 4 hojas 25 mono',
    'Corredera 4 hojas 25 termo',
  ],

  'SHOWER DOOR': [
    'Shower Door 2 hojas',
    'Shower Door Esquinero',
    'Shower Door 2 hojas con fijo',
  ],

  'PUERTAS': ['Puerta AM35', 'Puerta AM35 con placas'],

  'VIDRIOS': ['Vidrio 4 mm', 'Vidrio 5 mm', 'Termopanel', 'Espejo', 'Semilla'],
};

// ============================================================
// INICIO
// ============================================================

class InicioEfer extends StatelessWidget {
  const InicioEfer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 35, 24, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF123B5D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'EFER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'VIDRIOS & ALUMINIOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 18),
                  SizedBox(
                    width: 70,
                    child: Divider(color: Color(0xFF2F80C0), thickness: 3),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Presupuestos rápidos y profesionales',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 45),

            const Text(
              '¿Qué quieres hacer?',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B5D),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                height: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NuevoPresupuesto(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF123B5D),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 55),
                      SizedBox(height: 12),
                      Text(
                        'NUEVO PRESUPUESTO',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Ingresar cliente y medidas',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                height: 100,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistorialPage()),
                    );
                  },
                  icon: const Icon(Icons.folder_copy_outlined, size: 35),
                  label: const Text(
                    'HISTORIAL',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF123B5D),
                    side: const BorderSide(color: Color(0xFF123B5D), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Text(
                'EFER • Vidrios & Aluminios',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MODELO DE PRODUCTO
// ============================================================

class ItemPresupuesto {
  String? producto;

  final TextEditingController ancho;

  final TextEditingController ancho2;

  final TextEditingController alto;

  final TextEditingController cantidad;

  ItemPresupuesto()
    : ancho = TextEditingController(),
      ancho2 = TextEditingController(),
      alto = TextEditingController(),
      cantidad = TextEditingController(text: '1');

  double get metrosCuadrados {
    final anchoMm = double.tryParse(ancho.text.replaceAll(',', '.')) ?? 0;

    final altoMm = double.tryParse(alto.text.replaceAll(',', '.')) ?? 0;

    final cant = double.tryParse(cantidad.text.replaceAll(',', '.')) ?? 1;

    return (anchoMm / 1000) * (altoMm / 1000) * cant;
  }

  double get precioM2 {
    if (producto == null) {
      return 0;
    }

    return preciosM2[producto!] ?? 0;
  }

  double get total {
    const productosPrecioFijo = {
      'Shower Door 2 hojas',
      'Shower Door Esquinero',
      'Shower Door 2 hojas con fijo',
      'Puerta AM35',
      'Puerta AM35 con placas',
    };

    if (productosPrecioFijo.contains(producto)) {
      return precioM2;
    }

    return metrosCuadrados * precioM2;
  }

  void dispose() {
    ancho.dispose();
    ancho2.dispose();
    alto.dispose();
    cantidad.dispose();
  }
}

// ============================================================
// NUEVO PRESUPUESTO
// ============================================================

class NuevoPresupuesto extends StatefulWidget {
  const NuevoPresupuesto({super.key});

  @override
  State<NuevoPresupuesto> createState() => _NuevoPresupuestoState();
}

class _NuevoPresupuestoState extends State<NuevoPresupuesto> {
  final nombreController = TextEditingController();

  final telefonoController = TextEditingController();

  final correoController = TextEditingController();

  final direccionController = TextEditingController();

  final List<ItemPresupuesto> items = [ItemPresupuesto()];

  bool cargandoPrecios = true;

  @override
  void initState() {
    super.initState();
    cargarClientes();
    cargarPrecios();
  }

  Future<void> cargarPrecios() async {
    try {
      final datos = await Supabase.instance.client
          .from('precios_m2')
          .select('producto, precio_m2')
          .eq('empresa_id', 1)
          .eq('activo', true);

      for (final precio in datos) {
        final producto = precio['producto'] as String;
        final valor = (precio['precio_m2'] as num).toDouble();

        preciosM2[producto] = valor;
      }

      if (!mounted) return;

      setState(() {
        cargandoPrecios = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        cargandoPrecios = false;
      });
    }
  }

  int? clienteSeleccionadoId;

  List<Map<String, dynamic>> clientes = [];

  String colorSeleccionado = 'MATE';

  Future<void> cargarClientes() async {
    final lista = await EferDatabase.instance.obtenerClientes();

    if (!mounted) {
      return;
    }

    setState(() {
      clientes = lista;
    });
  }

  // ==========================================================
  // TOTAL GENERAL
  // ==========================================================

  double get totalGeneral {
    return items.fold(0, (total, item) => total + item.total);
  }

  double get metrosTotales {
    return items.fold(0, (total, item) => total + item.metrosCuadrados);
  }

  // ==========================================================
  // AGREGAR PRODUCTO
  // ==========================================================

  void agregarProducto() {
    setState(() {
      items.add(ItemPresupuesto());
    });
  }

  // ==========================================================
  // ELIMINAR PRODUCTO
  // ==========================================================

  void eliminarProducto(int index) {
    if (items.length == 1) {
      return;
    }

    setState(() {
      items[index].dispose();
      items.removeAt(index);
    });
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    direccionController.dispose();

    for (final item in items) {
      item.dispose();
    }

    super.dispose();
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
  // GUARDAR PRESUPUESTO
  // ==========================================================

  Future<void> _guardarPresupuesto() async {
    // --------------------------------------------------------
    // VALIDAR CLIENTE
    // --------------------------------------------------------

    if (nombreController.text.trim().isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el nombre del cliente')),
      );

      return;
    }

    // --------------------------------------------------------
    // OBTENER NUMERO
    // --------------------------------------------------------

    final numero = await EferDatabase.instance.obtenerSiguienteNumero();

    if (!mounted) {
      return;
    }

    // --------------------------------------------------------
    // FECHA Y HORA ACTUAL
    // --------------------------------------------------------

    final ahora = DateTime.now();

    final fecha =
        '${ahora.day.toString().padLeft(2, '0')}/'
        '${ahora.month.toString().padLeft(2, '0')}/'
        '${ahora.year}';

    final hora =
        '${ahora.hour.toString().padLeft(2, '0')}:'
        '${ahora.minute.toString().padLeft(2, '0')}';

    // --------------------------------------------------------
    // CALCULOS
    // --------------------------------------------------------

    final subtotal = totalGeneral;

    final iva = subtotal * 0.19;

    final total = subtotal + iva;

    // --------------------------------------------------------
    // PRODUCTOS
    // --------------------------------------------------------

    final productos = items.where((item) => item.producto != null).map((item) {
      return {
        'producto': item.producto!,

        'ancho': double.tryParse(item.ancho.text.replaceAll(',', '.')) ?? 0,

        'alto': double.tryParse(item.alto.text.replaceAll(',', '.')) ?? 0,

        'ancho2': double.tryParse(item.ancho2.text.replaceAll(',', '.')) ?? 0,

        'cantidad':
            double.tryParse(item.cantidad.text.replaceAll(',', '.')) ?? 1,

        'metrosCuadrados': item.metrosCuadrados,

        'precioM2': item.precioM2,

        'total': item.total,
      };
    }).toList();

    // --------------------------------------------------------
    // VALIDAR PRODUCTOS
    // --------------------------------------------------------

    if (productos.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un producto')),
      );

      return;
    }

    // --------------------------------------------------------
    // GUARDAR EN BASE DE DATOS
    // --------------------------------------------------------

    // --------------------------------------------------------
    // CREAR CLIENTE SI ES NUEVO
    // --------------------------------------------------------

    int? clienteId = clienteSeleccionadoId;

    clienteId ??= await EferDatabase.instance.crearCliente(
      nombre: nombreController.text.trim(),
      telefono: telefonoController.text.trim().isEmpty
          ? null
          : telefonoController.text.trim(),
      correo: correoController.text.trim().isEmpty
          ? null
          : correoController.text.trim(),
      direccion: direccionController.text.trim().isEmpty
          ? null
          : direccionController.text.trim(),
    );

    await EferDatabase.instance.guardarPresupuestoCompleto(
      numero: numero,
      fecha: fecha,
      hora: hora,
      nombreCliente: nombreController.text.trim(),
      clienteId: clienteId,
      telefono: telefonoController.text.trim(),
      correo: correoController.text.trim(),
      direccion: direccionController.text.trim(),
      color: colorSeleccionado,
      subtotal: subtotal,
      iva: iva,
      total: total,
      productos: productos,
    );

    if (!mounted) {
      return;
    }

    // --------------------------------------------------------
    // MOSTRAR CONFIRMACION
    // --------------------------------------------------------

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Presupuesto guardado'),

          content: Text(
            'Presupuesto Nº $numero\n\n'
            'Fecha: $fecha\n'
            'Hora: $hora\n\n'
            'Subtotal: '
            '${dinero(subtotal)}\n'
            'IVA 19%: '
            '${dinero(iva)}\n'
            'TOTAL: '
            '${dinero(total)}',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PresupuestoImagen(
          numero: numero,
          fecha: fecha,
          hora: hora,
          nombreCliente: nombreController.text.trim(),
          telefono: telefonoController.text.trim(),
          correo: correoController.text.trim(),
          direccion: direccionController.text.trim(),
          subtotal: subtotal,
          iva: iva,
          total: total,
          productos: productos.map((producto) {
            return ProductoImagen(
              producto: producto['producto'] as String,
              ancho: (producto['ancho'] as num).toDouble(),
              ancho2: (producto['ancho2'] as num).toDouble(),
              alto: (producto['alto'] as num).toDouble(),

              cantidad: (producto['cantidad'] as num).toDouble(),
              metrosCuadrados: (producto['metrosCuadrados'] as num).toDouble(),
              precioM2: (producto['precioM2'] as num).toDouble(),
              total: (producto['total'] as num).toDouble(),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==========================================================
  // PANTALLA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nuevo presupuesto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF123B5D),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // DATOS CLIENTE
            // ==================================================

            const Text(
              'DATOS DEL CLIENTE',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B5D),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<int>(
              initialValue: clienteSeleccionadoId,

              decoration: InputDecoration(
                labelText: 'Cliente registrado',
                hintText: 'Seleccionar cliente',
                prefixIcon: const Icon(Icons.people_alt_outlined),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('Sin cliente registrado'),
                ),

                ...clientes.map((cliente) {
                  return DropdownMenuItem<int>(
                    value: cliente['id'] as int,
                    child: Text(cliente['nombre'] as String),
                  );
                }),
              ],

              onChanged: (clienteId) {
                setState(() {
                  clienteSeleccionadoId = clienteId;
                });

                if (clienteId == null) {
                  return;
                }

                final cliente = clientes.firstWhere(
                  (elemento) => elemento['id'] == clienteId,
                );

                nombreController.text = (cliente['nombre'] ?? '').toString();

                telefonoController.text = (cliente['telefono'] ?? '')
                    .toString();

                correoController.text = (cliente['correo'] ?? '').toString();

                direccionController.text = (cliente['direccion'] ?? '')
                    .toString();
              },
            ),

            const SizedBox(height: 15),

            campo(
              'Nombre',
              'Nombre del cliente',
              nombreController,
              Icons.person,
            ),

            campo(
              'Teléfono',
              '+56 9 1234 5678',
              telefonoController,
              Icons.phone,
              tipo: TextInputType.phone,
            ),

            campo(
              'Correo',
              'correo@ejemplo.cl',
              correoController,
              Icons.email,
              tipo: TextInputType.emailAddress,
            ),

            campo(
              'Dirección',
              'Dirección del proyecto',
              direccionController,
              Icons.location_on,
            ),

            const SizedBox(height: 12),

            // ==========================================================
            // COLOR DE LAS VENTANAS
            // ==========================================================
            DropdownButtonFormField<String>(
              initialValue: colorSeleccionado,

              decoration: InputDecoration(
                labelText: 'Color de las ventanas',
                prefixIcon: const Icon(Icons.palette_outlined),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              items: const [
                DropdownMenuItem(value: 'MATE', child: Text('MATE')),

                DropdownMenuItem(value: 'MADERA', child: Text('MADERA')),

                DropdownMenuItem(value: 'NEGRO', child: Text('NEGRO')),

                DropdownMenuItem(value: 'BLANCO', child: Text('BLANCO')),

                DropdownMenuItem(value: 'TITANIO', child: Text('TITANIO')),

                DropdownMenuItem(value: 'GRAFITO', child: Text('GRAFITO')),
              ],

              onChanged: (valor) {
                if (valor == null) return;

                setState(() {
                  colorSeleccionado = valor;
                });
              },
            ),

            const SizedBox(height: 25),

            const SizedBox(height: 25),

            // ==================================================
            // PRODUCTOS
            // ==================================================
            const Text(
              'PRODUCTOS',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B5D),
              ),
            ),

            const SizedBox(height: 15),

            ...List.generate(items.length, (index) => construirProducto(index)),

            const SizedBox(height: 10),

            // ==================================================
            // AGREGAR PRODUCTO
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 55,

              child: OutlinedButton.icon(
                onPressed: agregarProducto,

                icon: const Icon(Icons.add),

                label: const Text(
                  'AGREGAR PRODUCTO',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF123B5D),

                  side: const BorderSide(color: Color(0xFF123B5D), width: 2),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // RESUMEN
            // ==================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFFEAF2F8),

                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  const Text(
                    'RESUMEN DEL PRESUPUESTO',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123B5D),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text('Productos'),

                      Text(
                        '${items.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text('Superficie total'),

                      Text(
                        '${metrosTotales.toStringAsFixed(2)} m²',

                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const Divider(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'SUBTOTAL',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        dinero(totalGeneral),

                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text('IVA 19%'),

                      Text(
                        dinero(totalGeneral * 0.19),

                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const Divider(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        dinero(totalGeneral + (totalGeneral * 0.19)),

                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123B5D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // GENERAR PRESUPUESTO
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 60,

              child: ElevatedButton.icon(
                onPressed: _guardarPresupuesto,

                icon: const Icon(Icons.receipt_long),

                label: const Text(
                  'GENERAR PRESUPUESTO',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF123B5D),

                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TARJETA PRODUCTO
  // ==========================================================

  Widget construirProducto(int index) {
    final item = items[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 18),

      elevation: 3,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Text(
                  'PRODUCTO ${index + 1}',

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF123B5D),
                  ),
                ),

                const Spacer(),

                if (items.length > 1)
                  IconButton(
                    onPressed: () {
                      eliminarProducto(index);
                    },

                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // --------------------------------------------------
            // PRODUCTO
            // --------------------------------------------------
            InkWell(
              onTap: () async {
                final producto = await seleccionarProducto();

                if (!mounted) {
                  return;
                }

                if (producto != null) {
                  setState(() {
                    item.producto = producto;
                  });
                }
              },

              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Producto',

                  prefixIcon: const Icon(Icons.window),

                  suffixIcon: const Icon(Icons.arrow_drop_down),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: Text(
                  item.producto ?? 'Seleccionar producto',

                  style: TextStyle(
                    color: item.producto == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // --------------------------------------------------
            // MEDIDAS
            // --------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: campo(
                    (item.producto == 'Shower Door Esquinero' ||
                            item.producto == 'Shower Door 2 hojas con fijo')
                        ? 'Ancho 1 (mm)'
                        : 'Ancho (mm)',
                    '1200',
                    item.ancho,
                    Icons.straighten,
                    tipo: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: () {
                      setState(() {});
                    },
                  ),
                ),

                if (item.producto == 'Shower Door Esquinero' ||
                    item.producto == 'Shower Door 2 hojas con fijo') ...[
                  const SizedBox(width: 10),

                  Expanded(
                    child: campo(
                      'Ancho 2 (mm)',
                      '1200',
                      item.ancho2,
                      Icons.straighten,
                      tipo: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: () {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ],
            ),
            campo(
              'Alto (mm)',
              '2000',
              item.alto,
              Icons.height,
              tipo: const TextInputType.numberWithOptions(decimal: true),
              onChanged: () {
                setState(() {});
              },
            ),

            campo(
              'Cantidad',
              '1',
              item.cantidad,
              Icons.numbers,

              tipo: TextInputType.number,

              onChanged: () {
                setState(() {});
              },
            ),

            // --------------------------------------------------
            // TOTAL PRODUCTO
            // --------------------------------------------------
            if (item.producto != null)
              Container(
                margin: const EdgeInsets.only(top: 5),

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F9),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text('Superficie'),

                        Text(
                          '${item.metrosCuadrados.toStringAsFixed(2)} m²',

                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text('Valor m²'),

                        Text(
                          dinero(item.precioM2),

                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Text(
                          dinero(item.total),

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF123B5D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SELECCIONAR PRODUCTO
  // ==========================================================

  Future<String?> seleccionarProducto() {
    return showModalBottomSheet<String>(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),

            shrinkWrap: true,

            children: [
              const Text(
                'SELECCIONAR PRODUCTO',

                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123B5D),
                ),
              ),

              const SizedBox(height: 20),

              ...productosPorCategoria.entries.expand(
                (categoria) => [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),

                    child: Text(
                      categoria.key,

                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F80C0),
                      ),
                    ),
                  ),

                  ...categoria.value.map((producto) {
                    return ListTile(
                      leading: const Icon(
                        Icons.window,
                        color: Color(0xFF123B5D),
                      ),

                      title: Text(producto),

                      trailing: Text(
                        dinero(preciosM2[producto] ?? 0),

                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      onTap: () {
                        Navigator.pop(context, producto);
                      },
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // CAMPO
  // ==========================================================

  Widget campo(
    String titulo,
    String hint,
    TextEditingController controller,
    IconData icon, {
    TextInputType? tipo,
    VoidCallback? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: TextField(
        controller: controller,

        keyboardType: tipo,

        onChanged: (_) {
          if (onChanged != null) {
            onChanged();
          }
        },

        decoration: InputDecoration(
          labelText: titulo,

          hintText: hint,

          prefixIcon: Icon(icon),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
