import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPage extends StatefulWidget {
  final int empresaId;

  const AdminPage({super.key, required this.empresaId});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _supabase = Supabase.instance.client;

  bool _cargando = true;
  bool _guardando = false;

  List<Map<String, dynamic>> _precios = [];

  @override
  void initState() {
    super.initState();
    _cargarPrecios();
  }

  Future<void> _cargarPrecios() async {
    try {
      final datos = await _supabase
          .from('precios_m2')
          .select('id, producto, precio_m2')
          .eq('empresa_id', widget.empresaId)
          .eq('activo', true)
          .order('producto');

      if (!mounted) return;

      setState(() {
        _precios = List<Map<String, dynamic>>.from(datos);
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los valores: $e')),
      );
    }
  }

  Future<void> _guardarPrecio(int id, String producto, String valor) async {
    final precio = double.tryParse(
      valor.replaceAll('.', '').replaceAll(',', '.'),
    );

    if (precio == null || precio < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un valor válido')));
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await _supabase
          .from('precios_m2')
          .update({'precio_m2': precio})
          .eq('id', id)
          .eq('empresa_id', widget.empresaId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$producto actualizado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  String _formatearPrecio(dynamic valor) {
    final numero = (valor as num).toDouble();

    return numero
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Administración EFER',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarPrecios,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EAF7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.admin_panel_settings_outlined,
                          color: Color(0xFF6A35A8),
                          size: 35,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'ADMINISTRACIÓN',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F245F),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Configuración de valores por m²',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'VALORES POR m²',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F245F),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ..._precios.map((precio) {
                    final controller = TextEditingController(
                      text: _formatearPrecio(precio['precio_m2']),
                    );

                    return _PrecioCard(
                      producto: precio['producto'].toString(),
                      controller: controller,
                      guardando: _guardando,
                      onGuardar: () {
                        _guardarPrecio(
                          precio['id'] as int,
                          precio['producto'].toString(),
                          controller.text,
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _PrecioCard extends StatelessWidget {
  final String producto;
  final TextEditingController controller;
  final bool guardando;
  final VoidCallback onGuardar;

  const _PrecioCard({
    required this.producto,
    required this.controller,
    required this.guardando,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                producto,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              width: 120,
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  labelText: 'Valor m²',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              onPressed: guardando ? null : onGuardar,
              icon: const Icon(Icons.save_outlined, color: Color(0xFF6A35A8)),
              tooltip: 'Guardar',
            ),
          ],
        ),
      ),
    );
  }
}
