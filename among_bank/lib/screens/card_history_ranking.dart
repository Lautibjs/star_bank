import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../models/transaction_model.dart';
import '../widgets/theme.dart';
import '../widgets/bank_card.dart';
import '../widgets/banner_header.dart';

// ══════════════════════════════════════════════════════
// CARD SCREEN
// ══════════════════════════════════════════════════════
class CardScreen extends StatefulWidget {
  const CardScreen({super.key});
  @override State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _anim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser!;
    final fmt = NumberFormat('#,##0.00', 'es');

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('💳 Mi Tarjeta'), backgroundColor: kBg),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: Image.asset('assets/images/card_bg.png', fit: BoxFit.cover),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 12),
              GestureDetector(
  onTap: () {
    if (_flipped) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
    setState(() => _flipped = !_flipped);
  },
  child: AnimatedBuilder(
    animation: _anim,
    builder: (_, __) {
      final front = _anim.value < 0.5;
      final angle = _anim.value * 3.14159;

      return Center(
  child: Transform(
    alignment: Alignment.center,
    transform: Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(angle),
    child: front
        ? _cardFront(user, fmt)
        : Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(3.14159),
            child: _cardBack(user),
          ),
  ),
);
    },
  ),
),

const SizedBox(height: 10),
           
              const Text('Toca la tarjeta para girarla', style: TextStyle(color: Colors.white24, fontSize: 11)),
              const SizedBox(height: 28),
              SectionCard(child: Column(children: [
                StatRow(label: 'Nombre', value: user.name),
                StatRow(label: 'Tarjeta', value: '${user.cardType} Card'),
                StatRow(label: 'Rol', value: user.roleLabel),
                StatRow(label: 'Estado', value: user.isActive ? '✅ Activa' : '❌ Suspendida',
                    valueColor: user.isActive ? Colors.green : Colors.red),
StatRow(
  label: 'Límite préstamo',
  value: '${NumberFormat('#,##0', 'es').format(user.maxLoan)} SC',
  valueColor: kGold,
),              ])),
              const SizedBox(height: 20),
              SectionCard(
                borderColor: kGold.withOpacity(0.3),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Progreso de nivel de tarjeta', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  ..._tiers.map((t) {
                    final min = t['min'] as double;
                    final reached = user.balance >= min;
                    final isCurrent = user.cardType == t['name'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent ? kGold.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrent ? Border.all(color: kGold.withOpacity(0.3)) : null,
                      ),
                      child: Row(children: [
                        Text(reached ? '✅' : '⬜', style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${t['name']} Card',
                            style: TextStyle(color: reached ? Colors.white : Colors.white38, fontSize: 13,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal))),
                        Text('\$${NumberFormat('#,##0','es').format(min)} SC',
                            style: TextStyle(color: reached ? kGold : Colors.white24, fontSize: 12)),
                      ]),
                    );
                  }),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  static const _tiers = [
    {'name': 'Blue', 'min': 1000.0}, {'name': 'Silver', 'min': 5000.0},
    {'name': 'Premium', 'min': 10000.0}, {'name': 'Platinum', 'min': 20000.0},
    {'name': 'Gold', 'min': 50000.0}, {'name': 'Ruby', 'min': 100000.0},
    {'name': 'Black', 'min': 250000.0}, {'name': 'Diamond', 'min': 500000.0},
  ];

  Widget _cardFront(user, NumberFormat fmt) {
  return Center(
    child: BankCard(
  userId: user.id,
  name: user.name,
  cardType: user.cardType,
  balance: user.balance,
)
  );
}

  Widget _cardBack(user) {
  return Center(
    child: Container(
      width: 540,
      height: 310,
      decoration: BoxDecoration(
        gradient: cardGradient(user.cardType),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.6),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              // Banda magnética
              Container(
                height: 46,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(height: 20),

              // CVV
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 170,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "CVV 847",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Text(
                user.roleLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "ID: ${user.id}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Límite de préstamo",
                style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                ),
              ),

              Text(
                "${NumberFormat('#,##0', 'es').format(user.maxLoan)} SC",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "AMONG BANK",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.45),
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

// ══════════════════════════════════════════════════════
// HISTORY SCREEN
// ══════════════════════════════════════════════════════
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    final hasTabs = state.currentUser?.canViewAllHistory ?? false;
    _tabs = TabController(length: hasTabs ? 2 : 1, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser!;
    final isAdmin = user.canViewAllHistory;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('📜 Historial'),
        backgroundColor: kBg,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: kGold), onPressed: () => state.refreshCurrentUser()),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white54),
            color: kCard,
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text('Todos', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'transfer_out', child: Text('Transferencias enviadas', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'transfer_in', child: Text('Transferencias recibidas', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'load_sc', child: Text('Cargas SC', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'bonus', child: Text('Bonos', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
        bottom: isAdmin ? TabBar(
          controller: _tabs,
          indicatorColor: kGold, labelColor: kGold, unselectedLabelColor: Colors.white38,
          tabs: const [Tab(text: 'Mis movimientos'), Tab(text: 'Todos los usuarios')],
        ) : null,
      ),
      body: isAdmin
    ? TabBarView(
        controller: _tabs,
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: BannerHeader(
                  image: "assets/images/banners/historial.jpeg",
                ),
              ),
              Expanded(
                child: _TxList(
                  txs: _applyFilter(state.transactions),
                  users: state.users,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: BannerHeader(
                  image: "assets/images/banners/historial.jpeg",
                ),
              ),
              Expanded(
                child: _TxList(
                  txs: _applyFilter(state.allTransactions),
                  users: state.users,
                  showUser: true,
                ),
              ),
            ],
          ),
        ],
      )
    : Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: BannerHeader(
              image: "assets/images/banners/historial.jpeg",
            ),
          ),
          Expanded(
            child: _TxList(
              txs: _applyFilter(state.transactions),
              users: state.users,
            ),
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _applyFilter(List<TransactionModel> txs) {
    if (_filter == 'all') return txs;
    return txs.where((t) => t.type == _filter).toList();
  }
}

class _TxList extends StatelessWidget {
  final List<TransactionModel> txs;
  final List users;
  final bool showUser;
  const _TxList({required this.txs, required this.users, this.showUser = false});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'es');
    if (txs.isEmpty) {
      return const Center(child: Text('Sin movimientos 💫', style: TextStyle(color: Colors.white38, fontSize: 16)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: txs.length,
      separatorBuilder: (_, __) => const Divider(color: Color(0xFF1C2333), height: 1),
      itemBuilder: (_, i) {
        final tx = txs[i];
        final pos = tx.amount > 0;
        String? userName;

if (showUser) {
  try {
    userName = users.firstWhere((u) => u.id == tx.userId).name;
  } catch (_) {
    userName = tx.userId;
  }
}
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          leading: Container(width: 42, height: 42,
            decoration: BoxDecoration(
              color: pos ? const Color(0xFF14532D) : const Color(0xFF7F1D1D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(tx.icon, style: const TextStyle(fontSize: 20)))),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (userName != null)
              Text(userName, style: const TextStyle(color: kGold, fontSize: 11, fontWeight: FontWeight.w600)),
            Text(tx.description, style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
          subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(tx.timestamp), style: const TextStyle(color: Colors.white24, fontSize: 11)),
          trailing: Text(
            '${pos ? '+' : ''}\$${fmt.format(tx.amount.abs())}',
            style: TextStyle(color: pos ? const Color(0xFF4ADE80) : const Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════
// RANKING SCREEN
// ══════════════════════════════════════════════════════
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});
  @override State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() { super.initState(); _tabs = TabController(length: 1, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('🏆 Ranking'),
        backgroundColor: kBg,
        bottom: TabBar(
          controller: _tabs, indicatorColor: kGold,
          labelColor: kGold, unselectedLabelColor: Colors.white38,
          tabs: const [Tab(text: '💰 Patrimonio')],
        ),
      ),
      body: _RankList(
  users: state.rankingByBalance,
  byBalance: true,
  currentId: state.currentUser?.id,
),
    );
  }
}

class _RankList extends StatelessWidget {
  final List users; final bool byBalance; final String? currentId;
  const _RankList({required this.users, required this.byBalance, this.currentId});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'es');
    final medals = ['🥇','🥈','🥉'];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final u = users[i];
        final isMe = u.id == currentId;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isMe ? kGold.withOpacity(0.08) : kCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isMe ? kGold.withOpacity(0.4) : kBorder),
          ),
          child: Row(children: [
            SizedBox(width: 36, child: Text(i < 3 ? medals[i] : '${i+1}',
                style: const TextStyle(fontSize: 18, color: Colors.white54))),
            CircleAvatar(
              radius: 18, backgroundColor: kGold.withOpacity(0.15),
              backgroundImage: (u.avatarUrl != null && u.avatarUrl!.isNotEmpty) ? NetworkImage(u.avatarUrl!) : null,
              child: (u.avatarUrl == null || u.avatarUrl!.isEmpty)
                  ? Text(u.initials, style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 12)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.name, style: TextStyle(color: isMe ? kGold : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(u.cardType, style: const TextStyle(color: Colors.white24, fontSize: 11)),
            ])),
            Text(
  '\$${fmt.format(u.balance)} SC',
                style: TextStyle(color: isMe ? kGold : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        );
      },
    );
  }
}
