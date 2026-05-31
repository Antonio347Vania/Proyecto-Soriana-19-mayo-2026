import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/pedido_model.dart';

class EditarPedidoScreen extends StatefulWidget {
  final PedidoModel pedido;

  const EditarPedidoScreen({super.key, required this.pedido});

  @override
  State<EditarPedidoScreen> createState() => _EditarPedidoScreenState();
}

class _EditarPedidoScreenState extends State<EditarPedidoScreen> {
  late TextEditingController _nombreUsuarioController;
  late TextEditingController _metodoPagoController;
  late TextEditingController _totalController;
  late List<Map<String, dynamic>> _productos;
  bool _isLoading = false;
  late String _estado;
  final List<String> _estados = ['Pendiente', 'Pagado', 'Enviado', 'Entregado', 'Cancelado'];

  @override
  void initState() {
    super.initState();
    _nombreUsuarioController = TextEditingController(text: widget.pedido.nombreUsuario);
    _metodoPagoController = TextEditingController(text: widget.pedido.metodoPago);
    _totalController = TextEditingController(text: widget.pedido.total.toString());
    _productos = List.from(widget.pedido.productos);
    _estado = widget.pedido.estado;
  }

  @override
  void dispose() {
    _nombreUsuarioController.dispose();
    _metodoPagoController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _agregarProducto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(labelText: 'Nombre del producto'),
              onChanged: (value) => _tempNombre = value,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _tempCantidad = int.tryParse(value) ?? 1,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(labelText: 'Precio unitario'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _tempPrecio = double.tryParse(value) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _productos.add({
                  'nombre': _tempNombre,
                  'cantidad': _tempCantidad,
                  'precio': _tempPrecio,
                  'subtotal': _tempCantidad * _tempPrecio,
                });
                _calcularTotal();
              });
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  String _tempNombre = '';
  int _tempCantidad = 1;
  double _tempPrecio = 0;

  void _editarProducto(int index) {
    var producto = _productos[index];
    TextEditingController nombreController = TextEditingController(text: producto['nombre']);
    TextEditingController cantidadController = TextEditingController(text: producto['cantidad'].toString());
    TextEditingController precioController = TextEditingController(text: producto['precio'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del producto'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: precioController,
              decoration: const InputDecoration(labelText: 'Precio unitario'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _productos[index] = {
                  'nombre': nombreController.text,
                  'cantidad': int.parse(cantidadController.text),
                  'precio': double.parse(precioController.text),
                  'subtotal': int.parse(cantidadController.text) * double.parse(precioController.text),
                };
                _calcularTotal();
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarProducto(int index) {
    setState(() {
      _productos.removeAt(index);
      _calcularTotal();
    });
  }

  void _calcularTotal() {
    double nuevoTotal = 0;
    for (var producto in _productos) {
      nuevoTotal += producto['subtotal'];
    }
    _totalController.text = nuevoTotal.toStringAsFixed(2);
  }

  Future<void> _actualizarPedido() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('Pedidos')
          .doc(widget.pedido.id)
          .update({
        'nombreUsuario': _nombreUsuarioController.text.trim(),
        'metodoPago': _metodoPagoController.text.trim(),
        'total': double.parse(_totalController.text),
        'productos': _productos,
        'estado': _estado,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido actualizado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Pedido'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Información del pedido
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nombreUsuarioController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Cliente',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _metodoPagoController,
                      decoration: const InputDecoration(
                        labelText: 'Método de Pago',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payment),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _estado,
                      items: _estados.map((estado) {
                        return DropdownMenuItem(value: estado, child: Text(estado));
                      }).toList(),
                      onChanged: (value) => setState(() => _estado = value!),
                      decoration: const InputDecoration(
                        labelText: 'Estado del Pedido',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _totalController,
                      decoration: const InputDecoration(
                        labelText: 'Total',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Productos
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Productos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.red),
                          onPressed: _agregarProducto,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        final producto = _productos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(producto['nombre']),
                            subtitle: Text(
                              'Cantidad: ${producto['cantidad']} x \$${producto['precio']} = \$${producto['subtotal']}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editarProducto(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _eliminarProducto(index),
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
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isLoading ? null : _actualizarPedido,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Actualizar Pedido', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}