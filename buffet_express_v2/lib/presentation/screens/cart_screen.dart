import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Importante para la navegación

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'ticket_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Variable para guardar el método de pago elegido
  String _selectedPaymentMethod = 'MercadoPago';

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

                // --- SECCIÓN DE PAGO ---
                Material(
                  color: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.black26,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¿Cómo querés pagar?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Opción Efectivo
                        RadioListTile<String>(
                          title: const Text('Efectivo (en el buffet)'),
                          subtitle: const Text('Pendiente de cobro'),
                          value: 'Efectivo',
                          groupValue: _selectedPaymentMethod,
                          activeColor: const Color(0xFF1E3D32),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) =>
                              setState(() => _selectedPaymentMethod = value!),
                        ),

                        // Opción Mercado Pago
                        RadioListTile<String>(
                          title: const Text('Mercado Pago'),
                          subtitle: const Text(
                            'Pagás ahora y pasa a preparación',
                          ),
                          value: 'MercadoPago',
                          groupValue: _selectedPaymentMethod,
                          activeColor: const Color(0xFF1E3D32),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) =>
                              setState(() => _selectedPaymentMethod = value!),
                        ),

                        const SizedBox(height: 16),
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
                              // 1. Crear el pedido con el método seleccionado
                              int totalItems = cart.items.values.fold(
                                0,
                                (sum, item) => sum + item.quantity,
                              ); // Calcula cantidad

                              context.read<OrderProvider>().createOrder(
                                'Alex García',
                                '3° 1.ª',
                                _selectedPaymentMethod,
                                cart.total,
                                totalItems, // <-- Lo pasamos aquí
                              );

                              // 2. Preparar los datos para el ticket
                              final orderData = {
                                'studentName': 'Alex García',
                                'course': '3° 1.ª',
                                'paymentMethod': _selectedPaymentMethod,
                                'total': cart.total,
                                'ticketCode':
                                    'TN12-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              };

                              // 3. Vaciar el carrito
                              cart.clear();

                              // 4. Navegar al ticket usando GoRouter
                              context.pushReplacement(
                                '/tienda/ticket',
                                extra: orderData,
                              );
                            },
                            child: const Text('Confirmar Pedido'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
