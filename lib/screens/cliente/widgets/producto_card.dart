import 'package:flutter/material.dart';
import '../../../models/producto_model.dart';

class ProductoCard extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = producto.stock <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen del producto
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: producto.imagen.isNotEmpty
                    ? Image.network(
                        producto.imagen,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 12),
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${producto.ratingFormateado} · ${producto.ventas}k ventas',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Mostrar stock disponible
                    Row(
                      children: [
                        Icon(Icons.inventory, size: 12, color: isOutOfStock ? Colors.red : Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          isOutOfStock ? 'Agotado' : 'Stock: ${producto.stock} unidades',
                          style: TextStyle(
                            color: isOutOfStock ? Colors.red : Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (producto.descuento > 0)
                          Text(
                            producto.precioFormateado,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          producto.precioConDescuentoFormateado,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: producto.descuento > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Botón de agregar al carrito
              Container(
                decoration: BoxDecoration(
                  color: isOutOfStock ? Colors.grey : Colors.red,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: isOutOfStock ? Colors.white54 : Colors.white),
                  onPressed: isOutOfStock ? null : onAddToCart,
                  iconSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}