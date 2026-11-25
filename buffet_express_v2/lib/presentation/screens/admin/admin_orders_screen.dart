import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';

// Estados del pedido en la base de datos
const _statusPending = 'Pending_Payment'; // el vendedor todavía no respondió
const _statusAccepted = 'Preparing'; // aceptado
const _statusRejected = 'Rejected'; // rechazado
const _statusCancelled = 'Cancelled'; // cancelado

const _green = Color(0xFF1E3D32);

enum _OrderTab { pending, accepted, rejected }

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  _OrderTab _tab = _OrderTab.pending;

  // Pedidos que se están guardando en este momento (para no tocar dos veces)
  final Set<String> _busyIds = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Al entrar a la pantalla, pedimos los datos a la nube
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OrderProvider>().fetchOrders();
    });
    // Cada 15 segundos buscamos pedidos nuevos
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Datos
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> _ordersFor(
    List<Map<String, dynamic>> all,
    _OrderTab tab,
  ) {
    bool matches(String status) {
      switch (tab) {
        case _OrderTab.pending:
          return status == _statusPending;
        case _OrderTab.accepted:
          return status == _statusAccepted;
        case _OrderTab.rejected:
          return status == _statusRejected || status == _statusCancelled;
      }
    }

    int idOf(Map<String, dynamic> o) => int.tryParse(o['id'].toString()) ?? 0;

    final list = all.where((o) => matches(o['status'].toString())).toList();
    // Pendientes y aceptados: el más viejo primero (orden de llegada).
    // Rechazados: el más nuevo primero.
    list.sort(
      (a, b) => tab == _OrderTab.rejected
          ? idOf(b).compareTo(idOf(a))
          : idOf(a).compareTo(idOf(b)),
    );
    return list;
  }

  Future<void> _changeStatus(
    Map<String, dynamic> order,
    String newStatus,
  ) async {
    final id = order['id'].toString();
    if (_busyIds.contains(id)) return;

    setState(() => _busyIds.add(id));
    final ok = await context.read<OrderProvider>().updateOrderStatus(
      id,
      newStatus,
    );
    if (!mounted) return;
    setState(() => _busyIds.remove(id));

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo actualizar el pedido. Revisá la conexión y probá de nuevo.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmReject(Map<String, dynamic> order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rechazar pedido'),
        content: Text(
          '¿Querés rechazar el pedido de ${order['studentName']}? '
          'Desde esta pantalla no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _changeStatus(order, _statusRejected);
    }
  }

  // ---------------------------------------------------------------------------
  // Pantalla
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OrderProvider>();
    final pending = _ordersFor(prov.orders, _OrderTab.pending);
    final accepted = _ordersFor(prov.orders, _OrderTab.accepted);
    final rejected = _ordersFor(prov.orders, _OrderTab.rejected);

    // Los números de arriba cuentan solo lo que falta responder
    int totalProducts = 0;
    double totalAmount = 0;
    for (final o in pending) {
      totalProducts += int.tryParse(o['itemCount'].toString()) ?? 0;
      totalAmount += double.tryParse(o['total'].toString()) ?? 0.0;
    }

    final visible = _tab == _OrderTab.pending
        ? pending
        : _tab == _OrderTab.accepted
        ? accepted
        : rejected;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final pad = isNarrow ? 16.0 : 24.0;
        final contentWidth = constraints.maxWidth - pad * 2;

        return RefreshIndicator(
          onRefresh: () => context.read<OrderProvider>().fetchOrders(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isNarrow),
                SizedBox(height: isNarrow ? 16 : 24),
                _buildStats(
                  isNarrow,
                  pending.length,
                  totalProducts,
                  totalAmount,
                ),
                SizedBox(height: isNarrow ? 16 : 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTab('Pendientes', pending.length, _OrderTab.pending),
                    _buildTab('Aceptados', accepted.length, _OrderTab.accepted),
                    _buildTab(
                      'Rechazados',
                      rejected.length,
                      _OrderTab.rejected,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (prov.hasError) _buildErrorBanner(),
                _buildOrdersArea(prov, visible, contentWidth),
                if (_tab == _OrderTab.pending && visible.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Al aceptar pasa a Aceptados. Al rechazar pasa a Rechazados.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isNarrow) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedidos',
                style: TextStyle(
                  fontSize: isNarrow ? 28 : 32,
                  fontWeight: FontWeight.bold,
                  color: _green,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Revisá lo que pidieron y decidí si podés prepararlo.',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Actualizar',
          icon: const Icon(Icons.refresh, color: _green),
          onPressed: () => context.read<OrderProvider>().fetchOrders(),
        ),
      ],
    );
  }

  Widget _buildStats(
    bool isNarrow,
    int pendingCount,
    int products,
    double amount,
  ) {
    final cardPending = _buildStatCard(
      pendingCount.toString(),
      'Por responder',
      isPrimary: true,
    );
    final cardProducts = _buildStatCard(
      products.toString(),
      'Productos solicitados',
    );
    final cardAmount = _buildStatCard(_money(amount), 'Total solicitado · ARS');

    if (isNarrow) {
      // En celular: "Por responder" arriba y los otros dos lado a lado
      return Column(
        children: [
          SizedBox(width: double.infinity, child: cardPending),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cardProducts),
              const SizedBox(width: 12),
              Expanded(child: cardAmount),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: cardPending),
        const SizedBox(width: 16),
        Expanded(child: cardProducts),
        const SizedBox(width: 16),
        Expanded(child: cardAmount),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isPrimary ? _green : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isPrimary ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count, _OrderTab tab) {
    final selected = _tab == tab;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _tab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _green : const Color(0xFFE3EEE9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$label · $count',
          style: TextStyle(
            color: selected ? Colors.white : _green,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'No se pudieron actualizar los pedidos. Probá de nuevo en unos segundos.',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersArea(
    OrderProvider prov,
    List<Map<String, dynamic>> visible,
    double contentWidth,
  ) {
    // Primera carga todavía en curso
    if (!prov.loaded && !prov.hasError) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    // La primera carga falló: el aviso rojo de arriba ya lo explica
    if (!prov.loaded && prov.hasError) {
      return const SizedBox.shrink();
    }

    if (visible.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            _emptyMessage(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    // Cantidad de columnas según el ancho: 1 en celular, hasta 3 en PC
    const gap = 16.0;
    const minCardWidth = 360.0;
    var columns = ((contentWidth + gap) / (minCardWidth + gap)).floor();
    if (columns < 1) columns = 1;
    if (columns > 3) columns = 3;
    final cardWidth = (contentWidth - gap * (columns - 1)) / columns;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: visible.map((o) => _buildOrderCard(o, cardWidth)).toList(),
    );
  }

  String _emptyMessage() {
    switch (_tab) {
      case _OrderTab.pending:
        return 'No hay pedidos pendientes por el momento.';
      case _OrderTab.accepted:
        return 'Todavía no aceptaste ningún pedido.';
      case _OrderTab.rejected:
        return 'No hay pedidos rechazados.';
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order, double width) {
    final isMercadoPago = order['paymentMethod'] == 'MercadoPago';
    final status = order['status'].toString();
    final isPending = status == _statusPending;
    final busy = _busyIds.contains(order['id'].toString());
    final items = (order['items'] as List<dynamic>?) ?? <dynamic>[];

    final time = _timeLabel(order['createdAt']);
    final header = 'PEDIDO #${order['ticketCode']}';
    final headerText = time.isEmpty ? header : '$header · $time';

    final payment = isMercadoPago
        ? 'Mercado Pago · Pagado'
        : 'Efectivo · Pendiente de pago';

    // Etiqueta de estado
    String badgeLabel;
    Color badgeBg;
    Color badgeFg;
    if (status == _statusAccepted) {
      badgeLabel = 'Aceptado';
      badgeBg = const Color(0xFFE0F2F1);
      badgeFg = _green;
    } else if (status == _statusRejected) {
      badgeLabel = 'Rechazado';
      badgeBg = const Color(0xFFFFEBEE);
      badgeFg = const Color(0xFFC62828);
    } else if (status == _statusCancelled) {
      badgeLabel = 'Cancelado';
      badgeBg = const Color(0xFFEEEEEE);
      badgeFg = Colors.black54;
    } else {
      badgeLabel = 'Pendiente';
      badgeBg = const Color(0xFFFBE9DD);
      badgeFg = const Color(0xFFB45309);
    }

    final rejectButton = OutlinedButton(
      onPressed: busy ? null : () => _confirmReject(order),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      child: const Text('Rechazar pedido'),
    );
    final acceptButton = ElevatedButton(
      onPressed: busy ? null : () => _changeStatus(order, _statusAccepted),
      style: ElevatedButton.styleFrom(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      child: Text(busy ? 'Guardando...' : 'Aceptar pedido'),
    );

    // Si la tarjeta es muy angosta, los botones van uno debajo del otro
    final stackButtons = width < 340;

    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  headerText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: badgeFg,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order['studentName'].toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            'Curso ${order['course']} · $payment',
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const Divider(height: 28),
          if (items.isEmpty)
            Text(
              '${order['itemCount']} productos solicitados',
              style: const TextStyle(fontWeight: FontWeight.w500),
            )
          else ...[
            const Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text('CANT.', style: _tableHeaderStyle),
                ),
                Expanded(child: Text('PRODUCTO', style: _tableHeaderStyle)),
                Text('IMPORTE', style: _tableHeaderStyle),
              ],
            ),
            const SizedBox(height: 6),
            for (final item in items)
              _buildItemRow(item as Map<String, dynamic>),
          ],
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total · ARS',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                _money(order['total'] as double),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            if (stackButtons) ...[
              SizedBox(width: double.infinity, child: acceptButton),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: rejectButton),
            ] else
              Row(
                children: [
                  Expanded(child: rejectButton),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: acceptButton),
                ],
              ),
          ],
        ],
      ),
    );
  }

  static const TextStyle _tableHeaderStyle = TextStyle(
    color: Colors.black45,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  Widget _buildItemRow(Map<String, dynamic> item) {
    final quantity = (item['quantity'] as num).toInt();
    final price = (item['price'] as num).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              '$quantity',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(item['name'].toString())),
          const SizedBox(width: 8),
          Text(
            _money(price * quantity),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Formatos
  // ---------------------------------------------------------------------------

  // 11700 -> $11.700
  String _money(num value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return '\$$buffer';
  }

  // Hora del pedido en el horario del dispositivo: "10:12", o "24/11 10:12"
  // si no es de hoy. Si el pedido no trae fecha devuelve texto vacío.
  String _timeLabel(dynamic createdAt) {
    final seconds = int.tryParse(createdAt.toString());
    if (seconds == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    String two(int n) => n.toString().padLeft(2, '0');
    final time = '${two(date.hour)}:${two(date.minute)}';
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    return isToday ? time : '${two(date.day)}/${two(date.month)} $time';
  }
}
