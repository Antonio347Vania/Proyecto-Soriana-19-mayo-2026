import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AgregarEmpleadoScreen extends StatefulWidget {
  const AgregarEmpleadoScreen({super.key});

  @override
  State<AgregarEmpleadoScreen> createState() => _AgregarEmpleadoScreenState();
}

class _AgregarEmpleadoScreenState extends State<AgregarEmpleadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _numeroController = TextEditingController();
  final _direccionController = TextEditingController();
  final _puestoController = TextEditingController();
  final _salarioController = TextEditingController();
  final _edadController = TextEditingController();
  
  String _departamento = 'Ventas';
  String _estado = 'Activo';
  String _imagenBase64 = '';
  bool _isLoading = false;
  
  final List<String> _departamentos = ['Ventas', 'Logística', 'Administración', 'Almacén'];
  final List<String> _estados = ['Activo', 'Inactivo', 'Vacaciones'];

  // Validar que solo se ingresen números
  void _onNumeroChanged(String value) {
    String filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (filtered != value) {
      _numeroController.value = TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }
  }

  void _onEdadChanged(String value) {
    String filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (filtered != value) {
      _edadController.value = TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      setState(() {
        _imagenBase64 = base64Image;
      });
    }
  }

  Future<void> _guardarEmpleado() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await FirebaseFirestore.instance.collection('Empleados').add({
        'Nombre': _nombreController.text.trim(),
        'Apellido': _apellidoController.text.trim(),
        'email': _emailController.text.trim(),
        'Numero': _numeroController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'Puesto': _puestoController.text.trim(),
        'departamento': _departamento,
        'salario': double.parse(_salarioController.text),
        'estado': _estado,
        'Edad': int.parse(_edadController.text),
        'imagen': _imagenBase64,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empleado agregado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
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
        title: const Text('Agregar Empleado'),
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
              // Imagen
              GestureDetector(
                onTap: _seleccionarImagen,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  child: _imagenBase64.isNotEmpty
                      ? ClipOval(
                          child: Image.memory(
                            base64Decode(_imagenBase64),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              
              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              
              // Apellido
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              
              // Número (Teléfono) - SOLO NÚMEROS
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Número de Teléfono',
                  hintText: '6561234567',
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                maxLength: 10,
                onChanged: _onNumeroChanged,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              
              // Dirección
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              
              // Puesto
              TextFormField(
                controller: _puestoController,
                decoration: const InputDecoration(labelText: 'Puesto'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              
              // Departamento
              DropdownButtonFormField<String>(
                initialValue: _departamento,
                items: _departamentos.map((depto) {
                  return DropdownMenuItem<String>(
                    value: depto,
                    child: Text(depto),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _departamento = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Departamento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              
              // Salario
              TextFormField(
                controller: _salarioController,
                decoration: const InputDecoration(labelText: 'Salario'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              
              // Estado
              DropdownButtonFormField<String>(
                initialValue: _estado,
                items: _estados.map((estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _estado = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              
              // Edad - SOLO NÚMEROS
              TextFormField(
                controller: _edadController,
                decoration: const InputDecoration(
                  labelText: 'Edad',
                  hintText: '25',
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                maxLength: 3,
                onChanged: _onEdadChanged,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _guardarEmpleado,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Empleado'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}