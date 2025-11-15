import 'package:flutter/material.dart';

class ProfileActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String trailing;

  const ProfileActivityItem({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // L'icône dans un cercle de couleur
        CircleAvatar(
          radius: 22,
          backgroundColor: iconBgColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: iconBgColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        // Le texte (Titre et sous-titre)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Le texte de fin (Hier, 2j)
        Text(
          trailing,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

