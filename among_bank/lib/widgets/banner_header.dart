import 'package:flutter/material.dart';

class BannerHeader extends StatelessWidget {
  final String image;

  const BannerHeader({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
  height: 230,
  width: double.infinity,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(28),
    image: DecorationImage(
      image: AssetImage(image),
      fit: BoxFit.cover,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.45),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(.10),
          Colors.black.withOpacity(.70),
        ],
      ),
    ),
  ),
);
  }
}