import 'package:flutter/material.dart';
//import 'package:moovapp/features/inscription/screens/email_verification_screen.dart';
import 'package:moovapp/features/premium/screens/premium_screen.dart';
import '../widgets/profile_activity_item.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
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
    return Scaffold(
      // On utilise un CustomScrollView pour avoir une AppBar qui disparaît
      // quand on scrolle vers le bas.
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            elevation: 0,
            title: const Text(
              'Mon Profil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ));
                },
              ),
            ],
            // Le header flexible qui contient l'avatar, le nom, etc.
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
          // Le reste du contenu de la page
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[100], // Fond gris clair pour le contenu
              child: Column(
                children: [
                  // Carte Premium
                  _buildPremiumCard(context),

                  // Carte Coordonnées
                  _buildContactCard(context),

                  // Cartes de statistiques
                  _buildStatsRow(),

                  // Section Activité récente
                  _buildActivitySection(),

                  // Section Menu (Notifications, Sécurité, etc.)
                  _buildMenuSection(context),

                  // Bouton Déconnexion
                  _buildLogoutButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Passez à Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sans pub, stats avancées et fonctionnalités exclusives',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Découvrir Premium',
                        style: TextStyle(
                          color: Colors.deepOrange,
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

  Widget _buildContactCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coordonnées',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email_outlined, color: Colors.grey[600]),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ahmed.benali@um6p.ma',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Email universitaire vérifié',
                      style: TextStyle(
                        color: Colors.green[600],
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
                Icon(Icons.phone_outlined, color: Colors.grey[600]),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Non renseigné',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Numéro de téléphone (optionnel)',
                      style: TextStyle(color: Colors.grey[600]),
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
                  // --- OPTION 1 : SI VOUS VOULEZ GARDER L'AJOUT DE TÉLÉPHONE ---
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => const AddPhoneScreen(), // À créer
                  // ));
                  
                  // --- OPTION 2 : MESSAGE D'INFORMATION ---
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('L\'ajout de téléphone est optionnel'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ajouter un numéro (optionnel)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ProfileStatCard(
              icon: Icons.directions_car_filled_outlined,
              value: '12',
              label: 'Trajets effectués',
              iconColor: Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ProfileStatCard(
              icon: Icons.star_border_outlined,
              value: '4.9',
              label: 'Note moyenne',
              iconColor: Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
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

  Widget _buildActivitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activité récente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ProfileActivityItem(
              icon: Icons.directions_car_outlined,
              iconBgColor: Colors.green,
              title: 'Trajet complété',
              subtitle: 'Ben Guerir → UM6P Campus',
              trailing: 'Hier',
            ),
            Divider(height: 24),
            ProfileActivityItem(
              icon: Icons.star_outline,
              iconBgColor: Colors.blue,
              title: 'Nouvel avis reçu',
              subtitle: '5 étoiles de Fatima Z.',
              trailing: '2j',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                  builder: (context) => const NotificationsScreen(),
                ));
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ProfileMenuItem(
              icon: Icons.people_alt_outlined,
              title: 'Mes communautés',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CommunitiesScreen(),
                ));
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ProfileMenuItem(
              icon: Icons.security_outlined,
              title: 'Sécurité',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SecurityScreen(),
                ));
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ProfileMenuItem(
              icon: Icons.settings_outlined,
              title: 'Paramètres',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ));
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Aide & Support',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SupportScreen(),
                ));
              },
              hasBorder: false, // Pas de bordure pour le dernier item
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextButton(
        onPressed: () {
          // TODO: Gérer la déconnexion
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Se déconnecter',
              style: TextStyle(
                color: Colors.red,
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