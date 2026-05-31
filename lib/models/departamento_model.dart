class DepartamentoModel {
  String id;
  String nombre;
  int cantProductos;
  String imagen; // URL de la imagen

  DepartamentoModel({
    required this.id,
    required this.nombre,
    required this.cantProductos,
    required this.imagen,
  });

  // Convertir de Firestore a objeto
  factory DepartamentoModel.fromFirestore(Map<String, dynamic> data, String id) {
    return DepartamentoModel(
      id: id,
      nombre: data['nombre'] ?? '',
      cantProductos: data['cantProductos'] ?? 0,
      imagen: data['imagen'] ?? '', // URL directa, no necesita decodificación
    );
  }

  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantProductos': cantProductos,
      'imagen': imagen,
    };
  }
}