import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/pedido_model.dart';
import 'detalle_pedido_screen.dart';
// ignore: unused_import
import 'editar_pedido_screen.dart';
import '../admin_home_screen.dart'; // Agregar import

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _estadoFiltro = 'Todos';
  final List<String> _estados = ['Todos', 'Pendiente', 'Pagado', 'Enviado', 'Entregado', 'Cancelado'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _eliminarPedido(String pedidoId, String nombreUsuario) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar el pedido de "$nombreUsuario"?'),
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
        await FirebaseFirestore.instance.collection('Pedidos').doc(pedidoId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pedido eliminado exitosamente')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Pedidos',
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
            onPressed: () => setState(() {}),
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
                hintText: 'Buscar por usuario...',
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
          
          // Filtro de estado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _estados.length,
                itemBuilder: (context, index) {
                  String estado = _estados[index];
                  bool isSelected = _estadoFiltro == estado;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(estado),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _estadoFiltro = estado;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.red,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Lista de pedidos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Pedidos')
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay pedidos registrados'));
                }

                var pedidosData = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String nombreUsuario = (data['nombreUsuario'] ?? '').toLowerCase();
                  bool matchesSearch = _searchQuery.isEmpty || nombreUsuario.contains(_searchQuery);
                  bool matchesEstado = _estadoFiltro == 'Todos' || data['estado'] == _estadoFiltro;
                  return matchesSearch && matchesEstado;
                }).toList();

                if (pedidosData.isEmpty) {
                  return const Center(child: Text('No se encontraron resultados'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pedidosData.length,
                  itemBuilder: (context, index) {
                    var doc = pedidosData[index];
                    var data = doc.data() as Map<String, dynamic>;
                    var pedido = PedidoModel.fromFirestore(data, doc.id);
                    return _buildPedidoCard(pedido);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPedidoCard(PedidoModel pedido) {
    Color estadoColor;
    switch (pedido.estado) {
      case 'Pagado': estadoColor = Colors.green; break;
      case 'Pendiente': estadoColor = Colors.orange; break;
      case 'Enviado': estadoColor = Colors.blue; break;
      case 'Entregado': estadoColor = Colors.purple; break;
      case 'Cancelado': estadoColor = Colors.red; break;
      default: estadoColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallePedidoScreen(pedido: pedido),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pedido.nombreUsuario,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: estadoColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          pedido.estado,
                          style: TextStyle(color: estadoColor, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botón de eliminar
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _eliminarPedido(pedido.id, pedido.nombreUsuario),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${pedido.productos.length} productos',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: \$${pedido.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                pedido.fechaFormateada,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}