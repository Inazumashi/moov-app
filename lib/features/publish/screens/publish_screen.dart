// lib/features/publish/screens/publish_screen.dart - VERSION CORRIGÉE
import 'package:flutter/material.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/features/publish/widgets/publish_ride_form.dart';
import 'package:moovapp/features/main_navigation/main_navigation_shell.dart';
import 'package:provider/provider.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({Key? key}) : super(key: key);

  @override
  _PublishScreenState createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  // Déclaration de toutes les variables nécessaires
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _seatsController =
      TextEditingController(text: '4');
  final TextEditingController _priceController =
      TextEditingController(text: '20');
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isRegularRide = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialiser la date par défaut (demain)
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _dateController.text = _formatDate(_selectedDate!);

    // Initialiser l'heure par défaut (8h00)
    _selectedTime = const TimeOfDay(hour: 8, minute: 0);
    _timeController.text = _formatTime(_selectedTime!);
  }

  @override
  void dispose() {
    // Nettoyer tous les contrôleurs
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _formatTime(picked);
      });
    }
  }

  Future<void> _publishRide() async {
    // ✅ Validation du formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ✅ Vérifier que les stations sont sélectionnées
    if (_departureController.text.isEmpty || _arrivalController.text.isEmpty) {
      _showSnackBar(
        'Veuillez sélectionner les stations de départ et d\'arrivée',
        isError: true,
      );
      return;
    }

    // ✅ Vérifier que la date et l'heure sont sélectionnées
    if (_selectedDate == null || _selectedTime == null) {
      _showSnackBar(
        'Veuillez sélectionner la date et l\'heure',
        isError: true,
      );
      return;
    }

    // ✅ Démarrer le chargement
    setState(() {
      _isLoading = true;
    });

    try {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);

      // ✅ Combiner date et heure
      final departureTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // ✅ Créer le modèle de trajet
      final ride = RideModel(
        driverId: '', // Le backend remplira avec l'ID du conducteur
        startPoint: _departureController.text,
        endPoint: _arrivalController.text,
        departureTime: departureTime,
        availableSeats: int.parse(_seatsController.text),
        pricePerSeat: double.parse(_priceController.text),
        vehicleInfo:
            _vehicleController.text.isEmpty ? null : _vehicleController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isRegularRide: _isRegularRide,
      );

      // ✅ Publier le trajet
      final success = await rideProvider.publishRide(ride);

      // ✅ CRITIQUE : Vérifier que le widget existe encore après l'opération async
      if (!mounted) return;

      // ✅ Arrêter le chargement
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // ✅ Afficher le message de succès
        _showSnackBar(
          '🎉 Trajet publié avec succès !',
          isError: false,
        );

        // ✅ Vider le formulaire
        _clearForm();

        // ✅ Attendre un peu pour que l'utilisateur voie le message
        await Future.delayed(const Duration(milliseconds: 800));

        // ✅ CRITIQUE : Revérifier que le widget existe avant de naviguer
        if (!mounted) return;

        // 💡 Étape 1 : Chercher l'état du Shell de Navigation Parent
        final MainNavigationShellState? parentState =
            context.findAncestorStateOfType<MainNavigationShellState>();

        if (parentState != null) {
          // 💡 Étape 2 : L'état a été trouvé, on peut naviguer.
          // Index 0 = Accueil
          parentState.navigateTo(0);
          // Forcer le rechargement des trajets publiés pour que l'accueil affiche immédiatement le nouveau trajet
          final rideProv = Provider.of<RideProvider>(context, listen: false);
          await rideProv.loadMyPublishedRides();
        } else {
          // 💡 Étape 3 : Si l'état parent n'est pas trouvé (cause de l'écran blanc)
          // On affiche un message d'erreur clair dans la console
          print(
              '🚨 FATAL ERROR: MainNavigationShellState parent non trouvé. Impossible de changer d\'onglet vers l\'Accueil.');

          // Et on affiche un message d'erreur à l'utilisateur
          _showSnackBar(
            'Erreur de navigation après publication. Veuillez redémarrer l\'application.',
            isError: true,
          );
          // Vous pourriez choisir de ne rien faire pour éviter un crash, mais le message est essentiel.
        }
      } else {
        // ✅ Afficher l'erreur
        _showSnackBar(
          'Erreur: ${rideProvider.error}',
          isError: true,
        );
      }
    } catch (e) {
      // ✅ Gérer les erreurs inattendues
      print('❌ Erreur lors de la publication: $e');

      // ✅ Vérifier que le widget existe
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnackBar(
        'Erreur inattendue: ${e.toString()}',
        isError: true,
      );
    }
  }

  void _clearForm() {
    _departureController.clear();
    _arrivalController.clear();

    // Réinitialiser la date (demain)
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _dateController.text = _formatDate(_selectedDate!);

    // Réinitialiser l'heure (8h00)
    _selectedTime = const TimeOfDay(hour: 8, minute: 0);
    _timeController.text = _formatTime(_selectedTime!);

    // Réinitialiser les autres champs
    _seatsController.text = '4';
    _priceController.text = '20';
    _vehicleController.clear();
    _notesController.clear();
    _isRegularRide = false;

    setState(() {});
  }

  // ✅ Méthode helper pour afficher les SnackBars
  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier un trajet'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearForm,
            tooltip: 'Effacer le formulaire',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Nouveau trajet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Remplissez les informations de votre trajet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Formulaire
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
                onSelectDate: () => _selectDate(context),
                onSelectTime: () => _selectTime(context),
                onDepartureChanged: (value) {
                  // Logique si nécessaire
                },
                onArrivalChanged: (value) {
                  // Logique si nécessaire
                },
              ),

              const SizedBox(height: 24),

              // ✅ Bouton de publication avec gestion du chargement
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _publishRide,
                  icon: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(colors.onPrimary),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isLoading
                        ? 'Publication en cours...'
                        : 'Publier le trajet',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Informations supplémentaires
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[800]),
                          const SizedBox(width: 8),
                          Text(
                            'Conseils de publication',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Sélectionnez les stations dans la liste pour faciliter la recherche\n'
                        '• Les trajets publiés apparaîtront dans les résultats de recherche\n'
                        '• Vous pouvez modifier ou annuler votre trajet plus tard',
                        style: TextStyle(fontSize: 14, color: Colors.blue[900]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
