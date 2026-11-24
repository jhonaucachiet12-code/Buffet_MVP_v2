import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Al entrar a la pantalla, pedimos los datos a la nube
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final pendingOrders = orderProv.orders
        .where(
          (o) => o['status'] == 'Pending_Payment' || o['status'] == 'Preparing',
        )
        .toList();

    int totalProducts = orderProv.orders.fold(
      0,
      (sum, o) => sum + (int.tryParse(o['itemCount'].toString()) ?? 0),
    );
    double totalAmount = orderProv.orders.fold(
      0.0,
      (sum, o) => sum + (double.tryParse(o['total'].toString()) ?? 0.0),
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
          const Text('Revisá los pedidos que llegaron.'),
          const SizedBox(height: 24),

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

          if (pendingOrders.isEmpty)
            const Center(
              child: Text('No hay pedidos pendientes por el momento.'),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: pendingOrders
                  .map((order) => _buildOrderCard(order, context))
                  .toList(),
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

  Widget _buildOrderCard(Map<String, dynamic> order, BuildContext context) {
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

          Text(
            order['studentName'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            '${order['course']} · ${isMercadoPago ? 'Mercado Pago' : 'Efectivo'}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const Divider(height: 24),
          Text(
            '$itemCount productos solicitados',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total · ARS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<OrderProvider>().updateOrderStatus(
                      order['id'],
                      'Rejected',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Rechazar pedido'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<OrderProvider>().updateOrderStatus(
                      order['id'],
                      'Preparing',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3D32),
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
