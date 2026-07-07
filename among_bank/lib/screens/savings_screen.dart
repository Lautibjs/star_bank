import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../widgets/theme.dart';
import '../widgets/banner_header.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});
  @override State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _amountCtrl = TextEditingController();

double _amount = 1000;
int _days = 7;
  Map<String, dynamic>? _savings;
  bool _loading = false, _dataLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _amountCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final id = context.read<AppState>().currentUser!.id;
    final s = await FirebaseService.getSavings(id);
    if (mounted) setState(() { _savings = s; _dataLoading = false; });
  }

  Future<void> _createSaving() async {

  setState(() => _loading = true);

  final result = await context.read<AppState>().createSaving(
        amount: _amount,
        days: _days,
      );

  if (!mounted) return;

  showMsg(
    context,
    result,
    isError: !result.startsWith('✅'),
  );

  setState(() => _loading = false);

  _load();
}

Future<void> _claimSaving() async {

  setState(() => _loading = true);

  final result =
      await context.read<AppState>().claimSaving();

  if (!mounted) return;

  showMsg(
    context,
    result,
    isError: !result.startsWith('✅'),
  );

  setState(() => _loading = false);

  _load();
}

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser!;
    final fmt = NumberFormat('#,##0.00', 'es');
    final saved = _savings != null ? (_savings!['amount'] as num).toDouble() : 0.0;
double rate = 0;

if (saved >= 10000) {
  rate = 0.30; // 30%
} else if (saved >= 5000) {
  rate = 0.20; // 20%
} else if (saved >= 1000) {
  rate = 0.10; // 10%
}

final interest = saved * rate;

double fixedRate = switch (_days) {
  7 => 0.05,
  10 => 0.10,
  15 => 0.15,
  _ => 0.25,
};

final profit = _amount * fixedRate;
final total = _amount + profit;

DateTime? endDate;
bool canClaim = false;
int daysLeft = 0;

if (_savings != null && _savings!['endDate'] != null) {
  endDate = DateTime.parse(_savings!['endDate']);
  canClaim = DateTime.now().isAfter(endDate);
  daysLeft = endDate.difference(DateTime.now()).inDays + 1;
}

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('📈 Ahorros'), backgroundColor: kBg),
      body: _dataLoading
    ? const Center(child: CircularProgressIndicator(color: kGold))
    : Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.06,
            child: Image.asset(
              'assets/images/savings_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                const BannerHeader(
                  image: "assets/images/banners/ahorros.jpeg",
                ),

                const SizedBox(height: 24),
                  // BALANCE ROW
                  Row(children: [
                    Expanded(child: _StatCard('Saldo disponible', '\$${fmt.format(user.balance)} SC', const Color(0xFF3B82F6), Icons.account_balance_wallet_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard('En ahorros', '\$${fmt.format(saved)} SC', Colors.green, Icons.savings_outlined)),
                  ]),
                  const SizedBox(height: 12),
                  _StatCard('Interés estimado (${(rate * 100).toInt()}%)', '+\$${fmt.format(interest)} SC', kGold, Icons.trending_up),
                  const SizedBox(height: 24),

                  // DEPOSITAR
                  if (_savings == null)
  SectionCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        'Nuevo plazo fijo',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),

      const SizedBox(height: 20),

      Text(
        '${_amount.toInt()} SC',
        style: const TextStyle(
          color: kGold,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),

      Slider(
        value: _amount,
        min: 1000,
        max: user.balance < 1000 ? 1000 : user.balance,
        divisions: (user.balance ~/ 1000).clamp(1, 100),
        onChanged: (v) {
          setState(() {
            _amount = v;
          });
        },
      ),

      const SizedBox(height: 12),

      DropdownButtonFormField<int>(
        value: _days,
        dropdownColor: kCard,
        decoration: const InputDecoration(
          labelText: 'Plazo',
        ),
        items: const [
          DropdownMenuItem(
            value: 7,
            child: Text('7 días (+5%)'),
          ),
          DropdownMenuItem(
            value: 10,
            child: Text('10 días (+10%)'),
          ),
          DropdownMenuItem(
            value: 15,
            child: Text('15 días (+15%)'),
          ),
          DropdownMenuItem(
            value: 30,
            child: Text('30 días (+25%)'),
          ),
        ],
        onChanged: (v) {
          if (v == null) return;

          setState(() {
            _days = v;
          });
        },
      ),

      const SizedBox(height: 20),

Text(
  'Ganancia: +${profit.toStringAsFixed(0)} SC',
  style: const TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
),

const SizedBox(height: 8),

Text(
  'Total al vencer: ${total.toStringAsFixed(0)} SC',
  style: const TextStyle(
    color: kGold,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  ),
),

const SizedBox(height: 20),

GoldButton(
        label: 'Crear plazo fijo',
        loading: _loading,
        onTap: _createSaving,
      ),
    ],
  ),
),
                  const SizedBox(height: 16),

                  // RETIRAR
                  if (_savings != null)
  SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
  'Plazo fijo activo',
  style: TextStyle(
    color: kGold,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
),

const SizedBox(height: 16),

Text(
  'Capital: ${((_savings!['amount'] ?? 0) as num).toStringAsFixed(0)} SC',
  style: const TextStyle(color: Colors.white),
),

Text(
  'Interés: ${((((_savings!['interest'] ?? 0) as num) * 100).toStringAsFixed(0))}%',
  style: const TextStyle(color: Colors.white),
),

Text(
  'Plazo: ${_savings!['days'] ?? '-'} días',
  style: const TextStyle(color: Colors.white),
),

Text(
  'Vence: ${_savings!['endDate'] != null
      ? DateFormat('dd/MM/yyyy').format(DateTime.parse(_savings!['endDate']))
      : '-'}',
  style: const TextStyle(color: Colors.white70),
),

const SizedBox(height: 20),

GoldButton(
  label: canClaim
      ? 'Reclamar inversión'
      : 'Disponible en $daysLeft día${daysLeft == 1 ? '' : 's'}',
  loading: _loading,
  onTap: canClaim ? _claimSaving : null,
),
      ],
    ),
  ),
                  const SizedBox(height: 16),
                  SectionCard(borderColor: Colors.green.withOpacity(0.2), child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 Cómo funcionan los ahorros', style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Text(
  '• Hasta 1.000 SC: sin interés\n'
  '• Desde 1.000 SC: 10%\n'
  '• Desde 5.000 SC: 20%\n'
  '• Desde 10.000 SC: 30%\n'
  '• Podés retirar cuando quieras\n'
  '• Cuanto más ahorres, mayor será tu rendimiento.',
  style: TextStyle(
    color: Colors.white54,
    fontSize: 13,
    height: 1.7,
  ),
),
                    ],
                  )),
                ]),
              ),
            ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatCard(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCard, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ]),
    ]),
  );
}
