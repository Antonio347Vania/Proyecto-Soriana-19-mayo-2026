import 'package:cloud_firestore/cloud_firestore.dart';

class PedidoModel {
  String id;
  String nombreUsuario;
  String usuarioId;
  List<Map<String, dynamic>> productos;
  String metodoPago;
  double total;
  DateTime fecha;
  String estado; // Pendiente, Pagado, Enviado, Entregado, Cancelado

  PedidoModel({
    required this.id,
    required this.nombreUsuario,
    required this.usuarioId,
    required this.productos,
    required this.metodoPago,
    required this.total,
    required this.fecha,
    this.estado = 'Pendiente',
  });

  factory PedidoModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PedidoModel(
      id: id,
      nombreUsuario: data['nombreUsuario'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      productos: List<Map<String, dynamic>>.from(data['productos'] ?? []),
      metodoPago: data['metodoPago'] ?? '',
      total: (data['total'] ?? 0).toDouble(),
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estado: data['estado'] ?? 'Pendiente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreUsuario': nombreUsuario,
      'usuarioId': usuarioId,
      'productos': productos,
      'metodoPago': metodoPago,
      'total': total,
      'fecha': Timestamp.fromDate(fecha),
      'estado': estado,
    };
  }

  String get fechaFormateada {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}