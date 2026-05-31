import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../models/empleado_model.dart';

class EditarEmpleadoScreen extends StatefulWidget {
  final EmpleadoModel empleado;

  const EditarEmpleadoScreen({super.key, required this.empleado});

  @override
  State<EditarEmpleadoScreen> createState() => _EditarEmpleadoScreenState();
}

class _EditarEmpleadoScreenState extends State<EditarEmpleadoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _numeroController;
  late TextEditingController _direccionController;
  late TextEditingController _puestoController;
  late TextEditingController _salarioController;
  late TextEditingController _edadController;
  
  late String _departamento;
  late String _estado;
  String _imagenBase64 = '';
  bool _isLoading = false;
  
  final List<String> _departamentos = ['Ventas', 'Logística', 'Administración', 'Almacén'];
  final List<String> _estados = ['Activo', 'Inactivo', 'Vacaciones'];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.empleado.nombre);
    _apellidoController = TextEditingController(text: widget.empleado.apellido);
    _emailController = TextEditingController(text: widget.empleado.email);
    _numeroController = TextEditingController(text: widget.empleado.numero);
    _direccionController = TextEditingController(text: widget.empleado.direccion);
    _puestoController = TextEditingController(text: widget.empleado.puesto);
    _salarioController = TextEditingController(text: widget.empleado.salario.toString());
    _edadController = TextEditingController(text: widget.empleado.edad.toString());
    
    // Validar que el departamento existe en la lista
    if (_departamentos.contains(widget.empleado.departamento)) {
      _departamento = widget.empleado.departamento;
    } else {
      _departamento = _departamentos[0];
    }
    
    // Validar que el estado existe en la lista
    if (_estados.contains(widget.empleado.estado)) {
      _estado = widget.empleado.estado;
    } else {
      _estado = _estados[0];
    }
    
    _imagenBase64 = widget.empleado.imagen;
  }

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

  Future<void> _actualizarEmpleado() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await FirebaseFirestore.instance
          .collection('Empleados')
          .doc(widget.empleado.id)
          .update({
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
          const SnackBar(content: Text('Empleado actualizado exitosamente')),
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
        title: const Text('Editar Empleado'),
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
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person, size: 60, color: Colors.grey);
                            },
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
              
              // Número - SOLO NÚMEROS
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
                onPressed: _isLoading ? null : _actualizarEmpleado,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Actualizar Empleado'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}