// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  // Para que la pantalla del vendedor sepa si ya cargó o si falló la carga
  bool _loaded = false;
  bool _hasError = false;
  bool get loaded => _loaded;
  bool get hasError => _hasError;

  // 1. GET: Traer los pedidos de la nube
  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('https://buffetbackend-production.up.railway.app/orders'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _orders.clear();
        for (var order in data) {
          final rawItems = (order['items'] as List<dynamic>?) ?? <dynamic>[];
          _orders.add({
            'id': order['id'].toString(),
            'ticketCode': order['ticketCode'],
            'studentName': order['studentName'],
            'course': order['course'],
            'paymentMethod': order['paymentMethod'],
            'status': order['status'],
            'total': double.parse(order['total'].toString()),
            'itemCount': order['itemCount'] ?? 0,
            // Fecha de creación en segundos desde 1970 (puede ser null)
            'createdAt': order['createdAt'],
            // Productos del pedido: nombre, cantidad y precio unitario
            'items': rawItems
                .map(
                  (i) => <String, dynamic>{
                    'name': i['name']?.toString() ?? 'Producto',
                    'quantity': int.tryParse(i['quantity'].toString()) ?? 0,
                    'price': double.tryParse(i['price'].toString()) ?? 0.0,
                  },
                )
                .toList(),
          });
        }
        _loaded = true;
        _hasError = false;
      } else {
        print(
          'Error del backend al obtener pedidos: ${response.statusCode} - ${response.body}',
        );
        _hasError = true;
      }
    } catch (e) {
      print('Error al obtener pedidos: $e');
      _hasError = true;
    }
    notifyListeners();
  }

  // 2. PATCH: Actualizar estado (Aceptar/Rechazar).
  // Estados: Pending_Payment (pendiente), Preparing (aceptado),
  // Rejected (rechazado), Cancelled (cancelado).
  // Devuelve true si se guardó en la base de datos.
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('https://buffetbackend-production.up.railway.app/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': int.parse(orderId), 'status': newStatus}),
      );

      if (response.statusCode == 200) {
        await fetchOrders(); // Recargamos la lista desde la nube
        return true;
      }
      print(
        'Error del backend al actualizar: ${response.statusCode} - ${response.body}',
      );
      return false;
    } catch (e) {
      print('Error de conexión al actualizar estado: $e');
      return false;
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
    // Todo pedido nuevo queda pendiente hasta que el vendedor lo acepte o
    // lo rechace (el backend también lo fuerza).
    const String status = 'Pending_Payment';

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
