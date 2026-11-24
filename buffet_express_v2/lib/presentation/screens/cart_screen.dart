import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _selectedPaymentMethod = 'MercadoPago';
  bool _isLoading = false; // <-- Para mostrar la ruedita de carga

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

                Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
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

                        RadioListTile<String>(
                          title: const Text('Efectivo (en el buffet)'),
                          subtitle: const Text('Pendiente de cobro'),
                          value: 'Cash',
                          groupValue: _selectedPaymentMethod,
                          activeColor: const Color(0xFF1E3D32),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) =>
                              setState(() => _selectedPaymentMethod = value!),
                        ),

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
                          height: 50,
                          child: ElevatedButton(
                            // Si está cargando, deshabilitamos el botón
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);

                                    // 1. Enviamos el pedido real al backend
                                    final String? ticketCode = await context
                                        .read<OrderProvider>()
                                        .createOrder(
                                          'Alex García',
                                          '3° 1.ª',
                                          _selectedPaymentMethod,
                                          cart.total,
                                          cart.items.values.toList(), // <-- Le pasamos los productos reales
                                        );

                                    if (ticketCode != null) {
                                      // 2. Preparamos datos para el ticket
                                      final orderData = {
                                        'studentName': 'Alex García',
                                        'course': '3° 1.ª',
                                        'paymentMethod': _selectedPaymentMethod,
                                        'total': cart.total,
                                        // Código real del pedido que acabamos de crear
                                        'ticketCode': ticketCode,
                                      };

                                      // 3. Vaciamos el carrito
                                      cart.clear();

                                      // 4. Navegamos al ticket
                                      if (mounted) {
                                        context.pushReplacement(
                                          '/tienda/ticket',
                                          extra: orderData,
                                        );
                                      }
                                    } else {
                                      // Si falló, mostramos un mensaje de error
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Error al conectar con el servidor. Revisá que el backend esté encendido.',
                                                ),
                                              ),
                                            );
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Confirmar Pedido'),
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
