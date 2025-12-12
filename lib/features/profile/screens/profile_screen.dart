import 'package:flutter/material.dart';
import 'package:moovapp/features/premium/screens/premium_screen.dart';
import 'package:moovapp/features/auth/screens/welcome_screen.dart';
import '../widgets/profile_activity_item.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stat_card.dart';
import 'communities_screen.dart';
import 'notifications_screen.dart';
import 'security_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: colors.primary,
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            title: Text(
              'Mon Profil',
              style: TextStyle(
                color: colors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.settings_outlined, color: colors.onPrimary),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ));
                },
              ),
            ],
            flexibleSpace: const FlexibleSpaceBar(
              background: ProfileHeader(
                name: 'Ahmed Benali',
                email: 'ahmed.benali@um6p.ma',
                avatarInitials: 'AB',
                universityInfo: 'UM6P - Étudiant',
              ),
              collapseMode: CollapseMode.pin,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Column(
                children: [
                  _buildPremiumCard(context, theme, colors),
                  _buildContactCard(context, theme, colors),
                  _buildStatsRow(colors),
                  _buildActivitySection(theme, colors),
                  _buildMenuSection(context, theme, colors),
                  _buildLogoutButton(context, colors),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(
      BuildContext context, ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              colors.primary,
              colors.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PremiumScreen(),
              ));
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium, color: colors.onPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Passez à Premium',
                        style: TextStyle(
                          color: colors.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sans pub, stats avancées et fonctionnalités exclusives',
                    style: TextStyle(color: colors.onPrimary.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.onPrimary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Découvrir Premium',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
      BuildContext context, ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coordonnées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email_outlined,
                    color: colors.onSurface.withOpacity(0.7)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ahmed.benali@um6p.ma',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      'Email universitaire vérifié',
                      style: TextStyle(
                        color: Colors.green[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone_outlined,
                    color: colors.onSurface.withOpacity(0.7)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Non renseigné',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      'Numéro de téléphone (optionnel)',
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          const Text('L\'ajout de téléphone est optionnel'),
                      backgroundColor: colors.primary,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: colors.onSurface.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Ajouter un numéro (optionnel)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ProfileStatCard(
              icon: Icons.directions_car_filled_outlined,
              value: '12',
              label: 'Trajets effectués',
              iconColor: colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: ProfileStatCard(
              icon: Icons.star_border_outlined,
              value: '4.9',
              label: 'Note moyenne',
              iconColor: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: ProfileStatCard(
              icon: Icons.people_outline,
              value: '28',
              label: 'Passagers',
              iconColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activité récente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ProfileActivityItem(
              icon: Icons.directions_car_outlined,
              iconBgColor: colors.primary,
              title: 'Trajet complété',
              subtitle: 'Ben Guerir → UM6P Campus',
              trailing: 'Hier',
            ),
            Divider(height: 24, color: colors.onSurface.withOpacity(0.2)),
            ProfileActivityItem(
              icon: Icons.star_outline,
              iconBgColor: colors.primary,
              title: 'Nouvel avis reçu',
              subtitle: '5 étoiles de Fatima Z.',
              trailing: '2j',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
      BuildContext context, ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            ProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ));
              },
            ),
            Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colors.onSurface.withOpacity(0.2)),
            ProfileMenuItem(
              icon: Icons.people_alt_outlined,
              title: 'Mes communautés',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const CommunitiesScreen(),
                ));
              },
            ),
            Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colors.onSurface.withOpacity(0.2)),
            ProfileMenuItem(
              icon: Icons.security_outlined,
              title: 'Sécurité',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SecurityScreen(),
                ));
              },
            ),
            Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colors.onSurface.withOpacity(0.2)),
            ProfileMenuItem(
              icon: Icons.settings_outlined,
              title: 'Paramètres',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ));
              },
            ),
            Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colors.onSurface.withOpacity(0.2)),
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Aide & Support',
              hasBorder: false,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SupportScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
       );

        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              'Se déconnecter',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
