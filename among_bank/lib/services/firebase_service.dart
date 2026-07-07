import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  // ── USUARIOS ─────────────────────────────────────────────────
  static Future<void> saveUser(UserModel u) =>
      _db.collection('users').doc(u.id).set(u.toMap());

  static Future<void> updateUser(UserModel u) =>
      _db.collection('users').doc(u.id).update(u.toMap());

  static Future<List<UserModel>> getAllUsers() async {
  final s = await _db.collection('users').get();
  final List<UserModel> users = [];
  for (final d in s.docs) {
    try {
      users.add(UserModel.fromMap(d.id, d.data()));
    } catch (e) {
      debugPrint('Error parseando usuario ${d.id}: $e');
    }
  }
  return users;
}

  static Future<UserModel?> getUserById(String id) async {
    final d = await _db.collection('users').doc(id).get();
    return d.exists ? UserModel.fromMap(d.id, d.data()!) : null;
  }

  static Future<void> deleteUser(String id) async {
    await _db.collection('users').doc(id).delete();
  }

  // ── BANCO CENTRAL ─────────────────────────────────────────────
  static Future<double> getBankBalance() async {
    final d = await _db.collection('config').doc('banco_central').get();
    return d.exists ? (d.data()?['balance'] ?? 5000000).toDouble() : 5000000;
  }

  static Future<void> saveBankBalance(double b) =>
      _db.collection('config').doc('banco_central').set(
          {'balance': b, 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true));

  // ── TRANSACCIONES ─────────────────────────────────────────────
  static Future<void> saveTransaction(TransactionModel tx) =>
      _db.collection('transactions').doc(tx.id).set(tx.toMap());

  static Future<List<TransactionModel>> getUserTransactions(String userId) async {
    final s = await _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(200)
        .get();
    return s.docs.map((d) => TransactionModel.fromMap(d.id, d.data())).toList();
  }

  static Future<List<TransactionModel>> getAllTransactions() async {
    final s = await _db
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(500)
        .get();
    return s.docs.map((d) => TransactionModel.fromMap(d.id, d.data())).toList();
  }

  // ── NOTIFICACIONES ────────────────────────────────────────────
  static Future<void> saveNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    final id = 'notif_${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection('notifications').doc(id).set({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'read': false,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    final s = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    return s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  static Future<void> markAllNotificationsRead(String userId) async {
    final s = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();
    for (final d in s.docs) {
      await d.reference.update({'read': true});
    }
  }

  // ── PRÉSTAMOS ─────────────────────────────────────────────────
  static Future<void> saveLoan({
    required String userId,
    required double amount,
    required double interest,
    required double totalToPay,
    required int weeks,
  }) async {
    final id = 'loan_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection('loans').doc(id).set({
      'userId': userId,
      'amount': amount,
      'interest': interest,
      'totalToPay': totalToPay,
      'paid': 0.0,
      'weeks': weeks,
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>?> getActiveLoan(String userId) async {
    final s = await _db
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (s.docs.isEmpty) return null;
    return {'id': s.docs.first.id, ...s.docs.first.data()};
  }

  static Future<void> updateLoanPaid(String loanId, double paid) =>
      _db.collection('loans').doc(loanId).update({'paid': paid});

  static Future<void> closeLoan(String loanId) =>
      _db.collection('loans').doc(loanId).update({'status': 'paid'});

  // ── AHORROS ──────────────────────────────────────────────────
  static Future<void> saveSavings({
  required String userId,
  required double amount,
  required double interest,
  required int days,
}) async {

  final now = DateTime.now();
  final end = now.add(Duration(days: days));

  await _db.collection('savings').doc(userId).set({
    'userId': userId,
    'amount': amount,
    'interest': interest,
    'days': days,
    'createdAt': now.toIso8601String(),
    'endDate': end.toIso8601String(),
    'claimed': false,
  });
}

  static Future<Map<String, dynamic>?> getSavings(String userId) async {
    final d = await _db.collection('savings').doc(userId).get();
    return d.exists ? {'id': d.id, ...d.data()!} : null;
  }

  static Future<void> updateSavingsAmount(String userId, double amount) =>
      _db.collection('savings').doc(userId).update({
        'amount': amount,
        'lastInterest': DateTime.now().toIso8601String(),
      });

  static Future<void> deleteSavings(String userId) =>
      _db.collection('savings').doc(userId).delete();
}
