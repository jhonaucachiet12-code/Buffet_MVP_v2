import 'package:material_ui/material_ui.dart';

import '../../domain/entities/product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};
  Map<int, CartItem> get items => _items;
  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get total => _items.values.fold(
    0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  void addProduct(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id!] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeProduct(int productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity--;
      if (_items[productId]!.quantity == 0) _items.remove(productId);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
