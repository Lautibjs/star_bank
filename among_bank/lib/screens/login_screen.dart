import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/app_state.dart';
import '../widgets/theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true, _loading = false, _blocked = false;
  int _fails = 0;
  Timer? _blockTimer;
  late AnimationController _anim;
  late Animation<double> _fade, _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade =
        CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _slide = Tween(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _blockTimer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_blocked) return;
    if (_userCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      showMsg(context, '❌ Completá todos los campos', isError: true);
      return;
    }
    setState(() => _loading = true);
    final error =
        await context.read<AppState>().login(_userCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (error == null) {
      _fails = 0;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      _fails++;
      if (_fails >= 3) {
        setState(() => _blocked = true);
        showMsg(context,
            '⛔ Bloqueado 30 segundos por múltiples intentos fallidos',
            isError: true);
        _blockTimer = Timer(const Duration(seconds: 30), () {
          if (mounted) setState(() { _blocked = false; _fails = 0; });
        });
      } else {
        showMsg(context, '❌ $error ($_fails/3 intentos)', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      // Sin color de fondo — la imagen lo llena todo
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── FONDO: imagen completa sin ningún overlay ────────
          Image.asset(
            'assets/images/splash_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),

          // ── GRADIENTE solo en la mitad inferior ─────────────
          // Para que los campos sean legibles sin tapar la imagen
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: h * 0.52,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xCC000000),
                    Color(0xF0050A12),
                  ],
                  stops: [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),

          // ── FORMULARIO ────────────────────────────────────────
          SafeArea(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, child) => Opacity(
                opacity: _fade.value,
                child: Transform.translate(
                    offset: Offset(0, _slide.value), child: child),
              ),
              child: Column(
                children: [
                  // Espacio superior — deja ver la imagen completa
                  const Spacer(flex: 3),

                  // ── CAMPOS DE LOGIN (abajo) ───────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        // Campo usuario
                        _glassField(
                          controller: _userCtrl,
                          hint: 'Usuario o email',
                          icon: Icons.person_outline,
                          enabled: !_blocked && !_loading,
                        ),
                        const SizedBox(height: 12),

                        // Campo contraseña
                        _glassField(
                          controller: _passCtrl,
                          hint: 'Contraseña',
                          icon: Icons.lock_outline,
                          obscure: _obscure,
                          enabled: !_blocked && !_loading,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white38,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          onSubmit: _login,
                        ),
                        const SizedBox(height: 20),

                        // Botón INICIAR SESIÓN
                        GestureDetector(
                          onTap: (_blocked || _loading) ? null : _login,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: _blocked
                                  ? const LinearGradient(
                                      colors: [Colors.grey, Colors.grey])
                                  : const LinearGradient(
                                      colors: [kGold, kGoldDark]),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: !_blocked
                                  ? [
                                      BoxShadow(
                                        color: kGold.withOpacity(0.35),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            child: _loading
                                ? const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.black, strokeWidth: 2),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _blocked
                                            ? '⛔ BLOQUEADO'
                                            : 'INICIAR SESIÓN',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      if (!_blocked) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.chevron_right,
                                            color: Colors.black, size: 20),
                                      ],
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (_blocked)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.red.withOpacity(0.4)),
                            ),
                            child: const Text(
                              '⛔ Cuenta bloqueada temporalmente (30 seg)',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          const Text(
                            '🔒 Solo los líderes pueden crear nuevas cuentas',
                            style:
                                TextStyle(color: Colors.white24, fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool enabled = true,
    Widget? suffix,
    VoidCallback? onSubmit,
  }) {
    return Container(
      decoration: BoxDecoration(
        // Fondo semi-transparente oscuro para legibilidad
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        onSubmitted: onSubmit != null ? (_) => onSubmit() : null,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
