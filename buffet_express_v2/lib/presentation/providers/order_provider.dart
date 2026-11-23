import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:convert'; // <-- Nuevo

import 'package:http/http.dart' as http; // <-- Nuevo

import 'cart_provider.dart'; // <-- Para usar los CartItem

class OrderProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  // Ahora es una función asíncrona (Future) porque espera la respuesta del servidor
  Future<bool> createOrder(
    String studentName,
    String course,
    String paymentMethod,
    double total,
    List<CartItem> cartItems, // <-- Ahora recibe los productos
  ) async {
    String ticketCode = 'TN12-${_genCode(4)}-${_genCode(4)}';
    String status = paymentMethod == 'MercadoPago'
        ? 'Preparing'
        : 'Pending_Payment';

    try {
      // 1. Hacemos la petición POST al backend
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

      // 2. Si el backend responde con éxito
      if (response.statusCode == 200) {
        // Lo guardamos en la lista local para que aparezca en el panel del vendedor
        _orders.add({
          'id': DateTime.now().millisecondsSinceEpoch
              .toString(), // ID temporal local
          'ticketCode': ticketCode,
          'studentName': studentName,
          'course': course,
          'paymentMethod': paymentMethod,
          'status': status,
          'total': total,
          'itemCount': cartItems.fold(0, (sum, item) => sum + item.quantity),
        });
        notifyListeners();
        return true; // Éxito
      } else {
        print('Error del servidor: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // 1. Enviamos la orden de cambio al backend
      final response = await http.patch(
        Uri.parse('http://localhost:8080/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': int.parse(orderId), 'status': newStatus}),
      );

      // 2. SOLO cuando el backend confirma el cambio, actualizamos la lista
      if (response.statusCode == 200) {
        await fetchOrders();
      }
    } catch (e) {
      print('Error al actualizar el estado: $e');
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
            'items': order['items'], // <-- Guardamos los productos
          });
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error al obtener pedidos: $e');
    }
  }
}
