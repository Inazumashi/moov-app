import 'package:flutter/material.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/features/publish/widgets/publish_ride_form.dart';
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
    _selectedDate = DateTime.now().add(Duration(days: 1));
    _dateController.text = _formatDate(_selectedDate!);

    // Initialiser l'heure par défaut (8h00)
    _selectedTime = TimeOfDay(hour: 8, minute: 0);
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
      lastDate: DateTime.now().add(Duration(days: 365)),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérifier que les stations sont sélectionnées
    if (_departureController.text.isEmpty || _arrivalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Veuillez sélectionner les stations de départ et d\'arrivée'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier que la date et l'heure sont sélectionnées
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner la date et l\'heure'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);

      // Combiner date et heure
      final departureTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Créer le modèle de trajet
      final ride = RideModel(
        driverId: '', // Le backend remplira avec l'ID du conducteur
        startPoint: _departureController.text,
        endPoint: _arrivalController.text,
        departureTime: departureTime,
        availableSeats: int.parse(_seatsController.text),
        pricePerSeat: double.parse(_priceController.text),
        vehicleInfo: _vehicleController.text,
        notes: _notesController.text,
        isRegularRide: _isRegularRide,
      );

      // Publier le trajet
      final success = await rideProvider.publishRide(ride);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trajet publié avec succès!'),
            backgroundColor: Colors.green,
          ),
        );

        // Vider le formulaire
        _clearForm();

        // Retourner à l'écran précédent
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${rideProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _departureController.clear();
    _arrivalController.clear();

    // Réinitialiser la date (demain)
    _selectedDate = DateTime.now().add(Duration(days: 1));
    _dateController.text = _formatDate(_selectedDate!);

    // Réinitialiser l'heure (8h00)
    _selectedTime = TimeOfDay(hour: 8, minute: 0);
    _timeController.text = _formatTime(_selectedTime!);

    // Réinitialiser les autres champs
    _seatsController.text = '4';
    _priceController.text = '20';
    _vehicleController.clear();
    _notesController.clear();
    _isRegularRide = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publier un trajet'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearForm,
            tooltip: 'Effacer le formulaire',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
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
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Remplissez les informations de votre trajet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),

              // Utiliser le PublishRideForm avec toutes les variables nécessaires
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

              SizedBox(height: 24),

              // Bouton de publication
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
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Icon(Icons.send),
                  label: Text(_isLoading
                      ? 'Publication en cours...'
                      : 'Publier le trajet'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Informations supplémentaires
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Conseils de publication',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Sélectionnez les stations dans la liste pour faciliter la recherche\n'
                        '• Les trajets publiés apparaîtront dans les résultats de recherche\n'
                        '• Vous pouvez modifier ou annuler votre trajet plus tard',
                        style: TextStyle(fontSize: 14),
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
