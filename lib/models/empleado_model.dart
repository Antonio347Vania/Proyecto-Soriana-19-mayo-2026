class EmpleadoModel {
  String id;
  String nombre;
  String apellido;
  String email;
  String numero;
  String direccion;  // En Firestore también es "direccion"
  String puesto;
  String departamento;
  double salario;
  String estado;
  int edad;
  String imagen;

  EmpleadoModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.numero,
    required this.direccion,
    required this.puesto,
    required this.departamento,
    required this.salario,
    required this.estado,
    required this.edad,
    required this.imagen,
  });

  // Convertir de Firestore a objeto
  factory EmpleadoModel.fromFirestore(Map<String, dynamic> data, String id) {
    // Manejar Numero que puede ser int o String
    String numeroValue = '';
    if (data['Numero'] != null) {
      if (data['Numero'] is int) {
        numeroValue = data['Numero'].toString();
      } else if (data['Numero'] is String) {
        numeroValue = data['Numero'];
      }
    }

    // Manejar imagen
    String imagenValue = data['imagen'] ?? '';
    if (imagenValue.startsWith('data:image')) {
      List<String> parts = imagenValue.split(',');
      if (parts.length > 1) {
        imagenValue = parts[1];
      }
    }

    return EmpleadoModel(
      id: id,
      nombre: data['Nombre'] ?? '',
      apellido: data['Apellido'] ?? '',
      email: data['email'] ?? '',
      numero: numeroValue,
      direccion: data['direccion'] ?? '',  // Ahora es "direccion" (bien escrito)
      puesto: data['Puesto'] ?? '',
      departamento: data['departamento'] ?? '',
      salario: (data['salario'] ?? 0).toDouble(),
      estado: data['estado'] ?? 'Activo',
      edad: data['Edad'] ?? 0,
      imagen: imagenValue,
    );
  }

  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'Nombre': nombre,
      'Apellido': apellido,
      'email': email,
      'Numero': numero,
      'direccion': direccion,  // Ahora es "direccion" (bien escrito)
      'Puesto': puesto,
      'departamento': departamento,
      'salario': salario,
      'estado': estado,
      'Edad': edad,
      'imagen': imagen,
    };
  }

  String get nombreCompleto => '$nombre $apellido';
}