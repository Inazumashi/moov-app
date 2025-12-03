import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:moovapp/core/service/auth_service.dart'; 

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

// 1. On passe en StatefulWidget
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 2. Variables d'état
  String fullName = "";
  String email = "";
  String university = "";
  String profileType = "";
  String initials = "";
  String phone = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 3. Fonction de chargement des données
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String fName = prefs.getString('first_name') ?? "";
      String lName = prefs.getString('last_name') ?? "";
      
      // Construction du nom complet
      fullName = "$fName $lName".trim();
      if (fullName.isEmpty) fullName = "Utilisateur";

      // Email (il faut s'assurer de l'avoir sauvegardé à la connexion, sinon vide)
      // Astuce : Si vous ne l'avez pas sauvegardé dans AuthService, ajoutez-le !
      // Pour l'instant, on suppose qu'il est là ou on met une valeur par défaut
      email = prefs.getString('email') ?? "email@um6p.ma"; 

      university = prefs.getString('university_id') ?? "Université";
      profileType = prefs.getString('profile_type') ?? "Profil";
      phone = prefs.getString('phone') ?? "";

      // Calcul des initiales (ex: Ahmed Benali -> AB)
      if (fName.isNotEmpty && lName.isNotEmpty) {
        initials = "${fName[0]}${lName[0]}".toUpperCase();
      } else if (fName.isNotEmpty) {
        initials = fName[0].toUpperCase();
      } else {
        initials = "U";
      }
    });
  }

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
<<<<<<< HEAD
            flexibleSpace: const FlexibleSpaceBar(
=======
            flexibleSpace: FlexibleSpaceBar(
              // 4. Utilisation des données dynamiques dans le Header
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
              background: ProfileHeader(
                name: fullName,       // ✅ Dynamique
                email: email,         // ✅ Dynamique
                avatarInitials: initials, // ✅ Dynamique
                universityInfo: '$university - $profileType', // ✅ Dynamique
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
                      email, // ✅ Utilisation de la variable dynamique
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
                      // ✅ Affichage conditionnel du téléphone
                      phone.isNotEmpty ? phone : 'Non renseigné',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
<<<<<<< HEAD
                        color: colors.onSurface.withOpacity(0.5),
=======
                        color: colors.onBackground.withOpacity(phone.isNotEmpty ? 1.0 : 0.5),
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
                      ),
                    ),
                    Text(
                      'Numéro de téléphone',
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
<<<<<<< HEAD
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
=======

            // On masque le bouton d'ajout si le téléphone existe déjà (optionnel)
            if (phone.isEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('L\'ajout de téléphone est optionnel'),
                        backgroundColor: colors.primary,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: colors.onBackground.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Ajouter un numéro (optionnel)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.onBackground,
                    ),
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
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
<<<<<<< HEAD
        onPressed: () {},
        child: const Row(
=======
        onPressed: () async {
          // 5. Déconnexion PROPRE
          final authService = AuthService();
          await authService.signOut(); // Nettoie le token et les infos

          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const WelcomeScreen(),
              ),
              (route) => false,
            );
          }
        },
        child: Row(
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
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