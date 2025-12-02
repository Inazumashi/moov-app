import 'package:flutter/material.dart';
import 'package:moovapp/core/service/ride_service.dart';
import 'package:moovapp/core/models/ride_model.dart';
import '../widgets/publish_ride_form.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final _formKey = GlobalKey<FormState>();

  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _seatsController = TextEditingController(text: '3');
  final _priceController = TextEditingController(text: '50');
  final _vehicleController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isRegularRide = false;
  bool _isLoading = false;

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

  Future<void> _selectDate() async {
    final theme = Theme.of(context);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _dateController.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() {});
    }
  }

  Future<void> _selectTime() async {
    final theme = Theme.of(context);
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _timeController.text = picked.format(context);
      setState(() {});
    }
  }

  Future<void> _publishRide() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Convertir date et heure en DateTime
      final dateParts = _dateController.text.split('/');
      final timeParts = _timeController.text.split(':');

      final departureDateTime = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final ride = RideModel(
        rideId: '', // backend génère l'ID
        driverId: '', // à remplacer par l'ID de l'utilisateur connecté
        driverName: '', // optionnel, backend peut remplir
        driverRating: 0.0,
        startPoint: _departureController.text,
        endPoint: _arrivalController.text,
        departureTime: departureDateTime,
        availableSeats: int.tryParse(_seatsController.text) ?? 0,
        pricePerSeat: double.tryParse(_priceController.text) ?? 0.0,
        vehicleInfo: _vehicleController.text,
        notes: _notesController.text,
        isRegularRide: _isRegularRide,
      );

      await RideService().publishRide(ride);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trajet publié avec succès !')),
      );

      _formKey.currentState!.reset();
      setState(() => _isRegularRide = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la publication: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Publier un trajet',
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(color: colors.onPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Partagez votre trajet avec la communauté',
                style: TextStyle(
                  color: colors.onPrimary.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        toolbarHeight: 90,
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            _buildPreviewCard(colors),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _publishRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Publier le trajet',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ColorScheme colors) {
    String departure = _departureController.text.isEmpty
        ? 'Départ'
        : _departureController.text;
    String arrival =
        _arrivalController.text.isEmpty ? 'Arrivée' : _arrivalController.text;
    String date = _dateController.text;
    String time = _timeController.text;
    String seats = _seatsController.text.isEmpty ? '0' : _seatsController.text;

    return Card(
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prévisualisation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Voici comment votre trajet apparaîtra aux autres utilisateurs',
              style: TextStyle(
                color: colors.onSurface.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outline.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$departure → $arrival',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$date · $time · $seats places disponibles',
                          style: TextStyle(
                            color: colors.onSurface.withOpacity(0.7),
                            fontSize: 13,
                          ),
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
