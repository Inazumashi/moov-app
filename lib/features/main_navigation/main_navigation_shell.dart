import 'package:flutter/material.dart';
import 'package:moovapp/features/home/screens/home_screen.dart';
import 'package:moovapp/features/search/screens/search_screen.dart';
import 'package:moovapp/features/publish/screens/publish_screen.dart';
import 'package:moovapp/features/favorites/screens/favorites_screen.dart';
import 'package:moovapp/features/profile/screens/profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  MainNavigationShellState createState() => MainNavigationShellState();
}

class MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;
  
  // Configuration des écrans de navigation
  static final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const PublishScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  // Configuration des éléments de navigation
  static const List<BottomNavigationBarItem> _navItems = [
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
  ];

  // Méthode publique pour naviguer vers un index
  void navigateTo(int index) {
    if (index < 0 || index >= _screens.length) return;
    
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Gestionnaire de clic sur les items de navigation
  void _onItemTapped(int index) {
    navigateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      
      // Écran actif
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      
      // Barre de navigation inférieure
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurface.withOpacity(0.6),
        backgroundColor: colors.surface,
        elevation: 8,
      ),
    );
  }
}