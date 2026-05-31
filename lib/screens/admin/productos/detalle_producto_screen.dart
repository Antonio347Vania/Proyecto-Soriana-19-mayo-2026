import 'package:flutter/material.dart';
import '../../../models/producto_model.dart';
import 'editar_producto_screen.dart';

class DetalleProductoScreen extends StatelessWidget {
  final ProductoModel producto;
  final String nombreDepartamento;

  const DetalleProductoScreen({
    super.key,
    required this.producto,
    required this.nombreDepartamento,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Detalle de Producto',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarProductoScreen(producto: producto),
                ),
              ).then((_) => Navigator.pop(context));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con imagen
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Imagen circular
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: ClipOval(
                      child: producto.imagen.isNotEmpty
                          ? Image.network(
                              producto.imagen,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white,
                                  child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                                );
                              },
                            )
                          : Container(
                              color: Colors.white,
                              child: const Icon(Icons.inventory, size: 60, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      nombreDepartamento,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            
            // Información del Producto
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Información del Producto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  
                  // Precio
                  _buildInfoRow(
                    Icons.attach_money,
                    'Precio Original',
                    producto.precioFormateado,
                  ),
                  const Divider(height: 1),
                  
                  // Descuento
                  _buildInfoRow(
                    Icons.local_offer,
                    'Descuento',
                    '${producto.descuento}%',
                  ),
                  const Divider(height: 1),
                  
                  // Precio con descuento
                  _buildInfoRow(
                    Icons.shopping_cart,
                    'Precio Final',
                    producto.precioConDescuentoFormateado,
                    textColor: Colors.red,
                  ),
                  const Divider(height: 1),
                  
                  // Stock
                  _buildInfoRow(
                    Icons.inventory,
                    'Stock Disponible',
                    '${producto.stock} unidades',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: Colors.red),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}