import 'package:material_ui/material_ui.dart';

import 'dart:math';

class OrderProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  void createOrder(
    String studentName,
    String course,
    String paymentMethod,
    double total,
  ) {
    String code = 'TN12-${_genCode(4)}-${_genCode(4)}';
    String status = paymentMethod == 'MercadoPago'
        ? 'Preparing'
        : 'Pending_Payment';

    _orders.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'ticketCode': code,
      'studentName': studentName,
      'course': course,
      'paymentMethod': paymentMethod,
      'status': status,
      'total': total,
    });
    notifyListeners();
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((o) => o['id'] == orderId);
    if (index != -1) {
      _orders[index]['status'] = newStatus;
      notifyListeners();
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
