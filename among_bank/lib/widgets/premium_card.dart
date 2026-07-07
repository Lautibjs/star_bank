import 'package:flutter/material.dart';
import 'theme.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;

  final String? cardType;

  final EdgeInsetsGeometry padding;

  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.cardType,
    this.padding = const EdgeInsets.all(20),
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

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withOpacity(.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accent.withOpacity(.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: card,
    );
  }
}