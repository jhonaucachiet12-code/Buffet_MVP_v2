import 'package:material_ui/material_ui.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: _buildStatCard('2', 'Por responder', isPrimary: true),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('6', 'Productos solicitados')),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('\$11.700', 'Total solicitado')),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              _buildTab('Pendientes · 2', true),
              const SizedBox(width: 8),
              _buildTab('Aceptados · 0', false),
              const SizedBox(width: 8),
              _buildTab('Rechazados · 0', false),
            ],
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildOrderCard(
                'PEDIDO #0124',
                '10:12',
                'Alex García',
                'Curso 3° 1.ª',
                'Efectivo · Pendiente de pago',
                [
                  ('Agua mineral', 1, 1200),
                  ('Alfajor de chocolate', 2, 2000),
                  ('Sándwich de milanesa', 1, 3500),
                ],
                6700,
              ),
              _buildOrderCard(
                'PEDIDO #0125',
                '10:15',
                'Camila López',
                'Curso 4° 2.ª',
                'Mercado Pago · Pagado',
                [
                  ('Jugo de naranja', 1, 1500),
                  ('Sándwich de milanesa', 1, 3500),
                ],
                5000,
              ),
            ],
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
    String id,
    String time,
    String name,
    String course,
    String payment,
    List<(String, int, double)> items,
    double total,
  ) {
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
                '$id · $time',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Pendiente',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            '$course · $payment',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const Divider(height: 24),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.$2} x ${item.$1}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('\$${item.$3.toStringAsFixed(0)}'),
                ],
              ),
            ),
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
                '\$$total.toStringAsFixed(0)',
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
                  onPressed: () {},
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
                  onPressed: () {},
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
