import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../widgets/theme.dart';
import '../widgets/banner_header.dart';

// ══════════════════════════════════════════════════════
// BONUSES SCREEN
// ══════════════════════════════════════════════════════
class BonusesScreen extends StatefulWidget {
  const BonusesScreen({super.key});
  @override State<BonusesScreen> createState() => _BonusesScreenState();
}

class _BonusesScreenState extends State<BonusesScreen> {
  bool _loading = false;

  List<Map> get _bonuses => [
  {
    'key': 'bienvenida',
    'name': '🎉 Bono de Bienvenida',
    'amount': 500.0,
    'desc': 'Solo una vez al unirte',
    'color': Colors.purple,
  },
  {
    'key': 'daily',
    'name': '☀️ Bono Diario',
    'amount': 50.0,
    'desc': 'Una vez por día',
    'color': Colors.orange,
  },
  {
    'key': 'weekly',
    'name': '📅 Bono Semanal',
    'amount': 200.0,
    'desc': 'Una vez por semana',
    'color': Colors.blue,
  },
  {
    'key': 'monthly',
    'name': '🗓️ Bono Mensual',
    'amount': 800.0,
    'desc': 'Una vez por mes',
    'color': Colors.teal,
  },
];

  int _week(DateTime d) => ((d.difference(DateTime(d.year, 1, 1)).inDays) / 7).ceil();

  Future<void> _claim(Map bonus) async {
    setState(() => _loading = true);
    final r = await context.read<AppState>().claimBonus(bonus['key'] as String, bonus['amount'] as double);
    if (!mounted) return;
    setState(() => _loading = false);
    showMsg(context, r, isError: !r.startsWith('✅'));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser!;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('🎁 Bonos'), backgroundColor: kBg),
      body: ListView(
  padding: const EdgeInsets.all(16),
  children: [

    const BannerHeader(
      image: "assets/images/banners/bonos.jpeg",
    ),

    const SizedBox(height: 24),
          const SectionCard(child: Text(
            '🤖 Nova: "Reclamá tus bonos diarios y semanales para acumular más SC sin gastar nada. ¡Cada SC cuenta!"',
            style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 13, height: 1.5))),
          const SizedBox(height: 16),
          ..._bonuses.map((b) {
            final claimed = user.claimedBonuses.contains(b['key'] as String);
            final color = b['color'] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: claimed ? Colors.white10 : color.withOpacity(0.35)),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b['name'] as String, style: TextStyle(
                    color: claimed ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(b['desc'] as String, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                  const SizedBox(height: 6),
                  Text('+\$${(b['amount'] as double).toStringAsFixed(0)} SC',
                      style: TextStyle(color: claimed ? Colors.white24 : color, fontWeight: FontWeight.bold, fontSize: 20)),
                ])),
                const SizedBox(width: 12),
                claimed
                    ? Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                        child: const Text('Reclamado', style: TextStyle(color: Colors.white24, fontSize: 12)))
                    : GestureDetector(
                        onTap: _loading ? null : () => _claim(b),
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,4))],
                          ),
                          child: const Text('Reclamar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// NOTIFICATIONS SCREEN
// ══════════════════════════════════════════════════════
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final notifs = state.notifications;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('🔔 Notificaciones'), backgroundColor: kBg,
        actions: [
          TextButton(onPressed: () => state.markAllRead(),
              child: const Text('Leer todo', style: TextStyle(color: kGold, fontSize: 13))),
        ],
      ),
      body: notifs.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🔔', style: TextStyle(fontSize: 48)),
              SizedBox(height: 12),
              Text('Sin notificaciones', style: TextStyle(color: Colors.white38, fontSize: 16)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final n = notifs[i];
                final read = n['read'] == true;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: read ? kCard : kGold.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: read ? kBorder : kGold.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    Container(width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: read ? Colors.white10 : kGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(_icon(n['type'] ?? ''), style: const TextStyle(fontSize: 18)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(n['title'] ?? '', style: TextStyle(
                          color: read ? Colors.white54 : Colors.white,
                          fontWeight: read ? FontWeight.normal : FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(n['message'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      const SizedBox(height: 3),
                      Text(
                        n['timestamp'] != null
                            ? DateFormat('dd/MM HH:mm').format(DateTime.tryParse(n['timestamp']) ?? DateTime.now())
                            : '',
                        style: const TextStyle(color: Colors.white24, fontSize: 10)),
                    ])),
                    if (!read)
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle)),
                  ]),
                );
              },
            ),
    );
  }

  String _icon(String type) {
    switch (type) {
      case 'transfer_in': return '📥';
      case 'load_sc': return '💰';
      case 'card_upgrade': return '💳';
      case 'prize_request': return '👑';
      case 'purchase': return '📦';
      default: return '🔔';
    }
  }
}

// ══════════════════════════════════════════════════════
// NOVA SCREEN
// ══════════════════════════════════════════════════════
class NovaScreen extends StatefulWidget {
  const NovaScreen({super.key});
  @override State<NovaScreen> createState() => _NovaScreenState();
}

class _NovaScreenState extends State<NovaScreen> {
  final List<Map<String, String>> _msgs = [];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    final h = DateTime.now().hour;
    final g = h < 12 ? '¡Buenos días' : h < 18 ? '¡Buenas tardes' : '¡Buenas noches';
    final user = context.read<AppState>().currentUser;
    _msgs.add({'role': 'nova', 'text': '$g, ${user?.name ?? ''}! 🤖 Soy Nova, tu asistente bancario del clan. ¿En qué te ayudo hoy?\n\nPodés preguntarme sobre tu saldo, transferencias, préstamos, ahorros, tienda o logros.'});
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() { _msgs.add({'role': 'user', 'text': text}); _typing = true; });
    _ctrl.clear();
    _scrollDown();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() { _msgs.add({'role': 'nova', 'text': _respond(text.toLowerCase())}); _typing = false; });
      _scrollDown();
    });
  }

  void _scrollDown() => Future.delayed(const Duration(milliseconds: 100), () {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  });

  String _respond(String q) {
    final state = context.read<AppState>();
    final user = state.currentUser!;
    final fmt = NumberFormat('#,##0.00', 'es');
    if (q.contains('saldo') || q.contains('sc') || q.contains('dinero'))
      return '💰 Tu saldo es \$${fmt.format(user.balance)} SC. Tarjeta: ${user.cardType}.';
    if (q.contains('score') || q.contains('punto'))
      return '🏦 Tu rol determina el monto máximo de préstamo disponible.';    if (q.contains('tarjeta'))
      return '💳 Tarjeta ${user.cardType}. El nivel sube automáticamente con tu saldo:\n• Blue: \$1,000\n• Silver: \$5,000\n• Gold: \$50,000\n• Black: \$250,000\n• Diamond: \$500,000';
    if (q.contains('transferir') || q.contains('enviar'))
      return '💸 Tocá "Transferir" en el inicio, elegí el destinatario e ingresá el monto. Mínimo 1 SC.';
    if (q.contains('préstamo') || q.contains('prestamo'))
      return '🏦 En la sección "Préstamos" podés solicitar un préstamo según tu rol.';    if (q.contains('ahorro'))
      return '📈 En "Ahorros" depositás SC y generás 5% de interés mensual. Mínimo 100 SC.';
    if (q.contains('tienda') || q.contains('caja') || q.contains('premio'))
      return '🛒 En la Tienda:\n🪐 Caja Nebula: 500 SC\n🌌 Caja Galaxy: 1,000 SC\n🌠 Caja Supernova: 1,500 SC\n👑 Premio Supremo Leyenda: 8,000 SC\nY muchos premios pequeños desde 10 SC.';
    if (q.contains('bono'))
      return '🎁 Bonos disponibles:\n☀️ Diario: 50 SC\n📅 Semanal: 200 SC\n🗓️ Mensual: 800 SC\n🎉 Bienvenida: 500 SC (una sola vez)';
    if (q.contains('logro') || q.contains('achievement'))
      return '🏦 Among Bank ya no utiliza un sistema de logros. Tu progreso depende de tu saldo, tarjeta y rol.';
    if (q.contains('rol') || q.contains('rango'))
      return '👤 Tu rol es ${user.roleLabel}. Los roles son asignados por los líderes del clan.';
    if (q.contains('hola') || q.contains('buenas') || q.contains('hey') || q.contains('hi'))
      return '¡Hola, ${user.name}! 😊 ¿En qué te ayudo hoy?';
    if (q.contains('gracias'))
      return '¡De nada! 🤖 Siempre estoy aquí para ayudarte.';
    return '🤖 Entendido. Podés preguntarme sobre:\n• Saldo y tarjeta\n• Transferencias\n• Préstamos\n• Ahorros\n• Tienda y premios\n• Bonos\n• Tu rol';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        title: const Row(children: [
          CircleAvatar(radius: 16, backgroundColor: Color(0xFF06B6D4), child: Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Nova', style: TextStyle(color: Colors.cyan, fontSize: 15, fontWeight: FontWeight.bold)),
            Text('Asistente bancario IA', style: TextStyle(color: Colors.white24, fontSize: 10)),
          ]),
        ]),
      ),
      body: Stack(
  fit: StackFit.expand,
  children: [

    Image.asset(
      "assets/images/banners/nova.jpeg",
      fit: BoxFit.cover,
    ),

    Container(
      color: Colors.black.withOpacity(0.70),
    ),

    Column(
      children: [

        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _msgs.length + (_typing ? 1 : 0),
            itemBuilder: (_, i) {
              if (_typing && i == _msgs.length) {
                return _bubble(
                  {'role': 'nova', 'text': '...'},
                  typing: true,
                );
              }
              return _bubble(_msgs[i]);
            },
          ),
        ),
  
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          decoration: const BoxDecoration(
            color: kCard,
            border: Border(
              top: BorderSide(color: kBorder),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: kCard2,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: (_) => _send(),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Preguntale a Nova...',
                      hintStyle: TextStyle(color: Colors.white24),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
  
              const SizedBox(width: 8),

              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.cyan,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    ),

  ],
),
    );
  }


  Widget _bubble(Map<String, String> msg, {bool typing = false}) {
    final isNova = msg['role'] == 'nova';
    return Align(
      alignment: isNova ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isNova ? const Color(0xFF0E7490).withOpacity(0.2) : kGold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16).copyWith(
              bottomLeft: isNova ? Radius.zero : null, bottomRight: isNova ? null : Radius.zero),
          border: Border.all(color: isNova ? Colors.cyan.withOpacity(0.2) : kGold.withOpacity(0.2)),
        ),
        child: typing
            ? const Text('● ● ●', style: TextStyle(color: Colors.white38, letterSpacing: 4))
            : Text(msg['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
            ),
  );
  }
}