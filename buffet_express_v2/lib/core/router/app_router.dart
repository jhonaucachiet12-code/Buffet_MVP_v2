import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/products_screen.dart';
import '../../presentation/screens/cart_screen.dart';
import '../../presentation/screens/admin/admin_login_screen.dart';
import '../../presentation/screens/admin/admin_layout.dart';
import '../../presentation/screens/admin/admin_orders_screen.dart';
import '../../presentation/screens/admin/admin_products_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/tienda', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/tienda/productos/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final title = state.uri.queryParameters['title'] ?? 'Productos';
          return ProductsScreen(categoryId: id, title: title);
        },
      ),
      GoRoute(
        path: '/tienda/carrito',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AdminLayout(child: child, currentRoute: state.uri.toString());
        },
        routes: [
          GoRoute(
            path: '/admin/panel',
            builder: (context, state) => const AdminOrdersScreen(),
          ),
          GoRoute(
            path: '/admin/productos',
            builder: (context, state) => const AdminProductsScreen(),
          ),
        ],
      ),
    ],
  );
}
