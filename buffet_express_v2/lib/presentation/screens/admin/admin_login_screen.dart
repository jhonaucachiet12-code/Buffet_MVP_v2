import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _show2FA = false;
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _codeController = TextEditingController();

  void _login() {
    if (!_show2FA) {
      setState(() => _show2FA = true);
    } else {
      context.go('/admin/panel'); // Redirige al panel
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: isDesktop
                    ? IntrinsicHeight(
                        // Soluciona el problema de altura
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildLeftPanel(desktop: true),
                            ),
                            const SizedBox(width: 24),
                            Expanded(flex: 6, child: _buildLoginForm()),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          _buildLeftPanel(desktop: false),
                          const SizedBox(height: 24),
                          _buildLoginForm(),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel({required bool desktop}) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3D32),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _show2FA
                ? 'Un paso más.\nUn acceso\nmás seguro.'
                : 'Hola, Héctor.\nTu buffet,\nbajo control.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _show2FA
                ? 'Confirmá que sos vos para entrar al panel del buffet escolar.'
                : 'Ingresá a tu espacio de trabajo para gestionar productos, ventas y pedidos.',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 40),
          _buildStep(
            '01',
            'Identificá tu cuenta',
            'DNI y correo del vendedor registrado.',
          ),
          _buildStep(
            '02',
            'Protegé tu acceso',
            'Contraseña personal, nunca compartida.',
          ),
          _buildStep(
            '03',
            'Confirmá que sos vos',
            'Código de seguridad enviado a tu Gmail.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _show2FA ? 'PASO 2 DE 2 · SEGURIDAD' : 'ACCESO RESTRINGIDO',
              style: const TextStyle(
                color: Color(0xFF1E3D32),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _show2FA ? 'Verificá tu identidad' : 'Ingresá como vendedor',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          if (!_show2FA) ...[
            TextField(
              controller: _dniController,
              decoration: const InputDecoration(
                labelText: 'DNI del vendedor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico (Gmail)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                suffixIcon: Text('Mostrar'),
              ),
            ),
          ] else ...[
            const Text(
              'Enviamos un código de 6 dígitos a tu correo registrado.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 16),
              maxLength: 6,
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'El código vence en 05:00. No lo compartas con nadie.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3D32),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _show2FA
                    ? 'Verificar e ingresar al panel'
                    : 'Continuar con la verificación',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () =>
                  _show2FA ? setState(() => _show2FA = false) : context.go('/'),
              child: Text(
                _show2FA
                    ? 'Volver al inicio de sesión'
                    : '¿Sos estudiante? Volver al acceso de compradores',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
