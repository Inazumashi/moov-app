import 'package:flutter/material.dart';
// MISE À JOUR: Import de l'écran suivant
import 'package:moovapp/features/inscription/screens/university_select_screen.dart';

// 1. On crée un StatefulWidget pour mémoriser les sélections
class RoutesConfigScreen extends StatefulWidget {
  const RoutesConfigScreen({super.key});

  @override
  State<RoutesConfigScreen> createState() => _RoutesConfigScreenState();
}

class _RoutesConfigScreenState extends State<RoutesConfigScreen> {
  // 2. On crée des variables d'état pour stocker les choix de l'utilisateur
  final _departController = TextEditingController();
  final _arriveeController = TextEditingController();

  // Un Set est parfait pour stocker les jours (pas de doublons)
  final Set<String> _selectedDays = {};
  // Une simple String pour la plage horaire (un seul choix possible)
  String? _selectedTimeSlot;

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    super.dispose();
  }

  // Liste des jours et plages
  final List<String> _daysOfWeek = [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim'
  ];
  final List<String> _timeSlots = [
    'Matin (6h-12h)',
    'Midi (12h-18h)',
    'Soir (18h-23h)'
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fond légèrement gris
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurez vos trajets habituels',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Étape 1/4 - Nous vous proposerons des trajets...',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // La carte "Trajet 1"
              _buildRouteCard(primaryColor),
              const SizedBox(height: 20),

              // Bouton "Ajouter un autre trajet"
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Logique pour ajouter un nouveau trajet
                },
                icon: Icon(Icons.add, color: primaryColor),
                label: Text(
                  'Ajouter un autre trajet',
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),
              const SizedBox(height: 32),

              // Bouton "Continuer"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // MISE À JOUR: Naviguer vers l'écran 2 (UniversitySelectScreen)
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UniversitySelectScreen(),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Indicateurs de page
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPageIndicator(isActive: true, color: primaryColor),
                  _buildPageIndicator(isActive: false, color: primaryColor),
                  _buildPageIndicator(isActive: false, color: primaryColor),
                  _buildPageIndicator(isActive: false, color: primaryColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour la carte principale
  Widget _buildRouteCard(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trajet 1',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _buildTextField('Départ', 'Ex: Casablanca Centre', _departController,
              Icons.location_on_outlined),
          const SizedBox(height: 16),
          _buildTextField('Arrivée', 'Ex: UM6P Campus', _arriveeController,
              Icons.flag_outlined),
          const SizedBox(height: 16),

          const Text('Jours de la semaine',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Wrap permet aux boutons de passer à la ligne s'il n'y a pas de place
          Wrap(
            spacing: 8.0, // Espace horizontal
            runSpacing: 4.0, // Espace vertical
            children: _daysOfWeek.map((day) {
              final isSelected = _selectedDays.contains(day);
              return FilterChip(
                label: Text(day),
                selected: isSelected,
                onSelected: (bool selected) {
                  // 3. On met à jour l'état quand l'utilisateur clique
                  setState(() {
                    if (selected) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  });
                },
                selectedColor: primaryColor.withOpacity(0.2),
                checkmarkColor: primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? primaryColor : Colors.grey.shade300,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          const Text('Plage horaire',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Column(
            children: _timeSlots.map((slot) {
              final isSelected = _selectedTimeSlot == slot;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      // 4. On met à jour la plage horaire
                      setState(() {
                        if (selected) {
                          _selectedTimeSlot = slot;
                        }
                      });
                    },
                    selectedColor: primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color:
                            isSelected ? primaryColor : Colors.grey.shade300,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget pour les champs de texte Départ/Arrivée
  Widget _buildTextField(String label, String hint,
      TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CORRECTION ICI: Ajout du paramètre 'style:'
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // Widget pour les indicateurs de page en bas
  Widget _buildPageIndicator({required bool isActive, required Color color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 16.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}