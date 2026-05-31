class ProductoModel {
  String id;
  String nombre;
  double precio;
  int stock;
  int descuento;
  String imagen;
  String departamento; // ID del departamento
  int ventas; // Nuevo campo para ventas

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.descuento,
    required this.imagen,
    required this.departamento,
    this.ventas = 0,
  });

  // Convertir de Firestore a objeto
  factory ProductoModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductoModel(
      id: id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      descuento: data['descuento'] ?? 0,
      imagen: data['imagen'] ?? '',
      departamento: data['departamento'] ?? '',
      ventas: data['ventas'] ?? 0,
    );
  }

  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'stock': stock,
      'descuento': descuento,
      'imagen': imagen,
      'departamento': departamento,
      'ventas': ventas,
    };
  }

  // Calcular precio con descuento
  double get precioConDescuento {
    if (descuento <= 0) return precio;
    return precio - (precio * descuento / 100);
  }

  String get precioFormateado => '\$${precio.toStringAsFixed(2)}';
  String get precioConDescuentoFormateado => '\$${precioConDescuento.toStringAsFixed(2)}';
  
  double get rating => 4.5 + ((ventas % 10) / 10);
  String get ratingFormateado => rating.toStringAsFixed(1);
}