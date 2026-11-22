import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AdminLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: isDesktop
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              title: Row(
                children: [
                  const Icon(Icons.school, color: Color(0xFF1E3D32)),
                  const SizedBox(width: 10),
                  const Text(
                    'Buffet escolar',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _buildDesktopNavItem(context, 'Administrar', '/admin/panel'),
                  _buildDesktopNavItem(context, 'Usuario', '/admin/usuario'),
                  _buildDesktopNavItem(context, 'Pedidos', '/admin/pedidos'),
                  const Spacer(),
                  const Chip(
                    label: Text('VENDEDOR'),
                    backgroundColor: Color(0xFFE0F2F1),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Héctor',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            )
          : null,
      body: child,
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              selectedItemColor: const Color(0xFF1E3D32),
              unselectedItemColor: Colors.grey,
              currentIndex: _getCurrentIndex(),
              onTap: (index) {
                if (index == 0) context.go('/admin/panel');
                if (index == 1) context.go('/admin/usuario');
                if (index == 2) context.go('/admin/pedidos');
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Administrar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Usuario',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Pedidos',
                ),
              ],
            )
          : null,
    );
  }

  int _getCurrentIndex() {
    if (currentRoute.contains('usuario')) return 1;
    if (currentRoute.contains('pedidos')) return 2;
    return 0;
  }

  Widget _buildDesktopNavItem(
    BuildContext context,
    String title,
    String route,
  ) {
    final isActive = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextButton(
        onPressed: () => context.go(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? const Color(0xFF1E3D32) : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isActive)
              Container(
                height: 2,
                width: 30,
                color: const Color(0xFFE07A5F),
                margin: const EdgeInsets.only(top: 4),
              ),
          ],
        ),
      ),
    );
  }
}
