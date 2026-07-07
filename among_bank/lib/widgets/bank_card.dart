import 'package:flutter/material.dart';
import 'theme.dart';

class BankCard extends StatelessWidget {
  final String userId;
  final String name;
  final String cardType;
  final double balance;

  const BankCard({
    super.key,
    required this.userId,
    required this.name,
    required this.cardType,
    required this.balance,
  });

  String get cardNumber {
    final hash = userId.hashCode.abs().toString().padLeft(16, '0');
    return "${hash.substring(0,4)} ${hash.substring(4,8)} ${hash.substring(8,12)} ${hash.substring(12,16)}";
  }

  String get expiry {
    final year = DateTime.now().year + 4;
    return "06/${year.toString().substring(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 540,
      height: 310,
      decoration: BoxDecoration(
        gradient: cardGradient(cardType),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.65),
            blurRadius: 45,
            spreadRadius: 2,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [

            Positioned(
              top: -90,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.05),
                ),
              ),
            ),

            Positioned(
  top: -35,
  left: 150,
  child: Transform.rotate(
    angle: -.35,
    child: Container(
      width: 260,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.16),
            Colors.white.withOpacity(.02),
            Colors.transparent,
          ],
        ),
      ),
    ),
  ),
),

            Positioned(
              bottom: -80,
              left: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(.12),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      const Text(
                        "AMONG BANK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),

                      Row(
                        children: [

                          const Icon(
                            Icons.contactless,
                            color: Colors.white70,
                            size: 26,
                          ),

                          const SizedBox(width: 10),

                          Text(
                            cardType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  Container(
  width: 64,
  height: 46,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xffF7D46A),
        Color(0xffD3A437),
        Color(0xff8A6214),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
      )
    ],
  ),
),
                  const SizedBox(height: 22),

                  Text(
                    cardNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),
                                    Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "TITULAR",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              name.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          const Text(
                            "VENCE",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            expiry,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 22),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          const Text(
                            "SALDO",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "SC ${balance.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 60,
                      height: 34,
                      child: Stack(
                        children: [

                          Positioned(
                            left: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(.9),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          Positioned(
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(.85),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}