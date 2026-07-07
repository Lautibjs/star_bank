import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../widgets/theme.dart';
import '../widgets/banner_header.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _loading = false;

  final _boxes = [
    {
      'name': 'Caja NEBULA',
      'emoji': '🪐',
      'color': Colors.green,
      'cost': 500.0,
      'desc': 'Caja básica',
      'rewards': ['💰 100 SC', '🏅 Reconocimiento en el clan', '📣 Mención en el grupo',
        '🎮 Entrada a dinámica', '🛡️ Protección de asistencia (1 uso)',
        '🎲 Bonus +10 a +50 SC', '🎁 Mini regalo del líder'],
    },
    {
      'name': 'Caja GALAXY',
      'emoji': '🌌',
      'color': Colors.blue,
      'cost': 1000.0,
      'desc': 'Caja media',
      'rewards': ['💰 200 SC', '🏛️ Salón de la Fama', '🏆 Miembro más activo',
        '🎮 Evento VIP', '⚡ Doble recompensa en una actividad',
        '👑 Título temporal', '📣 Mención destacada', '🎲 Premio sorpresa'],
    },
    {
      'name': 'Caja SUPERNOVA',
      'emoji': '🌠',
      'color': Colors.red,
      'cost': 1500.0,
      'desc': 'Caja legendaria',
      'rewards': ['🏛️ Museo del Clan', '💰 300 SC', '👑 Reconocimiento único',
        '🌟 Rango VIP Supremo', '🎮 Control de sala', '🎯 Elegir evento',
        '🛡️ Inmunidad asistencia', '⚡ Poder especial', '🎲 Premio secreto'],
    },
  ];

  final _smallPrizes = [
    {'name': 'Mención en el grupo', 'emoji': '📣', 'cost': 10.0},
    {'name': 'Entrada a dinámica extra', 'emoji': '🎮', 'cost': 10.0},
    {'name': 'Protección de asistencia (1 día)', 'emoji': '🛡️', 'cost': 20.0},
    {'name': 'Mini caja sorpresa', 'emoji': '🎲', 'cost': 25.0},
    {'name': 'Entrada VIP a sala', 'emoji': '🎮', 'cost': 35.0},
    {'name': 'Doble recompensa', 'emoji': '⚡', 'cost': 50.0},
    {'name': 'Reconocimiento del día', 'emoji': '🏅', 'cost': 60.0},
    {'name': 'Beneficio sorpresa rápido', 'emoji': '🎉', 'cost': 70.0},
  ];

  final _premiumPrize = {
    'name': 'Leyenda Eterna del Clan',
    'emoji': '👑',
    'cost': 8000.0,
    'games': ['🔫 Free Fire', '🐧 Stumble Guys', '♟️ Clash Royale', '💬 Plato', '⛏️ Minecraft'],
    'rewards': ['✨ Skins legendarias', '💎 Diamantes / gemas', '🎟️ Pases premium',
      '🎭 Emotes exclusivos', '🎁 Cofres raros', '🪙 Monedas del juego'],
    'bonus': ['👑 Título eterno: "Leyenda de la Líder"', '🏛️ Salón de la Fama Supremo permanente',
      '📣 Reconocimiento histórico', '🎮 Acceso VIP permanente a eventos', '⚡ 1 beneficio futuro',
      '🎯 Derecho a elegir 1 evento del clan', '💬 Mensaje personalizado de la líder',
      '🎁 Sorpresa secreta exclusiva'],
  };

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _buyBox(Map box) async {
    final cost = box['cost'] as double;
    final confirmed = await _confirm(context,
        '¿Comprar ${box['name']}?',
        'Costo: \$${cost.toStringAsFixed(0)} SC\n\nTu líder te entregará el premio.');
    if (!confirmed) return;

    setState(() => _loading = true);
    final result = await context.read<AppState>().purchaseBox(box['name'] as String, cost);
    if (!mounted) return;
    setState(() => _loading = false);
    showMsg(context, result, isError: !result.startsWith('✅'));
  }

  Future<void> _buyPrize(Map prize) async {
    final cost = prize['cost'] as double;
    final confirmed = await _confirm(context,
        '¿Canjear ${prize['name']}?',
        'Costo: \$${cost.toStringAsFixed(0)} SC');
    if (!confirmed) return;

    setState(() => _loading = true);
    final result = await context.read<AppState>().purchasePrize(prize['name'] as String, cost);
    if (!mounted) return;
    setState(() => _loading = false);
    showMsg(context, result, isError: !result.startsWith('✅'));
  }

  Future<bool> _confirm(BuildContext ctx, String title, String msg) async {
    return await showDialog<bool>(
          context: ctx,
          builder: (_) => AlertDialog(
            backgroundColor: kCard,
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: Text(msg, style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kGold),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirmar', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser!;
    final fmt = NumberFormat('#,##0', 'es');

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('🛒 Tienda'),
        backgroundColor: kBg,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: kGold,
          labelColor: kGold,
          unselectedLabelColor: Colors.white38,
          tabs: const [Tab(text: '📦 Cajas'), Tab(text: '🎁 Premios'), Tab(text: '👑 Supremo')],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: kCard,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tu saldo:', style: TextStyle(color: Colors.white54, fontSize: 13)),
                Text('\$${fmt.format(user.balance)} SC',
                    style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),

          const Padding(
  padding: EdgeInsets.all(16),
  child: BannerHeader(
    image: "assets/images/banners/tienda.jpeg",
  ),
),

          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                // ── CAJAS ──────────────────────────────────────
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                  ..._boxes.map((box) {
                    final cost = box['cost'] as double;
                    final canBuy = user.balance >= cost;
                    final color = box['color'] as Color;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(
                              children: [
                                Text(box['emoji'] as String, style: const TextStyle(fontSize: 32)),
                                const SizedBox(width: 12),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(box['name'] as String,
                                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(box['desc'] as String,
                                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                )),
                                Text('\$${fmt.format(cost)} SC',
                                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Posibles premios:',
                                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                                const SizedBox(height: 8),
                                ...(box['rewards'] as List).map((r) =>
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Text('  $r', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GoldButton(
                                  label: canBuy ? 'Comprar Caja' : 'SC insuficientes',
                                  loading: _loading,
                                  onTap: canBuy ? () => _buyBox(box) : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  ],
                ),

                // ── PREMIOS PEQUEÑOS ───────────────────────────
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                  ..._smallPrizes.map((p) {
                    final cost = p['cost'] as double;
                    final canBuy = user.balance >= cost;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        leading: Text(p['emoji'] as String, style: const TextStyle(fontSize: 24)),
                        title: Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${fmt.format(cost)}',
                                style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canBuy ? kGold : Colors.grey,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: canBuy ? () => _buyPrize(p) : null,
                              child: Text(canBuy ? 'Canjear' : 'Sin SC',
                                  style: TextStyle(color: canBuy ? Colors.black : Colors.white54, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  ],
                ),

                // ── PREMIO SUPREMO ─────────────────────────────
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [kGold.withOpacity(0.15), Colors.purple.withOpacity(0.15)]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kGold.withOpacity(0.5), width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const Text('👑💎', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 8),
                                const Text('PREMIO SUPREMO DE LA LÍDER',
                                    style: TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 18),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 4),
                                const Text('🔥 LEYENDA ETERNA DEL CLAN 🔥',
                                    style: TextStyle(color: Colors.orange, fontSize: 14),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [kGold, kGoldDark]),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('8,000 SC',
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('🎮 Juegos disponibles:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          ...(_premiumPrize['games'] as List).map((g) =>
                            Text('  $g', style: const TextStyle(color: Colors.white54, fontSize: 13))),
                          const SizedBox(height: 16),
                          const Text('💎 Qué recibís:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          ...(_premiumPrize['rewards'] as List).map((r) =>
                            Text('  $r', style: const TextStyle(color: Colors.white54, fontSize: 13))),
                          const SizedBox(height: 16),
                          const Text('🌟 Bonus exclusivos:', style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          ...(_premiumPrize['bonus'] as List).map((b) =>
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Text('  $b', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            )),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: const Text(
                              '⚠️ Solo con 8000 SC • Aprobación de la líder obligatoria • Premio único e irrepetible',
                              style: TextStyle(color: Colors.orange, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GoldButton(
                            label: user.balance >= 8000 ? '👑 Canjear Premio Supremo' : 'Necesitás 8,000 SC',
                            onTap: user.balance >= 8000 ? () => _buyPrize(_premiumPrize) : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
