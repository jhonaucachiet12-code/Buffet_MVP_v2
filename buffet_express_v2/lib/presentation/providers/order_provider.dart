import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/orders'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _orders.clear();
        for (var order in data) {
          _orders.add({
            'id': order['id'].toString(),
            'ticketCode': order['ticketCode'],
            'studentName': order['studentName'],
            'course': order['course'],
            'paymentMethod': order['paymentMethod'],
            'status': order['status'],
            'total': order['total'],
            'itemCount': order['itemCount'],
            'items': order['items'],
          });
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error al obtener pedidos: $e');
    }
  }

  // ESTA ES LA FUNCIÓN QUE DEBEMOS REVISAR
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      print(
        'Enviando PATCH para ID: $orderId, Nuevo Estado: $newStatus',
      ); // <-- Para depurar

      final response = await http.patch(
        Uri.parse('http://localhost:8080/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': int.parse(orderId), 'status': newStatus}),
      );

      if (response.statusCode == 200) {
        print('Backend confirmó el cambio. Recargando lista...');
        await fetchOrders();
      } else {
        print(
          'Error del backend al actualizar: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error de conexión al actualizar estado: $e');
    }
  }

  Future<bool> createOrder(
    String studentName,
    String course,
    String paymentMethod,
    double total,
    List<CartItem> cartItems,
  ) async {
    String ticketCode = 'TN12-${_genCode(4)}-${_genCode(4)}';
    String status = paymentMethod == 'MercadoPago'
        ? 'Preparing'
        : 'Pending_Payment';

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'studentName': studentName,
          'course': course,
          'ticketCode': ticketCode,
          'status': status,
          'paymentMethod': paymentMethod,
          'total': total,
          'items': cartItems
              .map(
                (item) => {
                  'productId': item.product.id,
                  'quantity': item.quantity,
                  'price': item.product.price,
                },
              )
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        await fetchOrders();
        return true;
      }
      return false;
    } catch (e) {
      print('Error de conexión al crear pedido: $e');
      return false;
    }
  }

  String _genCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }
}
