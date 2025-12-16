// File: lib/widgets/user_badge.dart
import 'package:flutter/material.dart';

enum UserRole { driver, passenger, both }

class UserBadge extends StatelessWidget {
  final UserRole role;
  final bool showText;
  final double size;
  final Color? customColor;

  const UserBadge({
    super.key,
    required this.role,
    this.showText = true,
    this.size = 24,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = customColor ?? _getColor(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showText ? 8 : 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: size * 0.7,
            color: Colors.white,
          ),
          if (showText) ...[
            SizedBox(width: size * 0.2),
            Text(
              _getText(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColor(BuildContext context) {
    switch (role) {
      case UserRole.driver:
        return Colors.blue[700]!;
      case UserRole.passenger:
        return Colors.green[700]!;
      case UserRole.both:
        return Colors.purple[700]!;
    }
  }

  IconData _getIcon() {
    switch (role) {
      case UserRole.driver:
        return Icons.directions_car;
      case UserRole.passenger:
        return Icons.person;
      case UserRole.both:
        return Icons.supervised_user_circle;
    }
  }

  String _getText() {
    switch (role) {
      case UserRole.driver:
        return 'Conducteur';
      case UserRole.passenger:
        return 'Passager';
      case UserRole.both:
        return 'Conducteur & Passager';
    }
  }
}
