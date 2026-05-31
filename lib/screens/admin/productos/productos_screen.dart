import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/producto_model.dart';
import 'detalle_producto_screen.dart';
import 'agregar_producto_screen.dart';
import 'editar_producto_screen.dart';
import '../admin_home_screen.dart'; // Agregar import

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _categoriaSeleccionada = 'Todas';
  List<String> _categorias = ['Todas'];
  
  // Mapa para guardar nombres de departamentos por ID
  final Map<String, String> _departamentosMap = {};

  @override
  void initState() {
    super.initState();
    _cargarDepartamentos();
  }

  Future<void> _cargarDepartamentos() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Departamentos')
          .get();
      
      setState(() {
        _categorias = ['Todas'];
        for (var doc in snapshot.docs) {
          String nombre = doc['nombre'] ?? 'Sin nombre';
          _categorias.add(nombre);
          _departamentosMap[doc.id] = nombre;
        }
      });
    } catch (e) {
      print('Error al cargar departamentos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Productos',
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _cargarDepartamentos();
              setState(() {});
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
                hintText: 'Buscar productos...',
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
          
          // Filtros por categoría
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                String categoria = _categorias[index];
                bool isSelected = _categoriaSeleccionada == categoria;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(categoria),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _categoriaSeleccionada = categoria;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Colors.red,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Botón agregar producto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () {
                  _agregarProducto();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar Nuevo Producto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Lista de productos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Productos')
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
                        const Icon(Icons.inventory, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text('No hay productos registrados'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _agregarProducto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Agregar Producto'),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar productos
                var productosData = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String nombre = (data['nombre'] ?? '').toLowerCase();
                  String departamentoId = data['departamento'] ?? '';
                  String departamentoNombre = _departamentosMap[departamentoId] ?? '';
                  
                  bool matchesSearch = _searchQuery.isEmpty || nombre.contains(_searchQuery);
                  bool matchesCategoria = _categoriaSeleccionada == 'Todas' || 
                                         departamentoNombre == _categoriaSeleccionada;
                  
                  return matchesSearch && matchesCategoria;
                }).toList();

                if (productosData.isEmpty) {
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
                  padding: const EdgeInsets.all(16),
                  itemCount: productosData.length,
                  itemBuilder: (context, index) {
                    var doc = productosData[index];
                    var data = doc.data() as Map<String, dynamic>;
                    var producto = ProductoModel.fromFirestore(data, doc.id);
                    return _buildProductoCard(producto);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoCard(ProductoModel producto) {
    String nombreDepartamento = _departamentosMap[producto.departamento] ?? 'Sin categoría';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _verDetalleProducto(producto);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen del producto
              SizedBox(
                width: 70,
                height: 70,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: producto.imagen.isNotEmpty
                      ? Image.network(
                          producto.imagen,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 30, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nombreDepartamento,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (producto.descuento > 0)
                          Text(
                            producto.precioFormateado,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          producto.precioConDescuentoFormateado,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: producto.descuento > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                        if (producto.descuento > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '-${producto.descuento}%',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: producto.stock > 10 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Stock: ${producto.stock}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                        onPressed: () {
                          _editarProducto(producto);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () {
                          _eliminarProducto(producto);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _agregarProducto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AgregarProductoScreen(),
      ),
    ).then((_) {
      _cargarDepartamentos();
      setState(() {});
    });
  }

  void _verDetalleProducto(ProductoModel producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleProductoScreen(
          producto: producto,
          nombreDepartamento: _departamentosMap[producto.departamento] ?? 'Sin categoría',
        ),
      ),
    );
  }

  void _editarProducto(ProductoModel producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarProductoScreen(producto: producto),
      ),
    ).then((_) {
      _cargarDepartamentos();
      setState(() {});
    });
  }

  void _eliminarProducto(ProductoModel producto) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar el producto "${producto.nombre}"?'),
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
            .collection('Productos')
            .doc(producto.id)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado exitosamente')),
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