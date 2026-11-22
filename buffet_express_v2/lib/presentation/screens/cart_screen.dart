import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'ticket_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Carrito'),
        backgroundColor: const Color(0xFFF9F6F0),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text('Cantidad: ${item.quantity}'),
                        trailing: Text(
                          '\$${(item.product.price * item.quantity).toStringAsFixed(0)}',
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${cart.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3D32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<OrderProvider>().createOrder(
                              'Alex García',
                              '3° 1.ª',
                              'MercadoPago',
                              cart.total,
                            );
                            final orderData = {
                              'studentName': 'Alex García',
                              'course': '3° 1.ª',
                              'paymentMethod': 'MercadoPago',
                              'total': cart.total,
                              'ticketCode': 'TN12-A7K9-X2M4',
                            };
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TicketScreen(order: orderData),
                              ),
                            );
                          },
                          child: const Text('Confirmar Pedido'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
