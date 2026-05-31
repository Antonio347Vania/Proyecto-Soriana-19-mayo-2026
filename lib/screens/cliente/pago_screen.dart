import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/carrito_provider.dart';
import '../../models/pedido_model.dart';
import 'cliente_home_screen.dart';

class PagoScreen extends StatefulWidget {
  final String nombreUsuario;
  const PagoScreen({super.key, required this.nombreUsuario});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  String _metodoPago = 'efectivo';
  bool _isTarjeta = false;
  bool _isProcessing = false;
  
  // Tarjeta
  final _titularController = TextEditingController();
  final _numeroController = TextEditingController();
  final _fechaController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _titularController.dispose();
    _numeroController.dispose();
    _fechaController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // Validar número de tarjeta (solo números y máximo 16 dígitos)
  void _onNumeroTarjetaChanged(String value) {
    String filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (filtered.length > 16) {
      filtered = filtered.substring(0, 16);
    }
    if (filtered != value) {
      _numeroController.value = TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }
  }

  // Validar fecha con formato MM/AA
  void _onFechaChanged(String value) {
    String filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (filtered.length > 4) {
      filtered = filtered.substring(0, 4);
    }
    
    String formatted = filtered;
    if (filtered.length >= 3) {
      formatted = '${filtered.substring(0, 2)}/${filtered.substring(2)}';
    } else if (filtered.length == 2) {
      formatted = filtered;
    }
    
    if (formatted != value) {
      _fechaController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    // Validar mes (01-12)
    if (filtered.length >= 2) {
      int mes = int.parse(filtered.substring(0, 2));
      if (mes < 1) {
        _fechaController.value = TextEditingValue(
          text: '01${filtered.length > 2 ? '/${filtered.substring(2)}' : ''}',
          selection: TextSelection.collapsed(offset: _fechaController.text.length),
        );
      } else if (mes > 12) {
        _fechaController.value = TextEditingValue(
          text: '12${filtered.length > 2 ? '/${filtered.substring(2)}' : ''}',
          selection: TextSelection.collapsed(offset: _fechaController.text.length),
        );
      }
    }
  }

  // Validar CVV (solo números y máximo 3-4 dígitos)
  void _onCvvChanged(String value) {
    String filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (filtered.length > 3) {
      filtered = filtered.substring(0, 3);
    }
    if (filtered != value) {
      _cvvController.value = TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }
  }

  // Validar que el número de tarjeta tenga exactamente 16 dígitos
  bool _isValidCardNumber() {
    String numero = _numeroController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return numero.length == 16;
  }

  // Validar que la fecha sea válida
  bool _isValidFecha() {
    String fecha = _fechaController.text;
    if (fecha.length != 5) return false;
    
    try {
      int mes = int.parse(fecha.substring(0, 2));
      int anio = int.parse(fecha.substring(3));
      return mes >= 1 && mes <= 12 && anio >= 24 && anio <= 99;
    } catch (e) {
      return false;
    }
  }

  // Validar que el CVV tenga exactamente 3 dígitos
  bool _isValidCvv() {
    String cvv = _cvvController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return cvv.length == 3;
  }

  Future<void> _actualizarStockProductos(CarritoProvider carrito) async {
    final batch = FirebaseFirestore.instance.batch();
    
    for (var item in carrito.items) {
      final productRef = FirebaseFirestore.instance.collection('Productos').doc(item.productoId);
      final productDoc = await productRef.get();
      if (productDoc.exists) {
        final currentStock = productDoc.data()?['stock'] ?? 0;
        final newStock = currentStock - item.cantidad;
        
        batch.update(productRef, {
          'stock': newStock,
          'ventas': FieldValue.increment(item.cantidad),
        });
      }
    }
    
    await batch.commit();
  }

  Future<void> _procesarPago(BuildContext context, CarritoProvider carrito) async {
    // Validar tarjeta si es necesario
    if (_metodoPago == 'tarjeta') {
      if (_titularController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingrese el nombre del titular')),
        );
        return;
      }
      if (!_isValidCardNumber()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Número de tarjeta inválido (debe tener 16 dígitos)')),
        );
        return;
      }
      if (!_isValidFecha()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fecha inválida (formato MM/AA)')),
        );
        return;
      }
      if (!_isValidCvv()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CVV inválido (debe tener 3 dígitos)')),
        );
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Primero verificar que haya suficiente stock
      for (var item in carrito.items) {
        final productDoc = await FirebaseFirestore.instance
            .collection('Productos')
            .doc(item.productoId)
            .get();
        
        if (productDoc.exists) {
          final currentStock = productDoc.data()?['stock'] ?? 0;
          if (currentStock < item.cantidad) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Stock insuficiente para ${item.nombre}. Solo quedan $currentStock unidades.')),
            );
            setState(() {
              _isProcessing = false;
            });
            return;
          }
        }
      }

      // Actualizar stock de productos
      await _actualizarStockProductos(carrito);

      // Crear pedido con el nombre del usuario
      final pedido = PedidoModel(
        id: '',
        nombreUsuario: widget.nombreUsuario,
        usuarioId: '',
        productos: carrito.items.map((item) => {
          'productoId': item.productoId,
          'nombre': item.nombre,
          'departamento': item.departamento,
          'precio': item.precio,
          'precioConDescuento': item.precioConDescuento,
          'cantidad': item.cantidad,
          'subtotal': item.subtotal,
        }).toList(),
        metodoPago: _metodoPago == 'efectivo' ? 'Efectivo' : 'Tarjeta',
        total: carrito.total,
        fecha: DateTime.now(),
        estado: 'Pagado',
      );

      await FirebaseFirestore.instance.collection('Pedidos').add(pedido.toMap());
      
      // Vaciar carrito
      carrito.vaciarCarrito();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Pago exitoso! Pedido realizado')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ClienteHomeScreen(nombreUsuario: widget.nombreUsuario),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar: $e')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Pago',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Resumen del pedido
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen del Pedido',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...carrito.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.cantidad}x ${item.nombre}'),
                          Text('\$${item.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          '\$${carrito.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Método de pago
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Método de Pago',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    RadioListTile(
                      title: const Text('Efectivo'),
                      value: 'efectivo',
                      groupValue: _metodoPago,
                      onChanged: (value) {
                        setState(() {
                          _metodoPago = value!;
                          _isTarjeta = false;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    RadioListTile(
                      title: const Text('Tarjeta'),
                      value: 'tarjeta',
                      groupValue: _metodoPago,
                      onChanged: (value) {
                        setState(() {
                          _metodoPago = value!;
                          _isTarjeta = true;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    
                    if (_isTarjeta) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text('Datos de la Tarjeta', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      // Nombre del Titular
                      TextField(
                        controller: _titularController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Titular',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Número de Tarjeta (solo números, 16 dígitos)
                      TextField(
                        controller: _numeroController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Tarjeta',
                          hintText: '1234 5678 9012 3456',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card),
                          counterText: '',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        onChanged: _onNumeroTarjetaChanged,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Fecha (MM/AA)
                          Expanded(
                            child: TextField(
                              controller: _fechaController,
                              decoration: const InputDecoration(
                                labelText: 'MM/AA',
                                hintText: '12/25',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                                counterText: '',
                              ),
                              keyboardType: TextInputType.datetime,
                              maxLength: 5,
                              onChanged: _onFechaChanged,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // CVV (solo 3 dígitos)
                          Expanded(
                            child: TextField(
                              controller: _cvvController,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                                counterText: '',
                              ),
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 3,
                              onChanged: _onCvvChanged,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _procesarPago(context, carrito),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirmar Pago',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}