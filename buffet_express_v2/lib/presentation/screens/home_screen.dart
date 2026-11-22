import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'id': 1,
      'name': 'Bebidas',
      'desc': 'Aguas, jugos y gaseosas',
      'icon': Icons.local_drink,
      'color': Color(0xFFE0F2F1),
    },
    {
      'id': 2,
      'name': 'Snacks',
      'desc': 'Algo rico para tu recreo',
      'icon': Icons.cookie,
      'color': Color(0xFFFFF3E0),
    },
    {
      'id': 3,
      'name': 'Menús',
      'desc': 'Opciones para el almuerzo',
      'icon': Icons.restaurant,
      'color': Color(0xFFF3E5F5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buffet escolar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF9F6F0),
        elevation: 0,
        actions: [
          if (cart.itemCount > 0)
            IconButton(
              icon: Badge(
                label: Text('${cart.itemCount}'),
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () => context.push('/tienda/carrito'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3D32),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Qué pinta para el recreo?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Elegí algo rico y armá tu pedido.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¿Qué vas a pedir?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isDesktop
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 3,
                          ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) =>
                          _buildCategoryCard(context, categories[index]),
                    )
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCategoryCard(context, categories[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> cat) {
    return Card(
      color: cat['color'],
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(cat['icon'], color: const Color(0xFF1E3D32), size: 32),
        title: Text(
          cat['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(cat['desc']),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () =>
            context.push('/tienda/productos/${cat['id']}?title=${cat['name']}'),
      ),
    );
  }
}
