import 'package:flutter/material.dart';
import '../../../models/empleado_model.dart';
import '../../../utils/image_helper.dart';
import 'editar_empleado_screen.dart';

class DetalleEmpleadoScreen extends StatelessWidget {
  final EmpleadoModel empleado;

  const DetalleEmpleadoScreen({super.key, required this.empleado});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Detalle de Empleado',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarEmpleadoScreen(empleado: empleado),
                ),
              ).then((_) => Navigator.pop(context));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con imagen y nombre
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
                children: [
                  // Imagen circular grande
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ClipOval(
                      child: empleado.imagen.isNotEmpty
                          ? ImageHelper.getImageWidget(empleado.imagen, 100)
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.white,
                              child: const Icon(Icons.person, size: 60, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    empleado.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    empleado.puesto,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      empleado.departamento,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            
            // Información de Contacto
            _buildSection(
              title: 'Información de Contacto',
              children: [
                _buildInfoRow(Icons.email, 'Email', empleado.email),
                const Divider(),
                _buildInfoRow(Icons.phone, 'Teléfono', empleado.numero),
                const Divider(),
                _buildInfoRow(Icons.location_on, 'Dirección', empleado.direccion), // Aquí se muestra
              ],
            ),
            
            // Información Laboral
            _buildSection(
              title: 'Información Laboral',
              children: [
                _buildInfoRow(Icons.work, 'Puesto', empleado.puesto),
                const Divider(),
                _buildInfoRow(Icons.attach_money, 'Salario Mensual', '\$${empleado.salario.toStringAsFixed(2)}'),
                const Divider(),
                _buildInfoRow(Icons.business, 'Departamento', empleado.departamento),
                const Divider(),
                _buildInfoRow(
                  Icons.circle,
                  'Estado',
                  empleado.estado,
                  textColor: _getEstadoColor(empleado.estado),
                ),
              ],
            ),
            
            // Información Personal
            _buildSection(
              title: 'Información Personal',
              children: [
                _buildInfoRow(Icons.person, 'Nombre completo', empleado.nombreCompleto),
                const Divider(),
                _buildInfoRow(Icons.cake, 'Edad', '${empleado.edad} años'),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
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
                Text(
                  value.isEmpty ? 'No especificado' : value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
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
}