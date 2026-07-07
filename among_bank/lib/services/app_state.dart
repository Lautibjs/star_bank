import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import 'firebase_service.dart';

class AppState extends ChangeNotifier {
  bool _loading = true;
  String _error = '';
  UserModel? _currentUser;
  List<UserModel> _users = [];
  double _bankBalance = 5000000;
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _allTransactions = [];
  List<Map<String, dynamic>> _notifications = [];
  SharedPreferences? _prefs;

  bool get isLoading => _loading;
  String get error => _error;
  UserModel? get currentUser => _currentUser;
  List<UserModel> get users => _users;
  double get bankBalance => _bankBalance;
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get allTransactions => _allTransactions;
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoggedIn => _currentUser != null;
  int get unreadCount => _notifications.where((n) => n['read'] == false).length;

  // ── USUARIOS PRIVILEGIADOS HARDCODEADOS ─────────────────────
  // Siempre existen en memoria. Firestore es secundario.
  static final _lautaro = UserModel(
    id: 'lautaro_superadmin',
    name: 'LautaroPRIV',
    password: 'Admin2026#SuperSeguro',
    role: 'super_admin',
    balance: 0,
    cardType: 'Diamond',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
  );

  static final _itzel = UserModel(
    id: 'itzel_lider',
    name: 'Itzel',
    password: 'Itzel2026#Lider',
    role: 'lider_supremo',
    balance: 0,
    cardType: 'Diamond',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
  );

  // ── INICIALIZACIÓN ────────────────────────────────────────────
  Future<void> initialize() async {
  try {
    _loading = true;
    _error = '';
    notifyListeners();

    _prefs = await SharedPreferences.getInstance();

    // Cargar usuarios con reintento (hasta 3 veces)
    List<UserModel> firestoreUsers = [];
    for (int i = 0; i < 3; i++) {
      try {
        firestoreUsers = await FirebaseService.getAllUsers()
            .timeout(const Duration(seconds: 10));
        if (firestoreUsers.isNotEmpty) break;
      } catch (e) {
        debugPrint('Intento ${i + 1} fallido: $e');
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    debugPrint('=== Usuarios en Firestore: ${firestoreUsers.length} ===');
    for (final u in firestoreUsers) {
      debugPrint('  Usuario: ${u.name} | pass: ${u.password} | id: ${u.id}');
    }

    try {
      _bankBalance = await FirebaseService.getBankBalance()
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('getBankBalance error: $e');
    }

    // Construir _users
    _users = [];
    _users.add(firestoreUsers.firstWhere(
        (u) => u.id == 'lautaro_superadmin', orElse: () => _lautaro));
    _users.add(firestoreUsers.firstWhere(
        (u) => u.id == 'itzel_lider', orElse: () => _itzel));
    for (final u in firestoreUsers) {
      if (u.id != 'lautaro_superadmin' && u.id != 'itzel_lider') {
        _users.add(u);
      }
    }

    debugPrint('=== Total en _users: ${_users.length} ===');
    for (final u in _users) {
      debugPrint('  _users: ${u.name} | pass: ${u.password}');
    }

    _savePrivilegedUsersToFirestore();

    final savedId = _prefs?.getString('currentUserId');

if (savedId != null) {
  try {
    // SIEMPRE leer el usuario directamente desde Firestore
    final user = await FirebaseService.getUserById(savedId);

    if (user != null) {
      _currentUser = user;

      // Actualizar también la lista en memoria
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
      } else {
        _users.add(user);
      }

      await _loadUserData();
    } else {
      await _prefs?.remove('currentUserId');
    }
  } catch (e) {
    debugPrint('Error cargando usuario actual: $e');
  }
}

    _loading = false;
    notifyListeners();
  } catch (e) {
    debugPrint('Initialize error: $e');
    _ensurePrivilegedUsersInMemory();
    _loading = false;
    _error = '';
    notifyListeners();
  }
}

UserModel? _findById(List<UserModel> list, String id) {
  try { return list.firstWhere((u) => u.id == id); } catch (_) { return null; }
}

void _ensurePrivilegedUsersInMemory() {
  if (!_users.any((u) => u.id == 'lautaro_superadmin')) _users.insert(0, _lautaro);
  if (!_users.any((u) => u.id == 'itzel_lider')) _users.insert(1, _itzel);
}

Future<void> _savePrivilegedUsersToFirestore() async {
  try {
    await FirebaseService.saveUser(_findById(_users, 'lautaro_superadmin') ?? _lautaro);
    await FirebaseService.saveUser(_findById(_users, 'itzel_lider') ?? _itzel);
  } catch (e) {
    debugPrint('Could not save privileged users to Firestore: $e');
  }
}
 
  // ── LOGIN ─────────────────────────────────────────────────────
  Future<String?> login(String name, String password) async {
  final nameTrim = name.trim().toLowerCase();

  UserModel? found;

  for (final u in _users) {
    if (u.name.toLowerCase() == nameTrim && u.password == password) {
      found = u;
      break;
    }
  }

  if (found == null) return 'Usuario o contraseña incorrectos.';
  if (!found.isActive) return 'Tu cuenta está suspendida.';

  // Leer el usuario actualizado desde Firestore
  final firebaseUser = await FirebaseService.getUserById(found.id);

  _currentUser = firebaseUser ?? found;

  debugPrint("========== LOGIN ==========");
  debugPrint("Usuario: ${_currentUser!.name}");
  debugPrint("ID: ${_currentUser!.id}");

  await _prefs?.setString('currentUserId', _currentUser!.id);

  await _loadUserData();

  notifyListeners();

  return null;
}

  Future<void> logout() async {
    _currentUser = null;
    _transactions = [];
    _allTransactions = [];
    _notifications = [];
    await _prefs?.remove('currentUserId');
    notifyListeners();
  }

  Future<void> _loadUserData() async {
  if (_currentUser == null) return;

  // ================== TRANSACCIONES ==================
  try {
    _transactions = await FirebaseService
        .getUserTransactions(_currentUser!.id)
        .timeout(const Duration(seconds: 6));

    debugPrint("══════════════════════════════");
    debugPrint("📜 HISTORIAL");
    debugPrint("Usuario: ${_currentUser!.name}");
    debugPrint("ID: ${_currentUser!.id}");
    debugPrint("Transacciones: ${_transactions.length}");

    for (final tx in _transactions) {
      debugPrint("${tx.type} | ${tx.userId} | ${tx.amount}");
    }
  } catch (e) {
    debugPrint("❌ ERROR AL CARGAR TRANSACCIONES");
    debugPrint(e.toString());
    _transactions = [];
  }

  // ================== NOTIFICACIONES ==================
  try {
    _notifications = await FirebaseService
        .getUserNotifications(_currentUser!.id)
        .timeout(const Duration(seconds: 6));

    debugPrint("🔔 Notificaciones: ${_notifications.length}");
  } catch (e) {
    debugPrint("❌ ERROR AL CARGAR NOTIFICACIONES");
    debugPrint(e.toString());
    _notifications = [];
  }

  // ================== HISTORIAL GENERAL ==================
  if (_currentUser!.canViewAllHistory) {
    try {
      _allTransactions = await FirebaseService
          .getAllTransactions()
          .timeout(const Duration(seconds: 8));

      debugPrint("🏦 Historial general: ${_allTransactions.length}");
    } catch (e) {
      debugPrint("❌ ERROR HISTORIAL GENERAL");
      debugPrint(e.toString());
      _allTransactions = [];
    }
  } else {
    _allTransactions = [];
  }

  notifyListeners();
}

  // ── REFRESH ────────────────────────────────────────────────────
  Future<void> refreshAll() async {
    try {
      final fb = await FirebaseService.getAllUsers().timeout(const Duration(seconds: 8));
      _bankBalance = await FirebaseService.getBankBalance().timeout(const Duration(seconds: 5));

      // Reconstruir lista conservando privilegiados
      _users = [];
      _users.add(_findById(fb, 'lautaro_superadmin') ?? _lautaro);
      _users.add(_findById(fb, 'itzel_lider') ?? _itzel);
      for (final u in fb) {
        if (u.id != 'lautaro_superadmin' && u.id != 'itzel_lider') _users.add(u);
      }

      if (_currentUser != null) {
        final updated = _findById(_users, _currentUser!.id);
        if (updated != null) _currentUser = updated;
        await _loadUserData();
      }
    } catch (e) { debugPrint('refreshAll error: $e'); }
    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;
    try {
      final updated = await FirebaseService.getUserById(_currentUser!.id)
          .timeout(const Duration(seconds: 5));
      if (updated != null) {
        _currentUser = updated;
        final idx = _users.indexWhere((u) => u.id == updated.id);
        if (idx >= 0) _users[idx] = updated;
      }
      await _loadUserData();
    } catch (e) { debugPrint('refreshCurrentUser error: $e'); }
    notifyListeners();
  }

  // ── CREAR USUARIO ────────────────────────────────────────────
  Future<String> createUser(String name, String password, String role) async {
    if (_currentUser == null || !_currentUser!.canCreateUsers)
      return '❌ Sin permisos para crear usuarios';
    if (name.trim().isEmpty || password.trim().isEmpty)
      return '❌ Completá nombre y contraseña';
    if (_users.any((u) => u.name.toLowerCase() == name.toLowerCase().trim()))
      return '❌ Ya existe un usuario con ese nombre';

    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(
      id: id, name: name.trim(), password: password.trim(),
      role: role, createdAt: DateTime.now(),
    );
    try {
      await FirebaseService.saveUser(user);
    } catch (e) {
      return '❌ Error al guardar en Firebase: $e\n\nVerificá las reglas de Firestore.';
    }
    _users.add(user);
    try { await FirebaseService.getAllUsers().then((fb) {
      for (final u in fb) {
        if (!_users.any((x) => x.id == u.id)) _users.add(u);
      }
    }); } catch (_) {}
    notifyListeners();
    return '✅ Usuario ${user.name} creado como ${user.roleLabel}';
  }

  // ── AVATAR ───────────────────────────────────────────────────
  Future<void> updateAvatar(String url) async {
    if (_currentUser == null) return;
    _currentUser!.avatarUrl = url;
    try { await FirebaseService.updateUser(_currentUser!); } catch (_) {}
    final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (idx >= 0) _users[idx] = _currentUser!;
    notifyListeners();
  }

  // ── TRANSFERENCIAS ────────────────────────────────────────────
Future<String> transfer(String toId, double amount) async {
  if (_currentUser == null) return '❌ Sin sesión';
  if (amount <= 0) return '❌ Monto inválido';
  if (_currentUser!.balance < amount) return '❌ Saldo insuficiente';
  final to = _findById(_users, toId);

  debugPrint("========== TRANSFER ==========");
  debugPrint("toId recibido: $toId");
  debugPrint("Usuario encontrado: ${to?.name}");
  debugPrint("ID encontrado: ${to?.id}");

  if (to == null) return '❌ Usuario no encontrado';
  if (!to.isActive) return '❌ El usuario destino está suspendido';
  if (to.id == _currentUser!.id) return '❌ No podés transferirte a vos mismo';

  _currentUser!.balance -= amount;
  to.balance += amount;

  _checkCardUpgrade(_currentUser!);
  _checkCardUpgrade(to);

  try {
    await FirebaseService.updateUser(_currentUser!);
    await FirebaseService.updateUser(to);

    final base = 'tx_${DateTime.now().millisecondsSinceEpoch}';

    final txOut = TransactionModel(
      id: '${base}_out',
      userId: _currentUser!.id,
      type: 'transfer_out',
      amount: -amount,
      toId: to.id,
      toName: to.name,
      fromName: _currentUser!.name,
      description: 'Transferencia a ${to.name}',
      timestamp: DateTime.now(),
    );

    final txIn = TransactionModel(
      id: '${base}_in',
      userId: to.id,
      type: 'transfer_in',
      amount: amount,
      toId: _currentUser!.id,
      toName: _currentUser!.name,
      fromName: _currentUser!.name,
      description: 'Transferencia de ${_currentUser!.name}',
      timestamp: DateTime.now(),
    );

    await FirebaseService.saveTransaction(txOut);
    await FirebaseService.saveTransaction(txIn);

    await FirebaseService.saveNotification(
      userId: to.id,
      title: '💸 Recibiste SC',
      message: '${_currentUser!.name} te envió \$${amount.toStringAsFixed(0)} SC',
      type: 'transfer_in',
    );
  } catch (e) {
    return '❌ Error en Firebase: $e';
  }

  await _loadUserData();

  notifyListeners();

  return '✅ Transferencia completada';
}

  // ── CARGAR SC ─────────────────────────────────────────────────
Future<String> loadSC(String userId, double amount) async {
  if (_currentUser == null || !_currentUser!.canLoadSC) {
    return '❌ Sin permisos';
  }

  if (amount <= 0) return '❌ Monto inválido';
  if (_bankBalance < amount) return '❌ Banco Central sin fondos';

  final target = _findById(_users, userId);
  if (target == null) return '❌ Usuario no encontrado';
  if (!target.isActive) return '❌ Usuario suspendido';

  _bankBalance -= amount;
  target.balance += amount;
  _checkCardUpgrade(target);

  try {
    await FirebaseService.saveBankBalance(_bankBalance);

    // Guarda el usuario actualizado
    await FirebaseService.updateUser(target);

    // Si el usuario modificado es el que está logueado,
    // volvemos a leerlo desde Firestore.
    if (_currentUser != null && _currentUser!.id == target.id) {
      final actualizado = await FirebaseService.getUserById(target.id);
      if (actualizado != null) {
        _currentUser = actualizado;
      }
    }

    final tx = TransactionModel(
      id: 'sc_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: 'load_sc',
      amount: amount,
      fromName: _currentUser!.name,
      description: 'Carga SC por ${_currentUser!.name}',
      timestamp: DateTime.now(),
    );

    await FirebaseService.saveTransaction(tx);

    await FirebaseService.saveNotification(
      userId: userId,
      title: '💰 Recibiste Star Coins',
      message: '${_currentUser!.name} te cargó \$${amount.toStringAsFixed(0)} SC',
      type: 'load_sc',
    );

  } catch (e) {
    return '❌ Error en Firebase: $e';
  }

  notifyListeners();

  return '✅ \$${amount.toStringAsFixed(0)} SC cargados a ${target.name}';
}

  Future<String> rechargeBank(double amount) async {
    if (_currentUser == null || !_currentUser!.canRechargeBank)
      return '❌ Solo LautaroPRIV puede recargar el banco';
    if (amount <= 0) return '❌ Monto inválido';
    _bankBalance += amount;
    try { await FirebaseService.saveBankBalance(_bankBalance); } catch (e) { return '❌ Error: $e'; }
    notifyListeners();
    return '✅ Banco recargado con \$${amount.toStringAsFixed(0)} SC';
  }

  // ── PRÉSTAMOS ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> getLoanOffer(
  double amount,
  int days,
) async {
  if (_currentUser == null) return {};

  if (amount > _currentUser!.maxLoan) {
    amount = _currentUser!.maxLoan;
  }

  double interest;

  switch (days) {
    case 7:
      interest = 0.05;
      break;

    case 10:
      interest = 0.10;
      break;

    case 15:
      interest = 0.15;
      break;

    default:
      interest = 0.25;
      break;
  }

  return {
    'amount': amount,
    'interest': interest,
    'totalToPay': amount * (1 + interest),
    'days': days,
  };
}

  Future<String> takeLoan(double amount, int days) async {
  if (_currentUser == null) return '❌ Sin sesión';

  if (amount > _currentUser!.maxLoan) {
    return '❌ Superás el límite permitido para tu rol.';
  }

  try {
    final existing =
        await FirebaseService.getActiveLoan(_currentUser!.id);

    if (existing != null) {
      return '❌ Ya tenés un préstamo activo.';
    }
  } catch (_) {}

  final offer = await getLoanOffer(amount, days);

  _currentUser!.balance += amount;

  _checkCardUpgrade(_currentUser!);

  try {
    await FirebaseService.updateUser(_currentUser!);

    await FirebaseService.saveLoan(
      userId: _currentUser!.id,
      amount: amount,
      interest: offer['interest'],
      totalToPay: offer['totalToPay'],
      weeks: days,
    );

    final tx = TransactionModel(
      id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser!.id,
      type: 'loan',
      amount: amount,
      description: 'Préstamo a $days días',
      timestamp: DateTime.now(),
    );

    await FirebaseService.saveTransaction(tx);

    _transactions.insert(0, tx);

  } catch (e) {
    return '❌ Error: $e';
  }

  notifyListeners();

  return '✅ Préstamo aprobado por ${amount.toStringAsFixed(0)} SC';
}

  Future<String> payLoan(double amount) async {
    if (_currentUser == null) return '❌ Sin sesión';
    if (_currentUser!.balance < amount) return '❌ Saldo insuficiente';
    Map<String, dynamic>? loan;
    try { loan = await FirebaseService.getActiveLoan(_currentUser!.id); } catch (_) {}
    if (loan == null) return '❌ Sin préstamo activo';
    final paid = (loan['paid'] as num).toDouble() + amount;
    final total = (loan['totalToPay'] as num).toDouble();
    _currentUser!.balance -= amount;
    try {
      await FirebaseService.updateUser(_currentUser!);
      if (paid >= total) { await FirebaseService.closeLoan(loan['id']); }
      else { await FirebaseService.updateLoanPaid(loan['id'], paid); }
      final tx = TransactionModel(id: 'lpay_${DateTime.now().millisecondsSinceEpoch}',
          userId: _currentUser!.id, type: 'loan_payment', amount: -amount,
          description: 'Pago de préstamo', timestamp: DateTime.now());
      await FirebaseService.saveTransaction(tx);
      _transactions.insert(0, tx);
    } catch (e) { return '❌ Error: $e'; }
    notifyListeners();
    return paid >= total ? '✅ Préstamo saldado completamente' : '✅ Pago registrado. Falta \$${(total-paid).toStringAsFixed(0)} SC';
  }

  // ── AHORROS ───────────────────────────────────────────────────
  Future<String> deposit(double amount) async {
    if (_currentUser == null) return '❌ Sin sesión';
    if (_currentUser!.balance < amount) return '❌ Saldo insuficiente';
    if (amount < 100) return '❌ Mínimo 100 SC';
    double current = 0;
    try {
      final existing = await FirebaseService.getSavings(_currentUser!.id);
      current = existing != null ? (existing['amount'] as num).toDouble() : 0;
    } catch (_) {}
    _currentUser!.balance -= amount;
    try {
      await FirebaseService.updateUser(_currentUser!);
await FirebaseService.saveSavings(
  userId: _currentUser!.id,
  amount: current + amount,
  interest: 0.05,
  days: 7,
);
      final tx = TransactionModel(id: 'save_${DateTime.now().millisecondsSinceEpoch}',
          userId: _currentUser!.id, type: 'save', amount: -amount,
          description: 'Depósito en ahorros', timestamp: DateTime.now());
      await FirebaseService.saveTransaction(tx);
      _transactions.insert(0, tx);
    } catch (e) { return '❌ Error: $e'; }
    notifyListeners();
    return '✅ Depositaste \$${amount.toStringAsFixed(0)} SC en ahorros';
  }

  Future<String> withdrawSavings(double amount) async {
    if (_currentUser == null) return '❌ Sin sesión';
    Map<String, dynamic>? savings;
    try { savings = await FirebaseService.getSavings(_currentUser!.id); } catch (_) {}
    if (savings == null) return '❌ Sin ahorros';
    final current = (savings['amount'] as num).toDouble();
    if (amount > current) return '❌ Monto mayor al saldo ahorrado';
    _currentUser!.balance += amount;
    _checkCardUpgrade(_currentUser!);
    try {
      await FirebaseService.updateUser(_currentUser!);
      if (current - amount <= 0) { await FirebaseService.deleteSavings(_currentUser!.id); }
      else { await FirebaseService.updateSavingsAmount(_currentUser!.id, current - amount); }
      final tx = TransactionModel(id: 'wtdr_${DateTime.now().millisecondsSinceEpoch}',
          userId: _currentUser!.id, type: 'withdraw', amount: amount,
          description: 'Retiro de ahorros', timestamp: DateTime.now());
      await FirebaseService.saveTransaction(tx);
      _transactions.insert(0, tx);
    } catch (e) { return '❌ Error: $e'; }
    notifyListeners();
    return '✅ Retiraste \$${amount.toStringAsFixed(0)} SC de ahorros';
  }
Future<String> createSaving({
  required double amount,
  required int days,
}) async {

  if (_currentUser == null) {
    return '❌ Usuario no encontrado';
  }

  if (amount <= 0) {
    return '❌ Monto inválido';
  }

  if (_currentUser!.balance < amount) {
    return '❌ Saldo insuficiente';
  }

  final current = await FirebaseService.getSavings(
    _currentUser!.id,
  );

  if (current != null) {
    return '❌ Ya tenés un plazo fijo activo';
  }

  double interest = 0;

  switch (days) {
    case 7:
      interest = .05;
      break;

    case 10:
      interest = .10;
      break;

    case 15:
      interest = .15;
      break;

    case 30:
      interest = .25;
      break;
  }

  _currentUser!.balance -= amount;

  await FirebaseService.updateUser(
    _currentUser!,
  );

  await FirebaseService.saveSavings(
    userId: _currentUser!.id,
    amount: amount,
    interest: interest,
    days: days,
  );

  final tx = TransactionModel(
  id: 'saving_${DateTime.now().millisecondsSinceEpoch}',
  userId: _currentUser!.id,
  type: 'saving_deposit',
  amount: -amount,
  description: 'Plazo fijo creado ($days días)',
  timestamp: DateTime.now(),
);

await FirebaseService.saveTransaction(tx);
_transactions.insert(0, tx);

  notifyListeners();

  return '✅ Plazo fijo creado';
}

Future<String> claimSaving() async {
  if (_currentUser == null) {
    return '❌ Usuario no encontrado';
  }

  final saving = await FirebaseService.getSavings(
    _currentUser!.id,
  );

  if (saving == null) {
    return '❌ No tenés un plazo fijo';
  }

  final endDate = DateTime.parse(
    saving['endDate'],
  );

  if (DateTime.now().isBefore(endDate)) {
    return '❌ El plazo fijo aún no venció';
  }

  final amount = (saving['amount'] as num).toDouble();
  final interest = (saving['interest'] as num).toDouble();

  final total = amount + (amount * interest);

  _currentUser!.balance += total;

  await FirebaseService.updateUser(
    _currentUser!,
  );

  await FirebaseService.deleteSavings(
    _currentUser!.id,
  );

  final tx = TransactionModel(
  id: 'saving_claim_${DateTime.now().millisecondsSinceEpoch}',
  userId: _currentUser!.id,
  type: 'saving_claim',
  amount: total,
  description: 'Cobro de plazo fijo',
  timestamp: DateTime.now(),
);

await FirebaseService.saveTransaction(tx);
_transactions.insert(0, tx);

  notifyListeners();

  return '✅ Recibiste ${total.toStringAsFixed(0)} SC';
}

  // ── TIENDA ─────────────────────────────────────────────────────
Future<String> purchaseBox(String boxType, double cost) async {
  if (_currentUser == null) return '❌ Sin sesión';
  if (_currentUser!.balance < cost) return '❌ SC insuficientes';
  _currentUser!.balance -= cost;
  await FirebaseService.updateUser(_currentUser!);
  final tx = TransactionModel(
    id: 'box_${DateTime.now().millisecondsSinceEpoch}',
    userId: _currentUser!.id,
    type: 'box_purchase',
    amount: -cost,
    description: 'Compra caja $boxType',
    timestamp: DateTime.now(),
  );
  await FirebaseService.saveTransaction(tx);
  _transactions.insert(0, tx);
    
  await FirebaseService.saveNotification(
    userId: 'itzel_lider',
    title: '📦 Caja comprada',
    message: '${_currentUser!.name} compró la caja: $boxType (\$${cost.toStringAsFixed(0)} SC)',
    type: 'purchase',
  );
  await FirebaseService.saveNotification(
    userId: 'lautaro_superadmin',
    title: '📦 Caja comprada',
    message: '${_currentUser!.name} compró la caja: $boxType (\$${cost.toStringAsFixed(0)} SC)',
    type: 'purchase',
  );
  
  notifyListeners();
  return '✅ Caja $boxType comprada. ¡Tu líder te entregará el premio!';
}

  Future<String> purchasePrize(String prizeName, double cost) async {
  if (_currentUser == null) return '❌ Sin sesión';
  if (_currentUser!.balance < cost) return '❌ SC insuficientes';
  _currentUser!.balance -= cost;
  try {
    await FirebaseService.updateUser(_currentUser!);
    final tx = TransactionModel(
      id: 'prize_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser!.id,
      type: 'prize_purchase',
      amount: -cost,
      description: 'Premio: $prizeName',
      timestamp: DateTime.now(),
    );
    await FirebaseService.saveTransaction(tx);
    _transactions.insert(0, tx);
    
    // Notificar a Itzel
    await FirebaseService.saveNotification(
      userId: 'itzel_lider',
      title: '🏆 Premio canjeado',
      message: '${_currentUser!.name} canjeó el premio: $prizeName (\$${cost.toStringAsFixed(0)} SC)',
      type: 'prize_request',
    );
    
    // Notificar a Lautaro
    await FirebaseService.saveNotification(
      userId: 'lautaro_superadmin',
      title: '🏆 Premio canjeado',
      message: '${_currentUser!.name} canjeó el premio: $prizeName (\$${cost.toStringAsFixed(0)} SC)',
      type: 'prize_request',
    );
    
  } catch (e) {
    return '❌ Error al canjear premio: $e';
  }
  notifyListeners();
  return '✅ Premio canjeado. Tu líder te lo entregará pronto.';
}

  // ── BONOS ─────────────────────────────────────────────────────
Future<String> claimBonus(String bonusKey, double amount) async {
  if (_currentUser == null) return '❌ Sin sesión';

  final now = DateTime.now();

  String realKey = bonusKey;

  switch (bonusKey) {
    case 'daily':
      realKey = 'daily_${now.day}_${now.month}_${now.year}';
      break;

    case 'weekly':
      final week = ((now.day - 1) ~/ 7) + 1;
      realKey = 'weekly_${week}_${now.month}_${now.year}';
      break;

    case 'monthly':
      realKey = 'monthly_${now.month}_${now.year}';
      break;

    case 'bienvenida':
      realKey = 'bienvenida';
      break;
  }

  // Ya fue reclamado
  if (_currentUser!.claimedBonuses.contains(realKey)) {
    return '❌ Ya reclamaste este bono.';
  }

  // Verificar antigüedad del usuario
  final created = _currentUser!.createdAt ?? now;
  final days = now.difference(created).inDays;

  if (bonusKey == 'weekly' && days < 7) {
    return '❌ El bono semanal se desbloquea luego de 7 días en Among Bank.';
  }

  if (bonusKey == 'monthly' && days < 30) {
    return '❌ El bono mensual se desbloquea luego de 30 días en Among Bank.';
  }

  // Entregar bono
  _currentUser!.balance += amount;
  _currentUser!.claimedBonuses.add(realKey);

  _checkCardUpgrade(_currentUser!);

  try {
    await FirebaseService.updateUser(_currentUser!);

    final tx = TransactionModel(
      id: 'bon_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser!.id,
      type: 'bonus',
      amount: amount,
      description: 'Bono $bonusKey',
      timestamp: DateTime.now(),
    );

    await FirebaseService.saveTransaction(tx);

    _transactions.insert(0, tx);

  } catch (e) {
    return '❌ Error: $e';
  }

  notifyListeners();

  return '✅ Bono reclamado correctamente.';
}

  // ── ADMIN ─────────────────────────────────────────────────────
  Future<String> suspendUser(String userId) async {
    if (_currentUser == null || !_currentUser!.canSuspendUsers) return '❌ Sin permisos';
    if (userId == 'lautaro_superadmin' || userId == 'itzel_lider') return '❌ No se puede suspender a usuarios privilegiados';
    final u = _findById(_users, userId);
    if (u == null) return '❌ No encontrado';
    u.isActive = false;
    try { await FirebaseService.updateUser(u); } catch (e) { return '❌ Error: $e'; }
    notifyListeners();
    return '✅ ${u.name} suspendido';
  }

  Future<String> activateUser(String userId) async {
    if (_currentUser == null || !_currentUser!.canSuspendUsers) return '❌ Sin permisos';
    final u = _findById(_users, userId);
    if (u == null) return '❌ No encontrado';
    u.isActive = true;
    try { await FirebaseService.updateUser(u); } catch (e) { return '❌ Error: $e'; }
    notifyListeners();
    return '✅ ${u.name} activado';
  }

  Future<String> deleteUser(String userId) async {
    if (_currentUser == null || !_currentUser!.canDeleteUsers) return '❌ Solo LautaroPRIV puede eliminar usuarios';
    if (userId == 'lautaro_superadmin' || userId == 'itzel_lider') return '❌ No se puede eliminar a usuarios privilegiados';
    try { await FirebaseService.deleteUser(userId); } catch (e) { return '❌ Error: $e'; }
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
    return '✅ Usuario eliminado';
  }

  Future<String> changeRole(String userId, String newRole) async {
    if (_currentUser == null || !_currentUser!.canModifyRoles) return '❌ Solo LautaroPRIV puede cambiar roles';
    if (userId == 'lautaro_superadmin') return '❌ No se puede modificar a LautaroPRIV';
    final u = _findById(_users, userId);
    if (u == null) return '❌ No encontrado';
    u.role = newRole;
    try { await FirebaseService.updateUser(u); } catch (e) { return '❌ Error: $e'; }
    notifyListeners();
    return '✅ Rol de ${u.name} cambiado a ${u.roleLabel}';
  }

  Future<String> adjustBalance(String userId, double amount) async {
    if (_currentUser == null || !_currentUser!.canLoadSC) return '❌ Sin permisos';
    final u = _findById(_users, userId);
    if (u == null) return '❌ No encontrado';
    u.balance = (u.balance + amount).clamp(0, double.infinity);
    _checkCardUpgrade(u);
    try { await FirebaseService.updateUser(u); } catch (e) { return '❌ Error: $e'; }
    notifyListeners();
    return amount > 0 ? '✅ +\$${amount.toStringAsFixed(0)} SC a ${u.name}' : '✅ -\$${amount.abs().toStringAsFixed(0)} SC a ${u.name}';
  }

  Future<void> markAllRead() async {
    if (_currentUser == null) return;
    try { await FirebaseService.markAllNotificationsRead(_currentUser!.id); } catch (_) {}
    for (var n in _notifications) n['read'] = true;
    notifyListeners();
  }

  // ── HELPERS ───────────────────────────────────────────────────
  void _checkCardUpgrade(UserModel user) {
    final newCard = UserModel.cardForBalance(user.balance);
    if (newCard != user.cardType) {
      final upgraded = _cardRank(newCard) > _cardRank(user.cardType);
      user.cardType = newCard;
      if (upgraded) {
        try {
          FirebaseService.saveNotification(userId: user.id, title: '💳 ¡Nueva tarjeta!',
              message: 'Subiste a la tarjeta $newCard 🎉', type: 'card_upgrade');
        } catch (_) {}
      }
    }
  }

  int _cardRank(String card) {
    const o = ['Starter','Blue','Silver','Premium','Platinum','Gold','Ruby','Black','Diamond'];
    return o.indexOf(card);
  }

  List<UserModel> get rankingByBalance =>
      List<UserModel>.from(_users)..sort((a, b) => b.balance.compareTo(a.balance));

  Map<String, dynamic> getStats() {
    final totalSC = _users.fold(0.0, (s, u) => s + u.balance);
    return {
      'totalUsuarios': _users.length,
      'usuariosActivos': _users.where((u) => u.isActive).length,
      'totalSC': totalSC,
      'bancoCentral': _bankBalance,
    };
  }
}
