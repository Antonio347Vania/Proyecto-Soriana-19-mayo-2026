class CarritoItemModel {
  String productoId;
  String nombre;
  String departamento;
  double precio;
  double precioConDescuento;
  String imagen;
  int cantidad;
  int descuento;

  CarritoItemModel({
    required this.productoId,
    required this.nombre,
    required this.departamento,
    required this.precio,
    required this.precioConDescuento,
    required this.imagen,
    this.cantidad = 1,
    this.descuento = 0,
  });

  double get subtotal => precioConDescuento * cantidad;

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'nombre': nombre,
      'departamento': departamento,
      'precio': precio,
      'precioConDescuento': precioConDescuento,
      'imagen': imagen,
      'cantidad': cantidad,
      'descuento': descuento,
    };
  }

  factory CarritoItemModel.fromMap(Map<String, dynamic> map, String id) {
    return CarritoItemModel(
      productoId: map['productoId'] ?? '',
      nombre: map['nombre'] ?? '',
      departamento: map['departamento'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      precioConDescuento: (map['precioConDescuento'] ?? 0).toDouble(),
      imagen: map['imagen'] ?? '',
      cantidad: map['cantidad'] ?? 1,
      descuento: map['descuento'] ?? 0,
    );
  }
}