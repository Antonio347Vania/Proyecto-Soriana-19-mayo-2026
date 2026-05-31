import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/cliente_model.dart';

class EditarClienteScreen extends StatefulWidget {
  final ClienteModel cliente;

  const EditarClienteScreen({super.key, required this.cliente});

  @override
  State<EditarClienteScreen> createState() => _EditarClienteScreenState();
}

class _EditarClienteScreenState extends State<EditarClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreUsuarioController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _contrasenaController;
  late TextEditingController _confirmarContrasenaController;
  
  bool _isLoading = false;
  bool _cambiarContrasena = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  @override
  void initState() {
    super.initState();
    _nombreUsuarioController = TextEditingController(text: widget.cliente.nombreUsuario);
    _correoController = TextEditingController(text: widget.cliente.correo);
    _telefonoController = TextEditingController(text: widget.cliente.telefono);
    _direccionController = TextEditingController(text: widget.cliente.direccion);
    _contrasenaController = TextEditingController();
    _confirmarContrasenaController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreUsuarioController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _actualizarCliente() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_cambiarContrasena && _contrasenaController.text != _confirmarContrasenaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      Map<String, dynamic> datosActualizar = {
        'nombreUsuario': _nombreUsuarioController.text.trim(),
        'correo': _correoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'direccion': _direccionController.text.trim(),
      };
      
      if (_cambiarContrasena && _contrasenaController.text.isNotEmpty) {
        datosActualizar['contrasena'] = _contrasenaController.text;
      }
      
      await FirebaseFirestore.instance
          .collection('Clientes')
          .doc(widget.cliente.id)
          .update(datosActualizar);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente actualizado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre de Usuario
              TextFormField(
                controller: _nombreUsuarioController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              
              // Correo Electrónico
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Campo requerido';
                  if (!value.contains('@')) return 'Ingrese un correo válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Teléfono - SOLO NÚMEROS
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  hintText: '6561234567',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                maxLength: 10,
                onChanged: _onTelefonoChanged,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              
              // Dirección
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              
              // Checkbox para cambiar contraseña
              CheckboxListTile(
                value: _cambiarContrasena,
                onChanged: (value) {
                  setState(() {
                    _cambiarContrasena = value!;
                    if (!_cambiarContrasena) {
                      _contrasenaController.clear();
                      _confirmarContrasenaController.clear();
                    }
                  });
                },
                title: const Text('Cambiar contraseña'),
                activeColor: Colors.red,
              ),
              
              if (_cambiarContrasena) ...[
                const SizedBox(height: 16),
                // Nueva Contraseña
                TextFormField(
                  controller: _contrasenaController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    border: const OutlineInputBorder(),
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
                  ),
                  validator: (value) {
                    if (_cambiarContrasena && value!.isEmpty) return 'Campo requerido';
                    if (_cambiarContrasena && value!.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Confirmar Contraseña
                TextFormField(
                  controller: _confirmarContrasenaController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    border: const OutlineInputBorder(),
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
                  ),
                  validator: (value) {
                    if (_cambiarContrasena && value!.isEmpty) return 'Campo requerido';
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _actualizarCliente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Actualizar Cliente', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}