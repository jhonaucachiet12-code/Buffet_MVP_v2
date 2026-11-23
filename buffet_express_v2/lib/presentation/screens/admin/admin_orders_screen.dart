import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final allOrders = orderProv.orders;

    final pendingOrders = allOrders
        .where((o) => o['status'] == 'Pending_Payment')
        .toList();
    final acceptedOrders = allOrders
        .where((o) => o['status'] == 'Preparing')
        .toList();
    final rejectedOrders = allOrders
        .where((o) => o['status'] == 'Rejected')
        .toList();

    List<Map<String, dynamic>> displayedOrders = [];
    if (_selectedTab == 0) displayedOrders = pendingOrders;
    if (_selectedTab == 1) displayedOrders = acceptedOrders;
    if (_selectedTab == 2) displayedOrders = rejectedOrders;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedidos',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3D32),
                    ),
                  ),
                  Text(
                    'Revisá los pedidos que llegaron. Elegí cuáles podés preparar.',
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<OrderProvider>().fetchOrders(),
                tooltip: 'Actualizar pedidos',
              ),
            ],
          ),
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

          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: _buildTab(
                  'Pendientes · ${pendingOrders.length}',
                  _selectedTab == 0,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: _buildTab(
                  'Aceptados · ${acceptedOrders.length}',
                  _selectedTab == 1,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _selectedTab = 2),
                child: _buildTab(
                  'Rechazados · ${rejectedOrders.length}',
                  _selectedTab == 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (displayedOrders.isEmpty)
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
                    'No hay pedidos en esta categoría.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: displayedOrders.map((order) {
                return _buildOrderCard(
                  context,
                  order,
                  isPending: _selectedTab == 0,
                );
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

  Widget _buildOrderCard(
    BuildContext context,
    Map<String, dynamic> order, {
    required bool isPending,
  }) {
    final isMercadoPago = order['paymentMethod'] == 'MercadoPago';
    final items = (order['items'] as List?) ?? [];

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

          if (items.isNotEmpty)
            ...items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item['quantity']} x ${item['name']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text('\$${item['price'].toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                )
                .toList()
          else
            const Text(
              'No hay detalles de productos',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
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

          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Llamamos a la función del provider
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
                      // Llamamos a la función del provider
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
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order['status'] == 'Preparing'
                    ? 'Pedido Aceptado / En preparación'
                    : 'Pedido Rechazado',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
