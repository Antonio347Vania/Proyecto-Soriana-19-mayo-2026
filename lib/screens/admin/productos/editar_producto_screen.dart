import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/producto_model.dart';

class EditarProductoScreen extends StatefulWidget {
  final ProductoModel producto;

  const EditarProductoScreen({super.key, required this.producto});

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _descuentoController;
  late TextEditingController _imagenUrlController;
  
  String _departamentoId = '';
  List<Map<String, dynamic>> _departamentos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _precioController = TextEditingController(text: widget.producto.precio.toString());
    _stockController = TextEditingController(text: widget.producto.stock.toString());
    _descuentoController = TextEditingController(text: widget.producto.descuento.toString());
    _imagenUrlController = TextEditingController(text: widget.producto.imagen);
    _departamentoId = widget.producto.departamento;
    _cargarDepartamentos();
  }

  Future<void> _cargarDepartamentos() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Departamentos')
          .get();
      
      setState(() {
        _departamentos = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'nombre': doc['nombre'] ?? 'Sin nombre',
          };
        }).toList();
      });
    } catch (e) {
      print('Error al cargar departamentos: $e');
    }
  }

  Future<void> _actualizarProducto() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await FirebaseFirestore.instance
          .collection('Productos')
          .doc(widget.producto.id)
          .update({
        'nombre': _nombreController.text.trim(),
        'precio': double.parse(_precioController.text),
        'stock': int.parse(_stockController.text),
        'descuento': int.parse(_descuentoController.text),
        'imagen': _imagenUrlController.text.trim(),
        'departamento': _departamentoId,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado exitosamente')),
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Vista previa de la imagen
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imagenUrlController.text.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _imagenUrlController.text,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
              ),
              const SizedBox(height: 20),
              
              // URL de la imagen
              TextFormField(
                controller: _imagenUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen',
                  hintText: 'https://ejemplo.com/producto.jpg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              
              // Nombre del producto
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.production_quantity_limits),
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              
              // Precio
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Campo requerido';
                  if (double.tryParse(value) == null) return 'Ingrese un precio válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Stock
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  hintText: '0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Ingrese un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Descuento
              TextFormField(
                controller: _descuentoController,
                decoration: const InputDecoration(
                  labelText: 'Descuento (%)',
                  hintText: '0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_offer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Ingrese un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Departamento (Dropdown)
              DropdownButtonFormField<String>(
                initialValue: _departamentoId.isNotEmpty ? _departamentoId : null,
                decoration: const InputDecoration(
                  labelText: 'Departamento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: _departamentos.map((depto) {
                  return DropdownMenuItem<String>(
                    value: depto['id'],
                    child: Text(depto['nombre']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _departamentoId = value!;
                  });
                },
                validator: (value) => value == null ? 'Seleccione un departamento' : null,
              ),
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _actualizarProducto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Actualizar Producto', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}