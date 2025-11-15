import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String avatarInitials;
  final String universityInfo;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.avatarInitials,
    required this.universityInfo,
  });

  @override
  Widget build(BuildContext context) {
    // Ce widget est utilisé à l'intérieur d'un FlexibleSpaceBar,
    // il gère donc sa propre disposition avec un Stack pour que
    // le contenu s'affiche joliment sous l'AppBar.
    return Container(
      // S'assurer que le fond est de la bonne couleur
      color: Theme.of(context).colorScheme.primary,
      child: Stack(
        children: [
          // Positionne le contenu principal (avatar, nom, etc.)
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar "AB"
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Text(
                    avatarInitials,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Nom, email, et université
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Tag Université
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          universityInfo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

