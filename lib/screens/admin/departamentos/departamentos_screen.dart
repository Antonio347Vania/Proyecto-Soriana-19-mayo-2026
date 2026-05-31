import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/departamento_model.dart';
import 'detalle_departamento_screen.dart';
import 'agregar_departamento_screen.dart';
import 'editar_departamento_screen.dart';
import '../admin_home_screen.dart';

class DepartamentosScreen extends StatefulWidget {
  const DepartamentosScreen({super.key});

  @override
  State<DepartamentosScreen> createState() => _DepartamentosScreenState();
}

class _DepartamentosScreenState extends State<DepartamentosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _verificarConexionFirebase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _verificarConexionFirebase() async {
    try {
      print('=== VERIFICANDO CONEXIÓN A FIREBASE ===');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Departamentos')
          .get();
      print('Número de departamentos encontrados: ${snapshot.docs.length}');
      
      if (snapshot.docs.isNotEmpty) {
        print('Primer departamento:');
        print('ID: ${snapshot.docs.first.id}');
        print('Datos: ${snapshot.docs.first.data()}');
      }
      setState(() {});
    } catch (e) {
      print('Error al verificar conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Departamentos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _verificarConexionFirebase();
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _agregarDepartamento();
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
                hintText: 'Buscar departamento...',
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Subtítulo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gestión de categorías de productos',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Lista de departamentos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Departamentos')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.category, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text('No hay departamentos registrados'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _agregarDepartamento,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Agregar Departamento'),
                        ),
                      ],
                    ),
                  );
                }

                var departamentosData = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String nombre = (data['nombre'] ?? '').toLowerCase();
                  return _searchQuery.isEmpty || nombre.contains(_searchQuery);
                }).toList();

                if (departamentosData.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text('No se encontraron resultados para "$_searchQuery"'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: departamentosData.length,
                  itemBuilder: (context, index) {
                    var doc = departamentosData[index];
                    var data = doc.data() as Map<String, dynamic>;
                    var departamento = DepartamentoModel.fromFirestore(data, doc.id);
                    return _buildDepartamentoCard(departamento);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartamentoCard(DepartamentoModel departamento) {
    int ventas = (departamento.cantProductos * 15) % 1000;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _verDetalleDepartamento(departamento);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Imagen y nombre
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del departamento
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: departamento.imagen.isNotEmpty
                        ? Image.network(
                            departamento.imagen,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 25, color: Colors.grey),
                              );
                            },
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.category, size: 25, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Nombre del departamento
                  Expanded(
                    child: Text(
                      departamento.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Botones de acción
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                        onPressed: () {
                          _editarDepartamento(departamento);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () {
                          _eliminarDepartamento(departamento);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Fila inferior: Productos y Ventas
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Productos: ${departamento.cantProductos}',
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.trending_up, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Ventas: $ventas',
                            style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _agregarDepartamento() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AgregarDepartamentoScreen(),
      ),
    ).then((_) {
      _verificarConexionFirebase();
      setState(() {});
    });
  }

  void _verDetalleDepartamento(DepartamentoModel departamento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleDepartamentoScreen(departamento: departamento),
      ),
    );
  }

  void _editarDepartamento(DepartamentoModel departamento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarDepartamentoScreen(departamento: departamento),
      ),
    ).then((_) {
      _verificarConexionFirebase();
      setState(() {});
    });
  }

  void _eliminarDepartamento(DepartamentoModel departamento) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar el departamento "${departamento.nombre}"?'),
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
            .collection('Departamentos')
            .doc(departamento.id)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Departamento eliminado exitosamente')),
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