import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'theme.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String cardType;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.cardType,
    this.onTap,
  });

  Color _accent() {
    switch (cardType) {
      case 'Blue':
        return const Color(0xFF3B82F6);
      case 'Silver':
        return const Color(0xFFC0C0C0);
      case 'Premium':
        return const Color(0xFF8B5CF6);
      case 'Platinum':
        return const Color(0xFFE5E7EB);
      case 'Gold':
        return const Color(0xFFFFD700);
      case 'Ruby':
        return const Color(0xFFE11D48);
      case 'Black':
        return const Color(0xFF444444);
      case 'Diamond':
        return const Color(0xFF38BDF8);
      default:
        return kGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent();
    final fmt = NumberFormat('#,##0.00', 'es');

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
       child: Container(
        height: 230,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: accent.withOpacity(.35),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF121826),
              Color(0xFF0B101B),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(.12),
              blurRadius: 35,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(.45),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [

            Positioned(
              right: -50,
              bottom: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withOpacity(.15),
                    width: 2,
                  ),
                ),
              ),
            ),

            Positioned(
  top: -25,
  left: 120,
  child: Transform.rotate(
    angle: -.35,
    child: Container(
      width: 250,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.12),
            Colors.white.withOpacity(.02),
            Colors.transparent,
          ],
        ),
      ),
    ),
  ),
),

            Positioned(
              right: 30,
              top: 10,
              child: Icon(
                Icons.account_balance_rounded,
                color: accent.withOpacity(.8),
                size: 42,
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "SALDO DISPONIBLE",
                  style: TextStyle(
                    color: Colors.white60,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),

                const Spacer(),

                Text(
                  "${fmt.format(balance)} SC",
                  style: TextStyle(
                    color: accent,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  ),
  decoration: BoxDecoration(
    color: accent.withOpacity(.12),
    borderRadius: BorderRadius.circular(30),
    border: Border.all(
      color: accent.withOpacity(.35),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.credit_card,
        size: 16,
        color: accent,
      ),
      const SizedBox(width: 8),
      Text(
        "Mi tarjeta",
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),
                   ],
            ),
          ],
        ),
      ),
    ),
  );
}
}