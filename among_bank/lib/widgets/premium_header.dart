import 'package:flutter/material.dart';

class PremiumHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final String role;
  final Color roleColor;
  final Widget avatar;
  final int notifications;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;

  const PremiumHeader({
    super.key,
    required this.greeting,
    required this.name,
    required this.role,
    required this.roleColor,
    required this.avatar,
    required this.notifications,
    required this.onNotifications,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        avatar,

        const SizedBox(width: 18),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: roleColor.withOpacity(.45),
                  ),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white70,
                size: 28,
              ),
              onPressed: onNotifications,
            ),

            if (notifications > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    notifications > 9 ? '9+' : '$notifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        IconButton(
          icon: const Icon(
            Icons.settings_outlined,
            color: Colors.white70,
            size: 28,
          ),
          onPressed: onSettings,
        ),
      ],
    );
  }
}