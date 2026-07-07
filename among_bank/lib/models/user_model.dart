class UserModel {
  final String id;
  String name;
  String password;
  String role;
  double balance;
  String cardType;
  bool isActive;
  List<String> claimedBonuses;
  String? avatarUrl;
  DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.password,
    this.role = 'tripulante',
    this.balance = 0,
    this.cardType = 'Starter',
    this.isActive = true,
    List<String>? claimedBonuses,
    this.avatarUrl,
    this.createdAt,
  }) : claimedBonuses = claimedBonuses ?? [];

  bool get isSuperAdmin => role == 'super_admin';
  bool get isLiderSupremo => role == 'lider_supremo' || isSuperAdmin;
  bool get isCoLider => role == 'colider' || isLiderSupremo;
  bool get isAdminElite => role == 'admin_elite' || isCoLider;
  bool get isAdmin => role == 'admin' || isAdminElite;

  bool get canCreateUsers => isLiderSupremo;
  bool get canLoadSC => isCoLider;
  bool get canViewAdmin => isAdmin;
  bool get canModifyRoles => isSuperAdmin;
  bool get canSuspendUsers => isAdminElite;
  bool get canDeleteUsers => isSuperAdmin;
  bool get canViewBankCentral => isAdminElite;
  bool get canRechargeBank => isSuperAdmin;
  bool get canViewAllHistory => isLiderSupremo || isSuperAdmin;

  double get maxLoan {
  switch (role) {
    case 'moderador':
      return 10000;

    case 'host':
      return 15000;

    case 'admin':
      return 25000;

    case 'admin_elite':
      return 35000;

    case 'colider':
      return 50000;

    case 'lider_supremo':
    case 'super_admin':
      return 70000;

    default:
      return 5000;
  }
}

  String get roleLabel {
    switch (role) {
      case 'super_admin': return '👑 Líder Supremo';
      case 'lider_supremo': return '⭐ Líder';
      case 'colider': return '🔵 Co-Líder';
      case 'admin_elite': return '💜 Admin Elite';
      case 'admin': return '🟢 Admin';
      case 'host': return '🎙️ Host';
      case 'moderador': return '🛡️ Moderador';
      default: return '🚀 Tripulante';
    }
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  static String cardForBalance(double balance) {
    if (balance >= 100000) return 'Diamond';
    if (balance >= 75000) return 'Black';
    if (balance >= 50000) return 'Ruby';
    if (balance >= 30000) return 'Gold';
    if (balance >= 15000) return 'Platinum';
    if (balance >= 7500) return 'Premium';
    if (balance >= 3000) return 'Silver';
    if (balance >= 1000) return 'Blue';
    return 'Starter';
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'password': password,
        'role': role,
        'balance': balance,
        'cardType': cardType,
        'isActive': isActive,
        'claimedBonuses': claimedBonuses,
        'avatarUrl': avatarUrl,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory UserModel.fromMap(String id, Map<String, dynamic> d) => UserModel(
        id: id,
        name: d['name'] ?? '',
        password: d['password'] ?? '',
        role: d['role'] ?? 'tripulante',
        balance: (d['balance'] ?? 0).toDouble(),
        cardType: d['cardType'] ?? 'Starter',
        isActive: d['isActive'] ?? true,
        claimedBonuses: List<String>.from(d['claimedBonuses'] ?? []),
        avatarUrl: d['avatarUrl'],
        createdAt: d['createdAt'] != null
    ? (d['createdAt'] is String
        ? DateTime.tryParse(d['createdAt'])
        : DateTime.tryParse(d['createdAt'].toDate().toString()))
    : null,
      );
}
