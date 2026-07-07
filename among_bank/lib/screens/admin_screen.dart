import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../models/user_model.dart';
import '../widgets/theme.dart';
import '../widgets/banner_header.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    final me = context.read<AppState>().currentUser!;
    final count = me.isSuperAdmin || me.isLiderSupremo ? 3 : 2;
    _tabs = TabController(length: count, vsync: this);
    context.read<AppState>().refreshAll();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final me = state.currentUser!;
    if (!me.canViewAdmin) return Scaffold(backgroundColor: kBg, body: const Center(child: Text('❌ Sin permisos', style: TextStyle(color: Colors.red, fontSize: 18))));

    final tabs = [
      const Tab(text: '👥 Usuarios'),
      const Tab(text: '💰 SC'),
      if (me.isSuperAdmin || me.isLiderSupremo) const Tab(text: '🏦 Banco'),
    ];

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('👑 Panel Admin'), backgroundColor: kBg,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: kGold), onPressed: () => state.refreshAll())],
        bottom: TabBar(controller: _tabs, indicatorColor: kGold, labelColor: kGold, unselectedLabelColor: Colors.white38, tabs: tabs),
      ),
      body: Stack(fit: StackFit.expand, children: [
        Opacity(opacity: 0.04, child: Image.asset('assets/images/admin_bg.png', fit: BoxFit.cover)),
        TabBarView(controller: _tabs, children: [
          _UsersTab(),
          _SCTab(),
          if (me.isSuperAdmin || me.isLiderSupremo) _BankTab(),
        ]),
      ]),
    );
  }
}

// ── USUARIOS ────────────────────────────────────────────────────
class _UsersTab extends StatefulWidget {
  @override State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'tripulante';
  bool _showForm = false, _loading = false, _obscure = true;

  @override
  void dispose() { _nameCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _create() async {
    setState(() => _loading = true);
    final r = await context.read<AppState>().createUser(_nameCtrl.text, _passCtrl.text, _role);
    if (!mounted) return;
    setState(() => _loading = false);
    showMsg(context, r, isError: !r.startsWith('✅'));
    if (r.startsWith('✅')) setState(() { _showForm = false; _nameCtrl.clear(); _passCtrl.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final me = state.currentUser!;

    return ListView(
  padding: const EdgeInsets.all(16),
  children: [

    const BannerHeader(
      image: "assets/images/banners/admin.jpeg",
    ),

    const SizedBox(height: 24),
        if (me.canCreateUsers) ...[
          GoldButton(
            label: _showForm ? '✕ Cancelar' : '➕ Crear nuevo usuario',
            onTap: () => setState(() => _showForm = !_showForm)),
          if (_showForm) ...[
            const SizedBox(height: 16),
            SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('NUEVO USUARIO', style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2)),
              const SizedBox(height: 14),
              TextField(controller: _nameCtrl, style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Nombre de usuario', prefixIcon: Icon(Icons.person_outline, color: kGold))),
              const SizedBox(height: 10),
              TextField(controller: _passCtrl, obscureText: _obscure, style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline, color: kGold),
                      suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure)))),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _role, dropdownColor: kCard, style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'tripulante', child: Text('🚀 Tripulante')),
                  DropdownMenuItem(value: 'moderador', child: Text('🛡️ Moderador')),
                  DropdownMenuItem(value: 'host', child: Text('🎙️ Host')),
                  DropdownMenuItem(value: 'admin', child: Text('🟢 Admin')),
                  DropdownMenuItem(value: 'admin_elite', child: Text('💜 Admin Elite')),
                  DropdownMenuItem(value: 'colider', child: Text('🔵 Co-Líder')),
                  DropdownMenuItem(value: 'lider_supremo', child: Text('⭐ Líder Supremo')),
                ],
                onChanged: (v) => setState(() => _role = v!)),
              const SizedBox(height: 16),
              GoldButton(label: 'Crear usuario', loading: _loading, onTap: _create, icon: Icons.person_add_outlined),
            ])),
          ],
          const SizedBox(height: 20),
        ],
        const Text('MIEMBROS DEL CLAN', style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 10),
        ...state.users.map((u) => _UserCard(u, me)),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel u, me;
  bool get _privileged => u.id == 'lautaro_superadmin' || u.id == 'itzel_lider';
  bool get _isMe => u.id == me.id;
  const _UserCard(this.u, this.me);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'es');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: _isMe ? kGold.withOpacity(0.3) : kBorder)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: u.isActive ? roleColor(u.role).withOpacity(0.2) : Colors.red.withOpacity(0.2),
          backgroundImage: (u.avatarUrl != null && u.avatarUrl!.isNotEmpty) ? NetworkImage(u.avatarUrl!) : null,
          child: (u.avatarUrl == null || u.avatarUrl!.isEmpty)
              ? Text(u.initials, style: TextStyle(color: u.isActive ? roleColor(u.role) : Colors.red, fontWeight: FontWeight.bold)) : null,
        ),
        title: Text(u.name, style: TextStyle(color: _isMe ? kGold : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('${u.roleLabel} • \$${fmt.format(u.balance)} SC • ${u.isActive ? "✅" : "❌"}',
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Column(children: [
            StatRow(label: 'Tarjeta', value: u.cardType),
            if (!_privileged && !_isMe) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                if (me.canSuspendUsers)
                  _Chip(u.isActive ? '🚫 Suspender' : '✅ Activar',
                      u.isActive ? Colors.red : Colors.green, () async {
                    final r = u.isActive
                        ? await context.read<AppState>().suspendUser(u.id)
                        : await context.read<AppState>().activateUser(u.id);
                    if (context.mounted) showMsg(context, r, isError: !r.startsWith('✅'));
                  }),
                if (me.canModifyRoles)
                  _Chip('🔄 Cambiar rol', Colors.blue, () => _showRoleDialog(context)),
                if (me.canDeleteUsers)
                  _Chip('🗑️ Eliminar', Colors.red.shade700, () => _confirmDelete(context)),
              ]),
            ],
            if (_privileged)
              const Padding(padding: EdgeInsets.only(top: 8),
                  child: Text('👑 Usuario privilegiado — protegido', style: TextStyle(color: kGold, fontSize: 11))),
          ])),
        ],
      ),
    );
  }

  void _showRoleDialog(BuildContext ctx) {
    showDialog(context: ctx, builder: (_) {
      String sel = u.role;
      return StatefulBuilder(builder: (c, ss) => AlertDialog(
        backgroundColor: kCard,
        title: Text('Rol de ${u.name}', style: const TextStyle(color: Colors.white, fontSize: 15)),
        content: DropdownButton<String>(value: sel, dropdownColor: kCard, style: const TextStyle(color: Colors.white),
          items: const [
            DropdownMenuItem(value: 'tripulante', child: Text('🚀 Tripulante')),
            DropdownMenuItem(value: 'moderador', child: Text('🛡️ Moderador')),
            DropdownMenuItem(value: 'host', child: Text('🎙️ Host')),
            DropdownMenuItem(value: 'admin', child: Text('🟢 Admin')),
            DropdownMenuItem(value: 'admin_elite', child: Text('💜 Admin Elite')),
            DropdownMenuItem(value: 'colider', child: Text('🔵 Co-Líder')),
            DropdownMenuItem(value: 'lider_supremo', child: Text('⭐ Líder Supremo')),
          ],
          onChanged: (v) => ss(() => sel = v!)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar', style: TextStyle(color: Colors.white38))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kGold),
            onPressed: () async {
              Navigator.pop(c);
              final r = await ctx.read<AppState>().changeRole(u.id, sel);
              if (ctx.mounted) showMsg(ctx, r, isError: !r.startsWith('✅'));
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.black))),
        ],
      ));
    });
  }

  void _confirmDelete(BuildContext ctx) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: kCard,
      title: const Text('¿Eliminar usuario?', style: TextStyle(color: Colors.white)),
      content: Text('Se eliminará a ${u.name} permanentemente.', style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white38))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(ctx);
            final r = await ctx.read<AppState>().deleteUser(u.id);
            if (ctx.mounted) showMsg(ctx, r, isError: !r.startsWith('✅'));
          },
          child: const Text('Eliminar', style: TextStyle(color: Colors.white))),
      ],
    ));
  }
}

class _Chip extends StatelessWidget {
  final String label; final Color color; final VoidCallback onTap;
  const _Chip(this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.35))),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))),
  );
}

// ── SC TAB ──────────────────────────────────────────────────────
class _SCTab extends StatefulWidget {
  @override State<_SCTab> createState() => _SCTabState();
}

class _SCTabState extends State<_SCTab> {
  UserModel? _target;
  final _amtCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _amtCtrl.dispose(); super.dispose(); }

  Future<void> _act(bool add) async {
    if (_target == null) { showMsg(context, '❌ Seleccioná un usuario', isError: true); return; }
    final amt = double.tryParse(_amtCtrl.text.replaceAll(',', '.'));
    if (amt == null || amt <= 0) { showMsg(context, '❌ Monto inválido', isError: true); return; }
    setState(() => _loading = true);
    final r = add ? await context.read<AppState>().loadSC(_target!.id, amt)
                  : await context.read<AppState>().adjustBalance(_target!.id, -amt);
    if (!mounted) return;
    setState(() => _loading = false);
    showMsg(context, r, isError: !r.startsWith('✅'));
    _amtCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final me = state.currentUser!;
    final fmt = NumberFormat('#,##0', 'es');
    if (!me.canLoadSC) return const Center(child: Text('❌ Sin permisos', style: TextStyle(color: Colors.red)));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        SectionCard(borderColor: kGold.withOpacity(0.3), child: StatRow(
          label: '🏦 Banco Central disponible',
          value: '\$${fmt.format(state.bankBalance)} SC', valueColor: kGold)),
        const SizedBox(height: 20),
        SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('GESTIONAR SC', style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 14),
          DropdownButtonFormField<UserModel>(
            value: _target, dropdownColor: kCard,
            decoration: const InputDecoration(labelText: 'Seleccioná usuario'),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            items: state.users.where((u) => u.isActive).map((u) => DropdownMenuItem(value: u,
              child: Text('${u.name} — \$${fmt.format(u.balance)} SC', style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (v) => setState(() => _target = v)),
          const SizedBox(height: 12),
          AmountField(controller: _amtCtrl, label: 'Cantidad de SC'),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: [100, 500, 1000, 5000, 10000].map((v) =>
            GestureDetector(onTap: () => _amtCtrl.text = '$v',
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: kCard2, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
                child: Text('\$${fmt.format(v.toDouble())}', style: const TextStyle(color: kGold, fontSize: 12, fontWeight: FontWeight.w600))))
          ).toList()),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: GoldButton(label: '➕ Cargar SC', loading: _loading, onTap: () => _act(true))),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: _loading ? null : () => _act(false),
              child: Container(height: 52,
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.red.withOpacity(0.35))),
                child: const Center(child: Text('➖ Quitar SC', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)))),
            )),
          ]),
        ])),
        const SizedBox(height: 20),
        const Text('SALDOS POR USUARIO', style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2)),
const SizedBox(height: 10),
...state.rankingByBalance.map((u) => Container(
  margin: const EdgeInsets.only(bottom: 4),
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: kCard,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: kBorder),
  ),
  child: Row(
    children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: roleColor(u.role).withOpacity(0.15),
        child: Text(u.initials, style: TextStyle(color: roleColor(u.role), fontWeight: FontWeight.bold, fontSize: 12)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(u.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
            Text(u.roleLabel, style: const TextStyle(color: Colors.white24, fontSize: 11)),
          ],
        ),
      ),
      Text('\$${fmt.format(u.balance)} SC', style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 13)),
    ],
  ),
)),
      ]),
    );
  }
}

// ── BANCO CENTRAL TAB ────────────────────────────────────────────
class _BankTab extends StatefulWidget {
  @override State<_BankTab> createState() => _BankTabState();
}

class _BankTabState extends State<_BankTab> {
  final _rechCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _rechCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final me = state.currentUser!;
    final stats = state.getStats();
    final fmt = NumberFormat('#,##0', 'es');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // BANCO CENTRAL
        Container(width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [kGold.withOpacity(0.12), kGoldDark.withOpacity(0.06)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGold.withOpacity(0.3)),
          ),
          child: Column(children: [
            const Text('🏦 BANCO CENTRAL', style: TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2)),
            const SizedBox(height: 12),
            Text('\$${fmt.format(state.bankBalance)} SC',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 34)),
            const Text('Saldo disponible para distribución', style: TextStyle(color: Colors.white24, fontSize: 11)),
          ])),
        const SizedBox(height: 20),
        SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📊 ESTADÍSTICAS GLOBALES', style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 12),
          StatRow(label: 'Total usuarios', value: '${stats['totalUsuarios']}'),
          StatRow(label: 'Usuarios activos', value: '${stats['usuariosActivos']}'),
          StatRow(label: 'SC en circulación', value: '\$${fmt.format(stats['totalSC'])} SC', valueColor: const Color(0xFF4ADE80)),
          StatRow(label: 'Banco Central', value: '\$${fmt.format(stats['bancoCentral'])} SC', valueColor: kGold),
        ])),
        if (me.canRechargeBank) ...[
          const SizedBox(height: 20),
          SectionCard(borderColor: kGold.withOpacity(0.2), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('💉 RECARGAR BANCO CENTRAL', style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2)),
            const Text('Solo LautaroPRIV puede ejecutar esta acción', style: TextStyle(color: Colors.white24, fontSize: 11)),
            const SizedBox(height: 14),
            AmountField(controller: _rechCtrl, label: 'Cantidad a agregar'),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 6, children: [10000, 50000, 100000, 500000].map((v) =>
              GestureDetector(onTap: () => _rechCtrl.text = '$v',
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: kCard2, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
                  child: Text('\$${fmt.format(v.toDouble())}', style: const TextStyle(color: kGold, fontSize: 12))))).toList()),
            const SizedBox(height: 14),
            GoldButton(label: '💰 Recargar Banco', loading: _loading, onTap: () async {
              final amt = double.tryParse(_rechCtrl.text.replaceAll(',', '.'));
              if (amt == null || amt <= 0) { showMsg(context, '❌ Monto inválido', isError: true); return; }
              setState(() => _loading = true);
              final r = await context.read<AppState>().rechargeBank(amt);
              if (!mounted) return;
              setState(() => _loading = false);
              showMsg(context, r, isError: !r.startsWith('✅'));
              _rechCtrl.clear();
            }),
          ])),
        ],
      ]),
    );
  }
}
