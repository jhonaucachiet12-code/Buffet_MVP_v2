// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  // 1. GET: Traer los pedidos de la nube
  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://buffetbackend-production.up.railway.app/orders',
        ), // <-- Faltaba /orders
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
            'total': double.parse(order['total'].toString()),
            'itemCount': order['itemCount'] ?? 0,
          });
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error al obtener pedidos: $e');
    }
  }

  // 2. PATCH: Actualizar estado (Aceptar/Rechazar)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse(
          'https://buffetbackend-production.up.railway.app/orders',
        ), // <-- Faltaba /orders
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': int.parse(orderId), 'status': newStatus}),
      );

      if (response.statusCode == 200) {
        await fetchOrders(); // Recargamos la lista desde la nube
      } else {
        print(
          'Error del backend al actualizar: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error de conexión al actualizar estado: $e');
    }
  }

  // 3. POST: Crear un pedido nuevo.
  // Devuelve el código del ticket si salió bien, o null si falló.
  Future<String?> createOrder(
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
        Uri.parse(
          'https://buffetbackend-production.up.railway.app/orders',
        ), // <-- Faltaba /orders
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        // El ticket ya lo conocemos: no hace falta recargar la lista acá.
        return ticketCode;
      }
      print(
        'Error del backend al crear pedido: ${response.statusCode} - ${response.body}',
      );
      return null;
    } catch (e) {
      print('Error de conexión al crear pedido: $e');
      return null;
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
