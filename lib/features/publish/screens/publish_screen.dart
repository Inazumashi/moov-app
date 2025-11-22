import 'package:flutter/material.dart';
// Reste rouge jusqu’à ce que tu crées le fichier
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,

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
            // FORMULAIRE EXTERNE
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

            // PRÉVISUALISATION
            _buildPreviewCard(colors),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                // TODO: logique de publication
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
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

  Widget _buildPreviewCard(ColorScheme colors) {
    String departure =
        _departureController.text.isEmpty ? 'Départ' : _departureController.text;

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
                color: colors.surfaceVariant.withOpacity(0.2),
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
