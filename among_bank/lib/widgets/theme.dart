import 'package:flutter/material.dart';

const kGold = Color(0xFFFFD700);
const kGoldDark = Color(0xFFDAA520);
const kBg = Color(0xFF080C14);
const kCard = Color(0xFF111827);
const kCard2 = Color(0xFF1C2333);
const kBorder = Color(0xFF2A3547);

// ── GRADIENTES DE TARJETA ─────────────────────────────────────
LinearGradient cardGradient(String card) {
  switch (card) {
    case 'Diamond': return const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'Black':   return const LinearGradient(colors: [Color(0xFF1C1C1C), Color(0xFF3D3D3D)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'Ruby':    return const LinearGradient(colors: [Color(0xFF7F1D1D), Color(0xFFDC2626)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'Gold':    return const LinearGradient(colors: [Color(0xFF78350F), Color(0xFFD97706)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'Platinum':return const LinearGradient(colors: [Color(0xFF334155), Color(0xFF64748B)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'Premium': return const LinearGradient(colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'Silver':  return const LinearGradient(colors: [Color(0xFF374151), Color(0xFF9CA3AF)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    case 'Blue':    return const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    default:        return const LinearGradient(colors: [Color(0xFF1F2937), Color(0xFF374151)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  }
}

Color cardTextColor(String card) => card == 'Gold' ? Colors.black87 : Colors.white;

Color roleColor(String role) {
  switch (role) {
    case 'super_admin': return const Color(0xFFFF4444);
    case 'lider_supremo': return kGold;
    case 'colider': return const Color(0xFF60A5FA);
    case 'admin_elite': return const Color(0xFFA78BFA);
    case 'admin': return const Color(0xFF34D399);
    default: return const Color(0xFF9CA3AF);
  }
}

// ── WIDGETS ───────────────────────────────────────────────────
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;
  const GoldButton({super.key, required this.label, this.onTap, this.loading = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          gradient: onTap == null ? const LinearGradient(colors: [Color(0xFF374151), Color(0xFF374151)])
              : const LinearGradient(colors: [kGold, kGoldDark]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: onTap != null ? [BoxShadow(color: kGold.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))] : null,
        ),
        child: loading
            ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (icon != null) ...[Icon(icon, color: Colors.black, size: 18), const SizedBox(width: 8)],
                Text(label, style: TextStyle(color: onTap == null ? Colors.white38 : Colors.black, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.3)),
              ]),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  const SectionCard({super.key, required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? kBorder),
      ),
      child: child,
    );
  }
}

class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  const AmountField({super.key, required this.controller, required this.label, this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixText: '\$ ',
        prefixStyle: const TextStyle(color: kGold, fontWeight: FontWeight.bold),
        filled: true, fillColor: kCard2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kGold, width: 1.5)),
        labelStyle: const TextStyle(color: Colors.white38),
      ),
    );
  }
}

class StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const StatRow({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    );
  }
}

void showMsg(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
    backgroundColor: isError ? const Color(0xFF7F1D1D) : const Color(0xFF14532D),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(12),
  ));
}
