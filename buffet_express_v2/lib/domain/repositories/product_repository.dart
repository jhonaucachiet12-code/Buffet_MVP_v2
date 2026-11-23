import '../entities/product.dart';

abstract class ProductRepository {
  /// Obtiene la lista completa de productos del buffet.
  Future<List<Product>> getProducts();

  /// Cambia la disponibilidad de un producto (para el panel del vendedor).
  Future<void> toggleAvailability(int productId, bool isAvailable);
}
