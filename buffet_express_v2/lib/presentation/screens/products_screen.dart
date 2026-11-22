import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product.dart';
import '../providers/cart_provider.dart';

class ProductsScreen extends StatefulWidget {
  final int categoryId;
  final String title;
  const ProductsScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final List<Product> _products = [
    Product(
      id: 1,
      categoryId: 1,
      name: 'Agua mineral',
      description: '500 ml',
      price: 1200,
      isAvailable: true,
    ),
    Product(
      id: 2,
      categoryId: 1,
      name: 'Jugo de naranja',
      description: '200 ml',
      price: 1500,
      isAvailable: true,
    ),
    Product(
      id: 3,
      categoryId: 2,
      name: 'Alfajor de chocolate',
      description: '1 unidad',
      price: 1000,
      isAvailable: true,
    ),
    Product(
      id: 4,
      categoryId: 2,
      name: 'Papas fritas',
      description: 'Bolsa de 40 g',
      price: 1300,
      isAvailable: false,
    ),
    Product(
      id: 5,
      categoryId: 3,
      name: 'Sándwich de milanesa',
      description: '1 unidad',
      price: 3500,
      isAvailable: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final catProducts = _products
        .where((p) => p.categoryId == widget.categoryId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFFF9F6F0),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: catProducts.length,
        itemBuilder: (context, index) {
          final p = catProducts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                p.name,
                style: TextStyle(
                  color: p.isAvailable ? Colors.black : Colors.grey,
                ),
              ),
              subtitle: Text('${p.description} • \$${p.price}'),
              trailing: p.isAvailable
                  ? IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () =>
                          context.read<CartProvider>().addProduct(p),
                    )
                  : const Text('Agotado', style: TextStyle(color: Colors.red)),
            ),
          );
        },
      ),
    );
  }
}
