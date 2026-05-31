import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/empleado_model.dart';
import '../../../utils/image_helper.dart';
import 'detalle_empleado_screen.dart';
import 'agregar_empleado_screen.dart';
import 'editar_empleado_screen.dart';
import '../admin_home_screen.dart'; // Agregar import

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({super.key});

  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _estadoFiltro = 'Todos';
  String _departamentoFiltro = 'Todos';
  
  final List<String> _estados = ['Todos', 'Activo', 'Inactivo', 'Vacaciones'];
  final List<String> _departamentos = ['Todos', 'Ventas', 'Logística', 'Administración', 'Almacén'];
  
  bool _mostrarFiltros = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Empleados',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // CORREGIDO: Regresar a AdminHomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminHomeScreen(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              setState(() {
                _mostrarFiltros = !_mostrarFiltros;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _agregarEmpleado();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar empleado...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Filtros expandibles
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _mostrarFiltros ? 120 : 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Filtro por estado
                    Row(
                      children: [
                        const Text(
                          'Estado: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: _estados.map((estado) {
                              return FilterChip(
                                label: Text(estado),
                                selected: _estadoFiltro == estado,
                                onSelected: (selected) {
                                  setState(() {
                                    _estadoFiltro = estado;
                                  });
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor: Colors.green,
                                labelStyle: TextStyle(
                                  color: _estadoFiltro == estado ? Colors.white : Colors.black,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Filtro por departamento
                    Row(
                      children: [
                        const Text(
                          'Departamento: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: _departamentos.map((departamento) {
                              return FilterChip(
                                label: Text(departamento),
                                selected: _departamentoFiltro == departamento,
                                onSelected: (selected) {
                                  setState(() {
                                    _departamentoFiltro = departamento;
                                  });
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor: Colors.blue,
                                labelStyle: TextStyle(
                                  color: _departamentoFiltro == departamento ? Colors.white : Colors.black,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Lista de empleados
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Empleados').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay empleados registrados'),
                  );
                }

                // Filtrar empleados
                var empleadosData = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String nombreCompleto = '${data['Nombre'] ?? ''} ${data['Apellido'] ?? ''}'.toLowerCase();
                  String puesto = (data['Puesto'] ?? '').toLowerCase();
                  String departamento = (data['departamento'] ?? '').toLowerCase();
                  
                  bool matchesSearch = _searchQuery.isEmpty ||
                      nombreCompleto.contains(_searchQuery) ||
                      puesto.contains(_searchQuery) ||
                      departamento.contains(_searchQuery);
                  
                  bool matchesEstado = _estadoFiltro == 'Todos' || data['estado'] == _estadoFiltro;
                  bool matchesDepartamento = _departamentoFiltro == 'Todos' || data['departamento'] == _departamentoFiltro;
                  
                  return matchesSearch && matchesEstado && matchesDepartamento;
                }).toList();

                int totalFiltrados = empleadosData.length;
                int totalEmpleados = snapshot.data!.docs.length;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mostrando $totalFiltrados de $totalEmpleados empleados',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          if (_estadoFiltro != 'Todos' || _departamentoFiltro != 'Todos' || _searchQuery.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _estadoFiltro = 'Todos';
                                  _departamentoFiltro = 'Todos';
                                });
                              },
                              child: const Text('Limpiar filtros'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: empleadosData.length,
                        itemBuilder: (context, index) {
                          var doc = empleadosData[index];
                          var data = doc.data() as Map<String, dynamic>;
                          var empleado = EmpleadoModel.fromFirestore(data, doc.id);
                          return _buildEmpleadoCard(empleado);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpleadoCard(EmpleadoModel empleado) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _verDetalleEmpleado(empleado);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen del empleado
              SizedBox(
                width: 60,
                height: 60,
                child: ImageHelper.getImageWidget(empleado.imagen, 60),
              ),
              const SizedBox(width: 16),
              // Información del empleado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      empleado.nombreCompleto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      empleado.puesto,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getEstadoColor(empleado.estado).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        empleado.departamento,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getEstadoColor(empleado.estado),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Botones de acción
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _editarEmpleado(empleado);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _eliminarEmpleado(empleado);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Activo':
        return Colors.green;
      case 'Inactivo':
        return Colors.red;
      case 'Vacaciones':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _agregarEmpleado() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AgregarEmpleadoScreen(),
      ),
    ).then((_) => setState(() {}));
  }

  void _verDetalleEmpleado(EmpleadoModel empleado) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleEmpleadoScreen(empleado: empleado),
      ),
    );
  }

  void _editarEmpleado(EmpleadoModel empleado) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarEmpleadoScreen(empleado: empleado),
      ),
    ).then((_) => setState(() {}));
  }

  void _eliminarEmpleado(EmpleadoModel empleado) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar a ${empleado.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('Empleados')
            .doc(empleado.id)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Empleado eliminado exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }
}