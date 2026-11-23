import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart'; // <-- Importante
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
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // Pedimos los productos al backend al iniciar la pantalla
    final repo = context.read<ProductRepository>();
    _productsFuture = repo.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFFF9F6F0),
        elevation: 0,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          // Mientras carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si hay error (ej. backend apagado)
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al conectar con el servidor:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // Filtramos los productos por la categoría seleccionada
          final allProducts = snapshot.data ?? [];
          final catProducts = allProducts
              .where((p) => p.categoryId == widget.categoryId)
              .toList();

          if (catProducts.isEmpty) {
            return const Center(
              child: Text('No hay productos en esta categoría.'),
            );
          }

          return ListView.builder(
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
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                          ),
                          onPressed: () =>
                              context.read<CartProvider>().addProduct(p),
                        )
                      : const Text(
                          'Agotado',
                          style: TextStyle(color: Colors.red),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
