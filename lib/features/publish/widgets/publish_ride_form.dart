import 'package:flutter/material.dart';

class PublishRideForm extends StatelessWidget {
  // On déclare tous les paramètres qu'il reçoit
  final GlobalKey<FormState> formKey;
  final TextEditingController departureController;
  final TextEditingController arrivalController;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final TextEditingController seatsController;
  final TextEditingController priceController;
  final TextEditingController vehicleController;
  final TextEditingController notesController;
  final bool isRegularRide;
  final ValueChanged<bool> onRegularRideChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  const PublishRideForm({
    super.key,
    required this.formKey,
    required this.departureController,
    required this.arrivalController,
    required this.dateController,
    required this.timeController,
    required this.seatsController,
    required this.priceController,
    required this.vehicleController,
    required this.notesController,
    required this.isRegularRide,
    required this.onRegularRideChanged,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Switch Trajet Régulier ---
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Trajet régulier',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Tous les jours de la semaine',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  value: isRegularRide,
                  onChanged: onRegularRideChanged, // Appelle la fonction parent
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 16),

              // --- Champs de texte ---
              _buildTextField(
                controller: departureController,
                label: 'Point de départ',
                hint: 'Adresse de départ',
                icon: Icons.my_location,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: arrivalController,
                label: 'Point d\'arrivée',
                hint: 'Adresse d\'arrivée',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),

              // --- Date & Heure ---
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: dateController,
                      label: 'Date',
                      hint: 'jj/mm/aaaa',
                      icon: Icons.calendar_today,
                      isReadOnly: true,
                      onTap: onSelectDate, // Appelle la fonction parent
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: timeController,
                      label: 'Heure',
                      hint: '--:--',
                      icon: Icons.access_time,
                      isReadOnly: true,
                      onTap: onSelectTime, // Appelle la fonction parent
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Places & Prix ---
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: seatsController,
                      label: 'Places disponibles',
                      hint: '3',
                      icon: Icons.people,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: priceController,
                      label: 'Prix par place',
                      hint: '50',
                      icon: Icons.local_offer,
                      keyboardType: TextInputType.number,
                      prefixText: 'MAD ',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: vehicleController,
                label: 'Véhicule (optionnel)',
                hint: 'Dacia Logan - Blanche',
                icon: Icons.directions_car,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: notesController,
                label: 'Notes supplémentaires',
                hint: 'Informations complémentaires pour les passagers...',
                icon: Icons.note_alt,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper pour créer un champ de texte stylisé
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    bool isReadOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          // validator: (value) { ... }
        ),
      ],
    );
  }
}
