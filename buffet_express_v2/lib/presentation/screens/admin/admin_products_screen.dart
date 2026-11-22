import 'package:material_ui/material_ui.dart';

// --- MODELO DE DATOS PARA LA VISTA ---
enum ProductStatus { inSale, unavailable, outOfSale }

class AdminProduct {
  String id;
  String name;
  String category;
  double price;
  ProductStatus status;
  String unavailableReason;

  AdminProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.status,
    this.unavailableReason = 'Sin stock',
  });
}

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  // Datos de prueba (luego los traes de la BD)
  final List<AdminProduct> _products = [
    AdminProduct(
      id: '1',
      name: 'Agua mineral',
      category: 'Bebidas · 500 ml',
      price: 1200,
      status: ProductStatus.inSale,
    ),
    AdminProduct(
      id: '2',
      name: 'Jugo de naranja',
      category: 'Bebidas · 200 ml',
      price: 1500,
      status: ProductStatus.inSale,
    ),
    AdminProduct(
      id: '3',
      name: 'Alfajor de chocolate',
      category: 'Snacks · 1 unidad',
      price: 1000,
      status: ProductStatus.inSale,
    ),
    AdminProduct(
      id: '4',
      name: 'Papas fritas',
      category: 'Snacks · Bolsa de 40 g',
      price: 1300,
      status: ProductStatus.unavailable,
      unavailableReason: 'Sin stock',
    ),
    AdminProduct(
      id: '5',
      name: 'Sándwich de milanesa',
      category: 'Menús · 1 unidad',
      price: 3500,
      status: ProductStatus.inSale,
    ),
    AdminProduct(
      id: '6',
      name: 'Tarta de verdura',
      category: 'Menús · 1 porción',
      price: 3200,
      status: ProductStatus.outOfSale,
    ),
  ];

  AdminProduct? _selectedProduct;
  bool _isEditing = false;

  // --- LÓGICA DE LA INTERFAZ ---
  void _openEditPanel(AdminProduct product) {
    setState(() {
      _selectedProduct = product;
      _isEditing = true;
    });

    // Si es móvil, mostramos el panel como un BottomSheet
    if (MediaQuery.of(context).size.width < 800) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildEditPanel(isBottomSheet: true),
      ).then((_) => setState(() => _isEditing = false));
    }
  }

  void _saveProduct(AdminProduct updatedProduct) {
    setState(() {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _isEditing = false;
      _selectedProduct = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto actualizado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Administrar productos',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3D32),
            ),
          ),
          const Text(
            'Cambiá precios y decidí qué pueden comprar tus clientes.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Fila de Estadísticas
          _buildStatsRow(),

          const SizedBox(height: 32),

          // Contenedor principal (Lista + Panel de Edición en PC)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna de la Lista
              Expanded(flex: 2, child: _buildProductList()),

              // Columna del Panel de Edición (Solo visible en PC)
              if (isDesktop && _isEditing)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: _buildEditPanel(isBottomSheet: false),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    int inSale = _products
        .where((p) => p.status == ProductStatus.inSale)
        .length;
    int unavailable = _products
        .where((p) => p.status == ProductStatus.unavailable)
        .length;
    int outOfSale = _products
        .where((p) => p.status == ProductStatus.outOfSale)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            inSale.toString(),
            'En venta',
            const Color(0xFFE0F2F1),
            const Color(0xFF1E3D32),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            unavailable.toString(),
            'No disponible',
            const Color(0xFFFFF3E0),
            Colors.orange.shade800,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            outOfSale.toString(),
            'Fuera de venta',
            const Color(0xFFF5F5F5),
            Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Encabezado de la tabla (solo PC)
          if (MediaQuery.of(context).size.width >= 800)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'PRODUCTO',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'PRECIO · ARS',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'ESTADO',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 80), // Espacio para el botón
                ],
              ),
            ),
          const Divider(height: 1),

          // Lista de Productos
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = _products[index];
              return _buildProductRow(product);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(AdminProduct product) {
    final isHighlighted = product.status == ProductStatus.unavailable;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: isHighlighted
          ? const Color(0xFFFFF9F5)
          : Colors.transparent, // Fondo suave si no está disponible
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildStatusBadge(product.status),
                  ],
                ),
                Text(
                  product.category,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => _openEditPanel(product),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3D32),
                        side: const BorderSide(color: Color(0xFF1E3D32)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Editar'),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        product.category,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildStatusBadge(product.status),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: OutlinedButton(
                    onPressed: () => _openEditPanel(product),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E3D32),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      backgroundColor: const Color(0xFFF5F5F5),
                    ),
                    child: const Text('Editar'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusBadge(ProductStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case ProductStatus.inSale:
        bg = const Color(0xFFE0F2F1);
        text = const Color(0xFF1E3D32);
        label = 'En venta';
        break;
      case ProductStatus.unavailable:
        bg = const Color(0xFFFFF3E0);
        text = Colors.orange.shade800;
        label = 'No disponible';
        break;
      case ProductStatus.outOfSale:
        bg = const Color(0xFFF5F5F5);
        text = Colors.grey.shade600;
        label = 'Fuera de venta';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- PANEL DE EDICIÓN (Se adapta a PC o Móvil) ---
  Widget _buildEditPanel({required bool isBottomSheet}) {
    if (_selectedProduct == null) return const SizedBox.shrink();

    // Variables locales para editar antes de guardar
    double tempPrice = _selectedProduct!.price;
    ProductStatus tempStatus = _selectedProduct!.status;
    String tempReason = _selectedProduct!.unavailableReason;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isBottomSheet
                ? const BorderRadius.vertical(top: Radius.circular(24))
                : BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Editar producto',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (isBottomSheet)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _selectedProduct!.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _selectedProduct!.category,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              const Text(
                'Precio de venta · ARS',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: tempPrice.toStringAsFixed(0),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (val) =>
                    tempPrice = double.tryParse(val) ?? tempPrice,
              ),
              const SizedBox(height: 24),

              const Text(
                'Disponibilidad para el comprador',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              const SizedBox(height: 8),

              // Radio Buttons de Estado
              _buildRadioOption(
                title: 'En venta',
                subtitle: 'Visible y se puede comprar',
                value: ProductStatus.inSale,
                groupValue: tempStatus,
                onChanged: (val) => setModalState(() => tempStatus = val!),
              ),
              _buildRadioOption(
                title: 'No disponible',
                subtitle: 'Visible, pero no se puede comprar',
                value: ProductStatus.unavailable,
                groupValue: tempStatus,
                onChanged: (val) => setModalState(() => tempStatus = val!),
                isHighlighted: true,
              ),
              _buildRadioOption(
                title: 'Fuera de venta',
                subtitle: 'No aparece en el catálogo',
                value: ProductStatus.outOfSale,
                groupValue: tempStatus,
                onChanged: (val) => setModalState(() => tempStatus = val!),
              ),

              // Campo extra si está "No disponible"
              if (tempStatus == ProductStatus.unavailable) ...[
                const SizedBox(height: 16),
                const Text(
                  'Motivo que verá el comprador',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: tempReason,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Sin stock',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (val) => tempReason = val,
                ),
              ],

              const SizedBox(height: 32),

              // Botones de Acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (isBottomSheet)
                          Navigator.pop(context);
                        else
                          setState(() => _isEditing = false);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.transparent),
                        backgroundColor: const Color(0xFFF5F5F5),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final updated = AdminProduct(
                          id: _selectedProduct!.id,
                          name: _selectedProduct!.name,
                          category: _selectedProduct!.category,
                          price: tempPrice,
                          status: tempStatus,
                          unavailableReason: tempReason,
                        );
                        if (isBottomSheet) Navigator.pop(context);
                        _saveProduct(updated);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3D32),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Guardar cambios',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required ProductStatus value,
    required ProductStatus groupValue,
    required ValueChanged<ProductStatus?> onChanged,
    bool isHighlighted = false,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected && isHighlighted
              ? const Color(0xFFFFF9F5)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? (isHighlighted
                      ? Colors.orange.shade300
                      : const Color(0xFF1E3D32))
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<ProductStatus>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: isHighlighted
                  ? Colors.orange.shade800
                  : const Color(0xFF1E3D32),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
