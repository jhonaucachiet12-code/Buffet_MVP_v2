class Product {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final bool isAvailable;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.isAvailable,
  });
}
