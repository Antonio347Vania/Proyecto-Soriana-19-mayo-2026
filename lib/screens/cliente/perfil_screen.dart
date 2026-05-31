import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilScreen extends StatefulWidget {
  final String nombreUsuario;

  const PerfilScreen({super.key, required this.nombreUsuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? _datosUsuario;
  bool _isLoading = true;
  bool _isEditing = false;
  String? _errorMensaje;

  // Controladores para los campos editables
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _correoController = TextEditingController();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
  }

  @override
  void dispose() {
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosUsuario() async {
    setState(() {
      _isLoading = true;
      _errorMensaje = null;
    });

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Clientes')
          .doc(widget.nombreUsuario)
          .get();

      if (doc.exists) {
        setState(() {
          _datosUsuario = doc.data() as Map<String, dynamic>;
          // Inicializar controladores con los datos actuales
          _correoController.text = _datosUsuario?['correo'] ?? '';
          _telefonoController.text = _datosUsuario?['telefono'] ?? '';
          _direccionController.text = _datosUsuario?['direccion'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMensaje = 'No se encontraron datos del usuario';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMensaje = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarCambios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Clientes')
          .doc(widget.nombreUsuario)
          .update({
        'correo': _correoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'direccion': _direccionController.text.trim(),
      });

      // Actualizar datos locales
      setState(() {
        _datosUsuario?['correo'] = _correoController.text.trim();
        _datosUsuario?['telefono'] = _telefonoController.text.trim();
        _datosUsuario?['direccion'] = _direccionController.text.trim();
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado exitosamente')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMensaje = 'Error al guardar cambios: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  void _cancelarEdicion() {
    setState(() {
      _isEditing = false;
      // Restaurar valores originales
      _correoController.text = _datosUsuario?['correo'] ?? '';
      _telefonoController.text = _datosUsuario?['telefono'] ?? '';
      _direccionController.text = _datosUsuario?['direccion'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing && !_isLoading)
            TextButton(
              onPressed: _guardarCambios,
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMensaje != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 50, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(_errorMensaje!),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _cargarDatosUsuario,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header con avatar y nombre
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Avatar circular
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.nombreUsuario.isNotEmpty
                                      ? widget.nombreUsuario[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.nombreUsuario,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Cliente',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Información Personal
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Información Personal',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_isEditing)
                                    TextButton(
                                      onPressed: _cancelarEdicion,
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            
                            // Correo Electrónico
                            _buildEditableInfoRow(
                              Icons.email,
                              'Correo Electrónico',
                              _correoController,
                              _isEditing,
                            ),
                            const Divider(height: 1),
                            
                            // Teléfono
                            _buildEditableInfoRow(
                              Icons.phone,
                              'Teléfono',
                              _telefonoController,
                              _isEditing,
                              keyboardType: TextInputType.phone,
                            ),
                            const Divider(height: 1),
                            
                            // Dirección
                            _buildEditableInfoRow(
                              Icons.location_on,
                              'Dirección',
                              _direccionController,
                              _isEditing,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Botón de Cerrar Sesión
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _cerrarSesion(context);
                            },
                            icon: const Icon(Icons.exit_to_app, color: Colors.red),
                            label: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEditableInfoRow(
    IconData icon,
    String label,
    TextEditingController controller,
    bool isEditing, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
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
            child: Icon(icon, size: 20, color: Colors.red),
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
                isEditing
                    ? TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: keyboardType,
                        maxLines: maxLines,
                      )
                    : Text(
                        controller.text.isNotEmpty
                            ? controller.text
                            : 'No especificado',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Regresar al main.dart (pantalla principal)
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}