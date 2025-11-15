import 'package:flutter/material.dart';

// --- ATTENTION : Ces 5 imports seront rouges (Erreurs) ---
// C'est normal, nous n'avons pas encore créé ces fichiers.
import 'package:moovapp/features/home/screens/home_screen.dart';
import 'package:moovapp/features/search/screens/search_screen.dart';
import 'package:moovapp/features/publish/screens/publish_screen.dart';
import 'package:moovapp/features/favorites/screens/favorites_screen.dart';
import 'package:moovapp/features/profile/screens/profile_screen.dart';
// ---------------------------------------------------------

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  // Un 'int' pour mémoriser l'index de l'onglet sélectionné
  int _selectedIndex = 0;

  // La liste des 5 écrans principaux
  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    SearchScreen(),
    PublishScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  // La fonction qui est appelée quand on clique sur un onglet
  void _onItemTapped(int index) {
    // Cas spécial pour le bouton "Publier" (index 2)
    // On veut afficher un "modal" (pop-up) au lieu de changer d'écran
    if (index == 2) {
      // TODO: Afficher le pop-up ou l'écran de publication
      // Pour l'instant, on navigue, mais on pourra changer ça
      setState(() {
        _selectedIndex = index;
      });
    } else {
      setState(() {
        // On met à jour l'index, ce qui va changer l'écran affiché
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le corps du Scaffold est l'écran actuellement sélectionné
      body: _screens.elementAt(_selectedIndex),
      
      // La barre de navigation en bas
      bottomNavigationBar: BottomNavigationBar(
        // Les 5 icônes/boutons
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Icône quand sélectionné
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Rechercher',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 32), // Icône plus grosse
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
        
        // --- Configuration importante ---
        currentIndex: _selectedIndex, // L'onglet actif
        onTap: _onItemTapped, // Ce qu'il faut faire quand on clique
        
        // --- Style (pour correspondre à la maquette) ---
        selectedItemColor: Theme.of(context).colorScheme.primary, // Couleur de l'icône active
        unselectedItemColor: Colors.grey[600], // Couleur des icônes inactives
        showUnselectedLabels: true, // Toujours montrer les labels
        type: BottomNavigationBarType.fixed, // Important pour 5 onglets
        backgroundColor: Colors.white,
        elevation: 5.0,
      ),
    );
  }
}
