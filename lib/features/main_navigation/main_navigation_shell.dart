import 'package:flutter/material.dart';

// (Les imports rouges sont normaux tant que les fichiers n'existent pas)
import 'package:moovapp/features/home/screens/home_screen.dart';
import 'package:moovapp/features/search/screens/search_screen.dart';
import 'package:moovapp/features/publish/screens/publish_screen.dart';
import 'package:moovapp/features/favorites/screens/favorites_screen.dart';
import 'package:moovapp/features/profile/screens/profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    SearchScreen(),
    PublishScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,

      // Écran actif
      body: _screens.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Rechercher',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 32),
            activeIcon: Icon(Icons.add_circle, size: 32),
            label: 'Publier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_outlined),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],

        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        // --- MODE SOMBRE/CLEAR AUTOMATIQUE ---
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurface.withOpacity(0.6),
        backgroundColor: colors.surface,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 5.0,
      ),
    );
  }
}
