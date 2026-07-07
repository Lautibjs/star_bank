import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../widgets/theme.dart';
import 'login_screen.dart';
import 'transfer_screen.dart';
import 'card_history_ranking.dart';
import 'store_screen.dart';
import 'loans_screen.dart';
import 'savings_screen.dart';
import 'misc_screens.dart';
import 'admin_screen.dart';
import 'profile_screen.dart';
import '../widgets/balance_card.dart';
import '../widgets/premium_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _balanceVisible = true;
  final _fmt = NumberFormat('#,##0', 'es');

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return '☀️ Buenos días';
    if (h < 18) return '🌤️ Buenas tardes';
    return '🌙 Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser!;
    final txs = state.transactions.take(4).toList();

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: kGold, backgroundColor: kCard,
          onRefresh: () => state.refreshCurrentUser(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── HEADER ──────────────────────────────────────
              PremiumHeader(
  greeting: _greeting(),
  name: user.name,
  role: user.roleLabel,
  roleColor: roleColor(user.role),

  avatar: GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    ),
    child: _avatar(user),
  ),

  notifications: state.unreadCount,

  onNotifications: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  },

  onSettings: () async {
    await state.logout();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  },
),
              const SizedBox(height: 24),

              // ── RESUMEN DE CUENTA ─────────────────────────────
BalanceCard(
  balance: user.balance,
  cardType: user.cardType,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CardScreen(),
      ),
    );
  },
),

const SizedBox(height: 24),
              // ── ACCIONES RÁPIDAS ──────────────────────────────
              const Text(
  "ACCESOS RÁPIDOS",
  style: TextStyle(
    color: Colors.white54,
    fontWeight: FontWeight.bold,
    fontSize: 13,
    letterSpacing: 2,
  ),
),
              const SizedBox(height: 12),
              Row(children: [
                _QuickBtn(icon: Icons.send_outlined, label: 'Transferir', color: const Color(0xFF3B82F6),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()))),
                _QuickBtn(icon: Icons.storefront_outlined, label: 'Tienda', color: const Color(0xFFA855F7),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen()))),
                _QuickBtn(icon: Icons.savings_outlined, label: 'Ahorros', color: const Color(0xFF22C55E),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()))),
                _QuickBtn(icon: Icons.account_balance_outlined, label: 'Préstamo', color: kGold,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoansScreen()))),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _QuickBtn(icon: Icons.history_outlined, label: 'Historial', color: const Color(0xFFF97316),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
                _QuickBtn(icon: Icons.redeem_outlined, label: 'Bonos', color: const Color(0xFFEC4899),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BonusesScreen()))),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _QuickBtn(icon: Icons.smart_toy_outlined, label: 'Nova', color: const Color(0xFF06B6D4),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NovaScreen()))),
                _QuickBtn(icon: Icons.person_outline, label: 'Perfil', color: Colors.white54,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                if (user.canViewAdmin)
                  _QuickBtn(icon: Icons.admin_panel_settings_outlined, label: 'Admin', color: const Color(0xFFFF4444),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()))),
              ]),
              const SizedBox(height: 28),

              // ── ÚLTIMOS MOVIMIENTOS ───────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text(
  "ÚLTIMOS MOVIMIENTOS",
  style: TextStyle(
    color: Colors.white54,
    fontWeight: FontWeight.bold,
    fontSize: 13,
    letterSpacing: 2,
  ),
),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                  child: const Text('Ver todo', style: TextStyle(color: kGold, fontSize: 12)),
                ),
              ]),
              const SizedBox(height: 8),
              SectionCard(
                padding: txs.isEmpty ? null : EdgeInsets.zero,
                child: txs.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(20),
                        child: Text('Sin movimientos aún 💫', style: TextStyle(color: Colors.white24))))
                    : Column(children: txs.map((tx) {
                        final pos = tx.amount > 0;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          leading: Container(width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: pos ? const Color(0xFF14532D) : const Color(0xFF7F1D1D),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text(tx.icon, style: const TextStyle(fontSize: 18)))),
                          title: Text(tx.description, style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(DateFormat('dd/MM HH:mm').format(tx.timestamp), style: const TextStyle(color: Colors.white24, fontSize: 11)),
                          trailing: Text(
                            '${pos ? '+' : ''}\$${_fmt.format(tx.amount.abs())}',
                            style: TextStyle(color: pos ? const Color(0xFF4ADE80) : const Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        );
                      }).toList()),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _avatar(user) {
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(radius: 24, backgroundImage: NetworkImage(user.avatarUrl!));
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: roleColor(user.role).withOpacity(0.2),
      child: Text(user.initials, style: TextStyle(color: roleColor(user.role), fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
Widget build(BuildContext context) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          splashColor: color.withOpacity(.15),
          highlightColor: Colors.transparent,
          child: Ink(
            height: 135,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B2433),
                  Color(0xFF0D111C),
                ],
              ),
              border: Border.all(
                color: color.withOpacity(.28),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.45),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: color.withOpacity(.12),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(.12),
                    border: Border.all(
                      color: color.withOpacity(.25),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: .4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}