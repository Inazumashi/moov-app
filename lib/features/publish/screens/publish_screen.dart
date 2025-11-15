import 'package:flutter/material.dart';
// L'import ici sera en ROUGE, c'est normal, on va créer le fichier juste après
import '../widgets/publish_ride_form.dart'; 

// J'ai renommé la classe en PublishScreen
class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  // Clé pour valider le formulaire
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _seatsController = TextEditingController(text: '3'); // Valeur par défaut
  final _priceController = TextEditingController(text: '50'); // Valeur par défaut
  final _vehicleController = TextEditingController();
  final _notesController = TextEditingController();

  // État pour le Switch
  bool _isRegularRide = false;

  // Libère les contrôleurs quand le widget est détruit
  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
    _vehicleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Fonction pour afficher le DatePicker
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    // Formatte la date en jj/mm/aaaa (simple)
    _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    setState(() {}); // Met à jour l'aperçu
    }

  // Fonction pour afficher le TimePicker
  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      _timeController.text = picked.format(context);
      setState(() {}); // Met à jour l'aperçu
    }
  }


  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Publier un trajet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Partagez votre trajet avec la communauté',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ),
        backgroundColor: primaryColor,
        toolbarHeight: 90,
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. LE FORMULAIRE ---
            // On appelle le widget externe
            PublishRideForm(
              formKey: _formKey,
              departureController: _departureController,
              arrivalController: _arrivalController,
              dateController: _dateController,
              timeController: _timeController,
              seatsController: _seatsController,
              priceController: _priceController,
              vehicleController: _vehicleController,
              notesController: _notesController,
              isRegularRide: _isRegularRide,
              onRegularRideChanged: (value) {
                setState(() {
                  _isRegularRide = value;
                });
              },
              onSelectDate: _selectDate,
              onSelectTime: _selectTime,
            ),
            const SizedBox(height: 24),
            
            // --- 2. LA PRÉVISUALISATION ---
            _buildPreviewCard(),
            const SizedBox(height: 24),

            // --- 3. LE BOUTON PUBLIER ---
            ElevatedButton(
              onPressed: () {
                // TODO: Logique de publication
                // if (_formKey.currentState!.validate()) { ... }
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
                'Publier le trajet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget privé pour la carte de PRÉVISUALISATION
  // (On le garde ici, car il dépend des contrôleurs de cet écran)
  Widget _buildPreviewCard() {
    // On met des valeurs par défaut si les champs sont vides
    String departure = _departureController.text.isEmpty ? 'Départ' : _departureController.text;
    String arrival = _arrivalController.text.isEmpty ? 'Arrivée' : _arrivalController.text;
    String date = _dateController.text;
    String time = _timeController.text;
    String seats = _seatsController.text.isEmpty ? '0' : _seatsController.text;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prévisualisation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Voici comment votre trajet apparaîtra aux autres utilisateurs',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$departure → $arrival',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$date · $time · $seats places disponibles',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on DateTime? {
  get day => null;
  
  get year => null;
  
  get month => null;
}

