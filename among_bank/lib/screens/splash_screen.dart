import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logo, _bar;
  late Animation<double> _logoFade, _logoScale, _progress;
  String _status = 'Iniciando...';

  @override
  void initState() {
    super.initState();
    _logo = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _bar  = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    _logoFade  = CurvedAnimation(parent: _logo, curve: Curves.easeIn);
    _logoScale = Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _logo, curve: Curves.elasticOut));
    _progress  = CurvedAnimation(parent: _bar, curve: Curves.easeInOut);
    _logo.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _bar.forward());
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _status = 'Conectando a Firebase...');
    final state = context.read<AppState>();
    await state.initialize();
    if (!mounted) return;
    if (mounted) setState(() => _status = 'Cargando datos...');
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => state.isLoggedIn ? const HomeScreen() : const LoginScreen(),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 600),
    ));
  }

  @override
  void dispose() { _logo.dispose(); _bar.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash_bg.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.55)),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Column(children: [
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [kGold, kGoldDark]),
                          boxShadow: [BoxShadow(color: kGold.withOpacity(0.5), blurRadius: 40, spreadRadius: 5)],
                        ),
                        child: const Icon(Icons.account_balance, size: 46, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      const Text('AMONG', style: TextStyle(color: kGold, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8, height: 1)),
                      const Text('BANK', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300, letterSpacing: 12)),
                      const SizedBox(height: 8),
                      const Text('— TU MUNDO, TU BANCO. —', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 4)),
                    ]),
                  ),
                ),
                const Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(children: [
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(kGold),
                          minHeight: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_status, style: const TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1)),
                  ]),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
