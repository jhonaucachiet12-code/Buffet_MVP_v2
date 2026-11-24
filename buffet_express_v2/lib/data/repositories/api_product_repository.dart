import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ApiProductRepository implements ProductRepository {
  final String baseUrl;
  ApiProductRepository({
    this.baseUrl = 'https://buffetbackend-production.up.railway.app',
  }); // Localhost para PC

  @override
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map(
            (json) => Product(
              id: json['id'],
              categoryId: json['categoryId'] ?? 1,
              name: json['name'],
              description: json['description'] ?? '',
              price: json['price'].toDouble(),
              isAvailable: json['status'] == 'inSale',
            ),
          )
          .toList();
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode}');
    }
  }

  @override
  Future<void> toggleAvailability(int productId, bool isAvailable) async {
    // Lo dejamos preparado para el panel del vendedor
  }
}
