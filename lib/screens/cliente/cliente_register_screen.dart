import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:soriana_vania/screens/cliente/cliente_login_screen.dart';
import '../../services/firebase_service.dart';
import 'cliente_home_screen.dart';

class ClienteRegisterScreen extends StatefulWidget {
  const ClienteRegisterScreen({super.key});

  @override
  State<ClienteRegisterScreen> createState() => _ClienteRegisterScreenState();
}

class _ClienteRegisterScreenState extends State<ClienteRegisterScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _aceptaTerminos = false;
  bool _isLoading = false;
  String? _errorMensaje;

  // Validar que solo se ingresen números en el teléfono
  void _onTelefonoChanged(String value) {
    String filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (filtered != value) {
      _telefonoController.value = TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }
  }

  Future<void> _registrarUsuario() async {
    String nombre = _nombreController.text.trim();
    String correo = _correoController.text.trim();
    String telefono = _telefonoController.text.trim();
    String direccion = _direccionController.text.trim();
    String contrasena = _contrasenaController.text.trim();
    String confirmarContrasena = _confirmarContrasenaController.text.trim();

    if (nombre.isEmpty || correo.isEmpty || telefono.isEmpty || direccion.isEmpty || contrasena.isEmpty) {
      setState(() {
        _errorMensaje = 'Por favor complete todos los campos';
      });
      return;
    }

    if (contrasena.length < 6) {
      setState(() {
        _errorMensaje = 'La contraseña debe tener al menos 6 caracteres';
      });
      return;
    }

    if (contrasena != confirmarContrasena) {
      setState(() {
        _errorMensaje = 'Las contraseñas no coinciden';
      });
      return;
    }

    if (!_aceptaTerminos) {
      setState(() {
        _errorMensaje = 'Debe aceptar los términos y condiciones';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMensaje = null;
    });

    try {
      await _firebaseService.guardarCliente(
        nombreUsuario: nombre,
        correo: correo,
        telefono: telefono,
        direccion: direccion,
        contrasena: contrasena,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Registro exitoso!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ClienteHomeScreen(nombreUsuario: nombre),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMensaje = 'Error al registrar: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Regresar a la pantalla anterior (ClienteLoginScreen)
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.app_registration,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Crear Nueva Cuenta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Únete a la familia Soriana Vania',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    // Nombre de Usuario
                    TextField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de Usuario',
                        hintText: 'Escribe tu nombre de usuario',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Correo Electrónico
                    TextField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        hintText: 'ejemplo@correo.com',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Número de Teléfono - SOLO NÚMEROS
                    TextField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Número de Teléfono',
                        hintText: '6561234567',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        counterText: '',
                      ),
                      maxLength: 10,
                      onChanged: _onTelefonoChanged,
                    ),
                    const SizedBox(height: 15),
                    // Dirección de Entrega
                    TextField(
                      controller: _direccionController,
                      decoration: InputDecoration(
                        labelText: 'Dirección de Entrega',
                        hintText: 'Calle, número, colonia, código postal, ciudad...',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Contraseña
                    TextField(
                      controller: _contrasenaController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Mínimo 6 caracteres',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Confirmar Contraseña
                    TextField(
                      controller: _confirmarContrasenaController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        hintText: 'Repite tu contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Términos y condiciones
                    Row(
                      children: [
                        Checkbox(
                          value: _aceptaTerminos,
                          onChanged: (value) {
                            setState(() {
                              _aceptaTerminos = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _aceptaTerminos = !_aceptaTerminos;
                              });
                            },
                            child: const Text(
                              'Acepto los términos y condiciones y la política de privacidad de Soriana Vania',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMensaje != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _errorMensaje!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _registrarUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Crear Mi Cuenta',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Ya tengo cuenta, iniciar sesión'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Regresar al menú principal'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}