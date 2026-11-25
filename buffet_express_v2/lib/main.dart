import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/api_product_repository.dart'; // <-- IMPORTANTE
import 'domain/repositories/product_repository.dart'; // <-- IMPORTANTE
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/order_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Aquí inyectamos el repositorio real conectado a Aiven
        Provider<ProductRepository>(create: (_) => ApiProductRepository()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp.router(
        // El título de la pestaña del navegador distingue al panel del vendedor
        title: kAppMode == 'admin'
            ? 'Buffet Express · Vendedor'
            : 'Buffet Express',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MaterialUiCompatibilityBridge(child: child!);
        },
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
        supportedLocales: const [
          Locale('es'), // Quitamos el 'AR'
          Locale('en'),
        ],
      ),
    );
  }
}
