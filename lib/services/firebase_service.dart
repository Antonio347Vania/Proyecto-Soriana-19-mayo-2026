import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'Clientes';

  // Verificar si Firestore está disponible
  Future<bool> isFirestoreAvailable() async {
    try {
      await _firestore.collection(collectionName).limit(1).get();
      return true;
    } catch (e) {
      print('Firestore no disponible: $e');
      return false;
    }
  }

  // Guardar cliente en Firestore
  Future<void> guardarCliente({
    required String nombreUsuario,
    required String correo,
    required String telefono,
    required String direccion,
    required String contrasena,
  }) async {
    try {
      // Verificar si el usuario ya existe
      DocumentSnapshot existingUser = await _firestore.collection(collectionName).doc(nombreUsuario).get();
      
      if (existingUser.exists) {
        throw Exception('El nombre de usuario ya está registrado');
      }

      await _firestore.collection(collectionName).doc(nombreUsuario).set({
        'nombreUsuario': nombreUsuario,
        'correo': correo,
        'telefono': telefono,
        'direccion': direccion,
        'contrasena': contrasena,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
      print('Cliente registrado exitosamente: $nombreUsuario');
    } catch (e) {
      print('Error al guardar cliente: $e');
      throw Exception('Error al registrar: $e');
    }
  }

  // Verificar si usuario existe
  Future<bool> verificarCredenciales(String usuario, String contrasena) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(collectionName).doc(usuario).get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['contrasena'] == contrasena) {
          print('Credenciales válidas para: $usuario');
          return true;
        }
      }
      print('Credenciales inválidas para: $usuario');
      return false;
    } catch (e) {
      print('Error al verificar credenciales: $e');
      return false;
    }
  }

  // Obtener todos los clientes para el admin
  Stream<QuerySnapshot> obtenerClientes() {
    return _firestore.collection(collectionName).orderBy('fechaRegistro', descending: true).snapshots();
  }

}