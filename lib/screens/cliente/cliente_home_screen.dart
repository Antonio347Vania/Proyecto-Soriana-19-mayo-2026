import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/producto_model.dart';
import '../../models/carrito_item_model.dart';
import '../../providers/carrito_provider.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/producto_card.dart';
import 'carrito_screen.dart';
import 'perfil_screen.dart';

class ClienteHomeScreen extends StatefulWidget {
  final String nombreUsuario;

  const ClienteHomeScreen({super.key, required this.nombreUsuario});

  @override
  State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
}

class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _categoriaSeleccionada = 'Todos';
  List<String> _categorias = ['Todos'];
  final Map<String, String> _departamentosMap = {};

  @override
  void initState() {
    super.initState();
    _cargarDepartamentos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDepartamentos() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Departamentos')
          .get();
      
      setState(() {
        _categorias = ['Todos'];
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

  void _verDetalleProducto(ProductoModel producto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detalle de ${producto.nombre} en construcción')),
    );
  }

  void _agregarAlCarrito(ProductoModel producto) {
    final carrito = Provider.of<CarritoProvider>(context, listen: false);
    
    String nombreDepartamento = _departamentosMap[producto.departamento] ?? 'Sin categoría';
    
    final carritoItem = CarritoItemModel(
      productoId: producto.id,
      nombre: producto.nombre,
      departamento: nombreDepartamento,
      precio: producto.precio,
      precioConDescuento: producto.precioConDescuento,
      imagen: producto.imagen,
      descuento: producto.descuento,
    );
    
    carrito.agregarProducto(carritoItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.nombre} agregado al carrito'),
        duration: const Duration(seconds: 1),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Soriana Vania',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Consumer<CarritoProvider>(
            builder: (context, carrito, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarritoScreen(nombreUsuario: widget.nombreUsuario),
                        ),
                      );
                    },
                  ),
                  if (carrito.cantidadItems > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${carrito.cantidadItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
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
          
          // Carrusel de banners
          const BannerCarousel(),
          
          const SizedBox(height: 20),
          
          // Categorías (chips)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 45,
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
          
          const SizedBox(height: 16),
          
          // Título de productos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nuestros Productos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Productos').snapshots(),
                  builder: (context, snapshot) {
                    int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Text(
                      '$total productos disponibles',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
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
                  return const Center(
                    child: Text('No hay productos disponibles'),
                  );
                }

                // Filtrar productos
                var productosData = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String nombre = (data['nombre'] ?? '').toLowerCase();
                  String departamentoId = data['departamento'] ?? '';
                  String departamentoNombre = _departamentosMap[departamentoId] ?? '';
                  
                  bool matchesSearch = _searchQuery.isEmpty || nombre.contains(_searchQuery);
                  bool matchesCategoria = _categoriaSeleccionada == 'Todos' || 
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
                        Text('No se encontraron productos para "$_searchQuery"'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: productosData.length,
                  itemBuilder: (context, index) {
                    var doc = productosData[index];
                    var data = doc.data() as Map<String, dynamic>;
                    var producto = ProductoModel.fromFirestore(data, doc.id);
                    return ProductoCard(
                      producto: producto,
                      onTap: () {
                        _verDetalleProducto(producto);
                      },
                      onAddToCart: () {
                        _agregarAlCarrito(producto);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header del drawer con información del usuario
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hola, ${widget.nombreUsuario}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Bienvenido a Soriana Vania',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Inicio
          ListTile(
            leading: const Icon(Icons.home, color: Colors.red),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          
          // Categorías (departamentos dinámicos)
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Categorías',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                if (_categorias[index] == 'Todos') return const SizedBox.shrink();
                return ListTile(
                  leading: const Icon(Icons.category, color: Colors.grey),
                  title: Text(_categorias[index]),
                  onTap: () {
                    setState(() {
                      _categoriaSeleccionada = _categorias[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          
          const Divider(),
          
          // Perfil - CORREGIDO
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.grey),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerfilScreen(nombreUsuario: widget.nombreUsuario),
                ),
              );
            },
          ),
          
          // Cerrar sesión - CORREGIDO
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              _cerrarSesion(context);
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}