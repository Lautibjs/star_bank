import 'package:flutter/material.dart';
import 'theme.dart';

class PremiumBalanceCard extends StatelessWidget {
  final double balance;
  final String cardType;
  final VoidCallback? onTap;

  const PremiumBalanceCard({
    super.key,
    required this.balance,
    required this.cardType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: cardGradient(cardType),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: cardTextColor(cardType).withOpacity(.18),
              blurRadius: 35,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [

            Positioned(
              right: -60,
              top: -40,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.05),
                ),
              ),
            ),

            Positioned(
              left: 30,
              top: 28,
              child: Text(
                "SALDO DISPONIBLE",
                style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
            ),

            Positioned(
              left: 30,
              top: 78,
              child: Text(
                "\$${balance.toStringAsFixed(2)} SC",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                ),
              ),
            ),

            Positioned(
              left: 30,
              bottom: 30,
              child: Row(
                children: const [

                  Icon(
                    Icons.visibility_outlined,
                    color: Colors.white70,
                    size: 18,
                  ),

                  SizedBox(width: 8),

                  Text(
                    "Ver detalles",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 30,
              bottom: 25,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 72,
                color: Colors.white.withOpacity(.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}