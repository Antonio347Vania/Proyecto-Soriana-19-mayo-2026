import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteModel {
  String id;
  String nombreUsuario;
  String correo;
  String telefono;
  String direccion;
  String contrasena;
  DateTime fechaRegistro;

  ClienteModel({
    required this.id,
    required this.nombreUsuario,
    required this.correo,
    required this.telefono,
    required this.direccion,
    required this.contrasena,
    required this.fechaRegistro,
  });

  // Convertir de Firestore a objeto
  factory ClienteModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ClienteModel(
      id: id,
      nombreUsuario: data['nombreUsuario'] ?? '',
      correo: data['correo'] ?? '',
      telefono: data['telefono'] ?? '',
      direccion: data['direccion'] ?? '',
      contrasena: data['contrasena'] ?? '',
      fechaRegistro: (data['fechaRegistro'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convertir objeto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombreUsuario': nombreUsuario,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'contrasena': contrasena,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }

  String get fechaFormateada {
    return '${fechaRegistro.day}/${fechaRegistro.month}/${fechaRegistro.year}';
  }
}