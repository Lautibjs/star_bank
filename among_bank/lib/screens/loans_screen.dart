import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../widgets/theme.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});
  @override State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  final _payCtrl = TextEditingController();
  Map<String, dynamic>? _offer;
  Map<String, dynamic>? _activeLoan;

  double _amount = 1000;
  int _days = 7;

  bool _loading = false;
  bool _dataLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _payCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final state = context.read<AppState>();
    final offer = await state.getLoanOffer(
  _amount,
  _days,
);

final active = await FirebaseService.getActiveLoan(
  state.currentUser!.id,
);

if (mounted) {
  setState(() {
    _offer = offer;
    _activeLoan = active;
    _dataLoading = false;
  });
}
  }

  Future<void> _take() async {
    setState(() => _loading = true);
    final r = await context.read<AppState>().takeLoan(
  _amount,
  _days,
);
    if (!mounted) return;
    showMsg(context, r, isError: !r.startsWith('✅'));
    setState(() => _loading = false);
    _load();
  }

  Future<void> _pay() async {
    final amt = double.tryParse(_payCtrl.text.replaceAll(',', '.'));
    if (amt == null || amt <= 0) { showMsg(context, '❌ Monto inválido', isError: true); return; }
    setState(() => _loading = true);
    final r = await context.read<AppState>().payLoan(amt);
    if (!mounted) return;
    showMsg(context, r, isError: !r.startsWith('✅'));
    _payCtrl.clear();
    setState(() => _loading = false);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser!;
    final fmt = NumberFormat('#,##0.00', 'es');

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('🏦 Préstamos'), backgroundColor: kBg),
      body: _dataLoading
          ? const Center(child: CircularProgressIndicator(color: kGold))
          : Stack(fit: StackFit.expand, children: [
              Opacity(opacity: 0.05, child: Image.asset('assets/images/loans_bg.png', fit: BoxFit.cover)),
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  // SALDO
                  Container(padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kGold.withOpacity(0.2))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Saldo actual', style: TextStyle(color: Colors.white38, fontSize: 13)),
                      Text('\$${fmt.format(user.balance)} SC', style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 18)),
                    ])),
                  const SizedBox(height: 20),

                  if (_activeLoan != null) ...[
                    // PRÉSTAMO ACTIVO
                    Container(padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kCard, borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.withOpacity(0.4)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Row(children: [
                          Icon(Icons.account_balance, color: Colors.orange, size: 22),
                          SizedBox(width: 8),
                          Text('Préstamo activo', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                        ]),
                        const SizedBox(height: 16),
                        StatRow(label: 'Monto original', value: '\$${fmt.format((_activeLoan!['amount'] as num).toDouble())} SC'),
                        StatRow(label: 'Total a pagar', value: '\$${fmt.format((_activeLoan!['totalToPay'] as num).toDouble())} SC', valueColor: const Color(0xFFF87171)),
                        StatRow(label: 'Pagado', value: '\$${fmt.format((_activeLoan!['paid'] as num).toDouble())} SC', valueColor: const Color(0xFF4ADE80)),
                        StatRow(label: 'Pendiente',
                          value: '\$${fmt.format(((_activeLoan!['totalToPay'] as num) - (_activeLoan!['paid'] as num)).toDouble())} SC',
                          valueColor: Colors.orange),
                        const SizedBox(height: 12),
                        ClipRRect(borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_activeLoan!['paid'] as num) / (_activeLoan!['totalToPay'] as num),
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                            minHeight: 6)),
                        const SizedBox(height: 16),
                        AmountField(controller: _payCtrl, label: 'Monto a pagar'),
                        const SizedBox(height: 12),
                        GoldButton(label: 'Realizar pago', loading: _loading, onTap: _pay, icon: Icons.payment),
                      ])),
                  ] else if (_offer != null) ...[
                    // OFERTA
                    Container(padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [kGold.withOpacity(0.08), const Color(0xFF14532D).withOpacity(0.08)]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kGold.withOpacity(0.3)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                       const Text(
  'Monto máximo disponible',
  style: TextStyle(
    color: Colors.white70,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
),

const SizedBox(height: 8),

StatRow(
  label: 'Rol',
  value: user.roleLabel,
),

const SizedBox(height: 15),

Text(
  '${NumberFormat('#,###', 'es').format(user.maxLoan)} SC',
  style: const TextStyle(
    color: kGold,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 20),

Slider(
  value: _amount,
  min: 1000,
  max: user.maxLoan,
  divisions: (user.maxLoan ~/ 1000),
  label: _amount.toInt().toString(),
  onChanged: (v) async {
    setState(() => _amount = v);

    _offer = await context.read<AppState>().getLoanOffer(
      _amount,
      _days,
    );

    setState(() {});
  },
),

Column(
  children: [
    const Text(
      'Monto solicitado',
      style: TextStyle(
        color: Colors.white54,
      ),
    ),
    const SizedBox(height: 4),
    Text(
      '${NumberFormat('#,###', 'es').format(_amount)} SC',
      style: const TextStyle(
        color: kGold,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  ],
),

const SizedBox(height: 20),

DropdownButtonFormField<int>(
  value: _days,
  dropdownColor: kCard,
  decoration: const InputDecoration(
    labelText: 'Plazo',
  ),
  items: const [
    DropdownMenuItem(value: 7, child: Text('7 días (5%)')),
    DropdownMenuItem(value: 10, child: Text('10 días (10%)')),
    DropdownMenuItem(value: 15, child: Text('15 días (15%)')),
    DropdownMenuItem(value: 30, child: Text('30 días (25%)')),
  ],
  onChanged: (v) async {
  if (v == null) return;

  setState(() {
    _days = v;
  });

  _offer = await context.read<AppState>().getLoanOffer(
    _amount,
    _days,
  );

  setState(() {});
},
),

const SizedBox(height: 20),

StatRow(
  label: 'Interés',
  value:
      '${((_offer!['interest'] as double) * 100).toStringAsFixed(0)}%',
),

StatRow(
  label: 'Total a pagar',
  value:
      '${(_offer!['totalToPay'] as double).toStringAsFixed(0)} SC',
),

StatRow(
  label: 'Vencimiento',
  value: DateFormat(
    'dd/MM/yyyy',
  ).format(
    DateTime.now().add(
      Duration(days: _days),
    ),
  ),
),

const SizedBox(height: 20),

GoldButton(
  label: 'Confirmar préstamo',
  loading: _loading,
  onTap: _take,
), 
                      ])),
                  ],
                  const SizedBox(height: 20),
                  // INFORMACIÓN BANCARIA
                  SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('🏦 Información bancaria', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    StatRow(label: 'Rol', value: user.roleLabel),
                    StatRow(label: 'Límite préstamo', value: '${user.maxLoan.toInt()} SC', valueColor: kGold),
                    StatRow(label: 'Tarjeta', value: user.cardType),
                    StatRow(label: 'Estado', value: user.isActive ? '✅ Activo' : '❌ Suspendido',
                        valueColor: user.isActive ? Colors.green : Colors.red),
                  ])),
                ]),
              ),
            ]),
    );
  }
}
