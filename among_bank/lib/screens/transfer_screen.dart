import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../models/user_model.dart';
import '../widgets/theme.dart';
import '../widgets/banner_header.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});
  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amountCtrl = TextEditingController();
  UserModel? _selected;
  bool _loading = false, _done = false;
  String _lastResult = '';

  @override
  void dispose() { _amountCtrl.dispose(); super.dispose(); }

  Future<void> _transfer() async {
    if (_selected == null) { showMsg(context, '❌ Elegí un destinatario', isError: true); return; }
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) { showMsg(context, '❌ Monto inválido', isError: true); return; }
    setState(() => _loading = true);
    final result = await context.read<AppState>().transfer(_selected!.id, amount);
    if (!mounted) return;
    setState(() { _loading = false; _lastResult = result; });
    if (result.startsWith('✅')) setState(() => _done = true);
    else showMsg(context, result, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser!;
    final others = state.users.where((u) => u.id != user.id && u.isActive).toList();
    final fmt = NumberFormat('#,##0.00', 'es');

    if (_done) {
      return Scaffold(
        backgroundColor: kBg,
        body: Stack(fit: StackFit.expand, children: [
          Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 90, height: 90,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF14532D),
                  boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)]),
                child: const Icon(Icons.check, color: Colors.greenAccent, size: 50)),
              const SizedBox(height: 28),
              const Text('¡Transferencia\ncompletada!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Para:', style: TextStyle(color: Colors.white38, fontSize: 13)),
                    Text(_selected!.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Monto:', style: TextStyle(color: Colors.white38, fontSize: 13)),
                    Text('\$${fmt.format(double.tryParse(_amountCtrl.text.replaceAll(',','.')) ?? 0)} SC',
                        style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                ])),
              const SizedBox(height: 28),
              GoldButton(label: 'Nueva transferencia', icon: Icons.send_outlined,
                onTap: () => setState(() { _done = false; _selected = null; _amountCtrl.clear(); })),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.pop(context),
                child: const Text('Volver al inicio', style: TextStyle(color: Colors.white38))),
            ]),
          )),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(fit: StackFit.expand, children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const BannerHeader(
  image: "assets/images/banners/transferencias.jpeg",
),

const SizedBox(height: 30),
const Text(
  "TRANSFERENCIAS",
  style: TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  ),
),

const SizedBox(height: 6),

const Text(
  "Envía StarCoins a otros miembros de Star Legion.",
  style: TextStyle(
    color: Colors.white54,
    fontSize: 14,
  ),
),

const SizedBox(height: 24),
            // SALDO
            SectionCard(borderColor: kGold.withOpacity(0.3), child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tu saldo disponible', style: TextStyle(color: Colors.white38, fontSize: 13)),
                Text('\$${fmt.format(user.balance)} SC', style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            )),
            const SizedBox(height: 24),
            const Text('DESTINATARIO', style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2)),
            const SizedBox(height: 10),
            if (others.isEmpty)
              const SectionCard(child: Center(child: Padding(padding: EdgeInsets.all(16),
                child: Text('No hay otros usuarios disponibles', style: TextStyle(color: Colors.white38)))))
            else
              SectionCard(padding: EdgeInsets.zero, child: Column(
                children: others.map((u) {
                  final sel = _selected?.id == u.id;
                  return InkWell(
                    onTap: () => setState(() => _selected = u),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? kGold.withOpacity(0.08) : null,
                        borderRadius: BorderRadius.circular(16),
                        border: sel ? Border.all(color: kGold.withOpacity(0.3)) : null,
                      ),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 20, backgroundColor: roleColor(u.role).withOpacity(0.2),
                          backgroundImage: (u.avatarUrl != null && u.avatarUrl!.isNotEmpty) ? NetworkImage(u.avatarUrl!) : null,
                          child: (u.avatarUrl == null || u.avatarUrl!.isEmpty)
                              ? Text(u.initials, style: TextStyle(color: roleColor(u.role), fontWeight: FontWeight.bold)) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(u.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(u.roleLabel, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        ])),
                        if (sel) const Icon(Icons.check_circle, color: kGold) else const Icon(Icons.radio_button_unchecked, color: Colors.white24),
                      ]),
                    ),
                  );
                }).toList(),
              )),
            const SizedBox(height: 24),
            const Text('CANTIDAD', style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2)),
            const SizedBox(height: 10),
            AmountField(controller: _amountCtrl, label: 'Cantidad de SC a enviar'),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8,
              children: [50, 100, 500, 1000, 2000, 5000].map((v) => GestureDetector(
                onTap: () => _amountCtrl.text = '$v',
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: kCard2, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
                  child: Text('\$$v', style: const TextStyle(color: kGold, fontSize: 13, fontWeight: FontWeight.w600))),
              )).toList()),
            const SizedBox(height: 32),
            GoldButton(label: 'Confirmar transferencia', loading: _loading, onTap: _transfer, icon: Icons.send_outlined),
          ]),
        ),
      ]),
    );
  }
}
