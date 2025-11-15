import 'package:flutter/material.dart';

class PublishRideForm extends StatelessWidget {
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
              const Text(
                'Détails du trajet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Champ Départ
              _buildTextField(
                controller: departureController,
                label: 'Lieu de départ',
                hint: 'Ex: Campus UM6P, Résidence...',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              
              // Champ Arrivée
              _buildTextField(
                controller: arrivalController,
                label: 'Destination',
                hint: 'Ex: Casa Voyageurs, Rabat...',
                icon: Icons.flag_outlined,
              ),
              const SizedBox(height: 12),
              
              // Date et Heure
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      controller: dateController,
                      label: 'Date',
                      onTap: onSelectDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      controller: timeController,
                      label: 'Heure',
                      onTap: onSelectTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Places et Prix
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: seatsController,
                      label: 'Places disponibles',
                      hint: '3',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: priceController,
                      label: 'Prix (DH)',
                      hint: '50',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Véhicule
              _buildTextField(
                controller: vehicleController,
                label: 'Véhicule (optionnel)',
                hint: 'Ex: Renault Clio, Gris...',
                icon: Icons.directions_car_outlined,
              ),
              const SizedBox(height: 12),
              
              // Trajet régulier
              Row(
                children: [
                  const Text(
                    'Trajet régulier',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Switch(
                    value: isRegularRide,
                    onChanged: onRegularRideChanged,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Notes
              _buildTextField(
                controller: notesController,
                label: 'Notes (optionnel)',
                hint: 'Précisions sur le point de rencontre...',
                maxLines: 3,
                icon: Icons.note_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: IgnorePointer(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Sélectionner',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}