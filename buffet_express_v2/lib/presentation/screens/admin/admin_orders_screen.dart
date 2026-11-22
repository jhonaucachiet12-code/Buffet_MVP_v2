import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios del proveedor de pedidos
    final orderProv = context.watch<OrderProvider>();
    final allOrders = orderProv.orders;

    // 1. Filtramos los pedidos según su estado
    final pendingOrders = allOrders
        .where(
          (o) => o['status'] == 'Pending_Payment' || o['status'] == 'Preparing',
        )
        .toList();
    final acceptedOrders = allOrders
        .where((o) => o['status'] == 'Preparing')
        .toList();
    final rejectedOrders = allOrders
        .where((o) => o['status'] == 'Rejected')
        .toList();

    // 2. Calculamos las estadísticas dinámicas
    int totalProducts = allOrders.fold(
      0,
      (sum, o) => sum + (o['itemCount'] as int? ?? 0),
    );
    double totalAmount = allOrders.fold(
      0.0,
      (sum, o) => sum + (o['total'] as double? ?? 0.0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pedidos',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3D32),
            ),
          ),
          const Text(
            'Revisá los pedidos que llegaron. Elegí cuáles podés preparar.',
          ),
          const SizedBox(height: 24),

          // --- FILA DE ESTADÍSTICAS DINÁMICAS ---
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  pendingOrders.length.toString(),
                  'Por responder',
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  totalProducts.toString(),
                  'Productos solicitados',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '\$${totalAmount.toStringAsFixed(0)}',
                  'Total solicitado',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- TABS DE ESTADO (Visuales por ahora) ---
          Row(
            children: [
              _buildTab('Pendientes · ${pendingOrders.length}', true),
              const SizedBox(width: 8),
              _buildTab('Aceptados · ${acceptedOrders.length}', false),
              const SizedBox(width: 8),
              _buildTab('Rechazados · ${rejectedOrders.length}', false),
            ],
          ),
          const SizedBox(height: 24),

          // --- LISTA DE PEDIDOS ---
          if (pendingOrders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay pedidos pendientes por el momento.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: pendingOrders.map((order) {
                return _buildOrderCard(context, order);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF1E3D32) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: isPrimary ? Colors.white70 : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E3D32) : const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF1E3D32),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final isMercadoPago = order['paymentMethod'] == 'MercadoPago';
    final itemCount = order['itemCount'] ?? 0;

    return Container(
      width: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la tarjeta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PEDIDO #${order['ticketCode']}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMercadoPago
                      ? const Color(0xFFE0F2F1)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isMercadoPago ? 'Pagado' : 'Pendiente',
                  style: TextStyle(
                    color: isMercadoPago
                        ? const Color(0xFF1E3D32)
                        : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Datos del alumno
          Text(
            order['studentName'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            '${order['course']} · ${isMercadoPago ? 'Mercado Pago' : 'Efectivo'}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const Divider(height: 24),

          // Resumen de productos (Como no guardamos el detalle en el provider, mostramos la cantidad)
          Text(
            '$itemCount productos solicitados',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),

          const Divider(height: 24),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total · ARS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // CORRECCIÓN DEL ERROR DE SINTAXIS AQUÍ
              Text(
                '\$${(order['total'] as double).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botones funcionales
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Cambia el estado a Rechazado
                    context.read<OrderProvider>().updateOrderStatus(
                      order['id'],
                      'Rejected',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Rechazar pedido'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Cambia el estado a En Preparación
                    context.read<OrderProvider>().updateOrderStatus(
                      order['id'],
                      'Preparing',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3D32),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Aceptar pedido',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
