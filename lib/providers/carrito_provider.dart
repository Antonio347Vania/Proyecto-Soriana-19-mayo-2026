import 'package:flutter/material.dart';
import '../models/carrito_item_model.dart';

class CarritoProvider extends ChangeNotifier {
  final List<CarritoItemModel> _items = [];

  List<CarritoItemModel> get items => _items;

  int get cantidadItems => _items.fold(0, (sum, item) => sum + item.cantidad);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  double get total => subtotal; // Por ahora sin envío

  void agregarProducto(CarritoItemModel producto) {
    final index = _items.indexWhere((item) => item.productoId == producto.productoId);
    
    if (index != -1) {
      _items[index].cantidad++;
    } else {
      _items.add(producto);
    }
    notifyListeners();
  }

  void incrementarCantidad(String productoId) {
    final index = _items.indexWhere((item) => item.productoId == productoId);
    if (index != -1) {
      _items[index].cantidad++;
      notifyListeners();
    }
  }

  void decrementarCantidad(String productoId) {
    final index = _items.indexWhere((item) => item.productoId == productoId);
    if (index != -1) {
      if (_items[index].cantidad > 1) {
        _items[index].cantidad--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void eliminarProducto(String productoId) {
    _items.removeWhere((item) => item.productoId == productoId);
    notifyListeners();
  }

  void vaciarCarrito() {
    _items.clear();
    notifyListeners();
  }
}