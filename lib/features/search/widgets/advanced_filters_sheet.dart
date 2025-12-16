import 'package:flutter/material.dart';

class AdvancedFiltersSheet extends StatefulWidget {
  final VoidCallback onApply;
  final Map<String, dynamic> currentFilters;

  const AdvancedFiltersSheet({
    super.key,
    required this.onApply,
    required this.currentFilters,
  });

  @override
  State<AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<AdvancedFiltersSheet> {
  late RangeValues _priceRange;
  late RangeValues _seatsRange;
  late RangeValues _ratingRange;
  late TimeOfDay _departureTime;
  late TimeOfDay _arrivalTime;
  bool _flexibleTime = false;
  bool _directRideOnly = false;
  bool _womenOnly = false;
  bool _petsAllowed = false;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    _priceRange = RangeValues(
      (widget.currentFilters['minPrice'] ?? 0.0).toDouble(),
      (widget.currentFilters['maxPrice'] ?? 100.0).toDouble(),
    );
    _seatsRange = RangeValues(
      (widget.currentFilters['minSeats'] ?? 1.0).toDouble(),
      (widget.currentFilters['maxSeats'] ?? 5.0).toDouble(),
    );
    _ratingRange = RangeValues(
      (widget.currentFilters['minRating'] ?? 1.0).toDouble(),
      (widget.currentFilters['maxRating'] ?? 5.0).toDouble(),
    );
    _departureTime = TimeOfDay.fromDateTime(
      DateTime.parse(widget.currentFilters['departureTime'] ?? '2024-01-01 06:00'),
    );
    _arrivalTime = TimeOfDay.fromDateTime(
      DateTime.parse(widget.currentFilters['arrivalTime'] ?? '2024-01-01 23:00'),
    );
    _flexibleTime = widget.currentFilters['flexibleTime'] ?? false;
    _directRideOnly = widget.currentFilters['directRideOnly'] ?? false;
    _womenOnly = widget.currentFilters['womenOnly'] ?? false;
    _petsAllowed = widget.currentFilters['petsAllowed'] ?? false;
  }

  void _applyFilters() {
    final filters = {
      'minPrice': _priceRange.start,
      'maxPrice': _priceRange.end,
      'minSeats': _seatsRange.start.toInt(),
      'maxSeats': _seatsRange.end.toInt(),
      'minRating': _ratingRange.start,
      'maxRating': _ratingRange.end,
      'departureTime': _departureTime,
      'arrivalTime': _arrivalTime,
      'flexibleTime': _flexibleTime,
      'directRideOnly': _directRideOnly,
      'womenOnly': _womenOnly,
      'petsAllowed': _petsAllowed,
    };

    Navigator.pop(context, filters);
    widget.onApply();
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 100);
      _seatsRange = const RangeValues(1, 5);
      _ratingRange = const RangeValues(1, 5);
      _departureTime = const TimeOfDay(hour: 6, minute: 0);
      _arrivalTime = const TimeOfDay(hour: 23, minute: 0);
      _flexibleTime = false;
      _directRideOnly = false;
      _womenOnly = false;
      _petsAllowed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtres avancés',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prix
                      _buildSectionTitle('Prix (€)', colors),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        labels: RangeLabels(
                          _priceRange.start.toStringAsFixed(0),
                          _priceRange.end.toStringAsFixed(0),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() => _priceRange = values);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Places
                      _buildSectionTitle('Places disponibles', colors),
                      RangeSlider(
                        values: _seatsRange,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        labels: RangeLabels(
                          _seatsRange.start.toInt().toString(),
                          _seatsRange.end.toInt().toString(),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() => _seatsRange = values);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Note du conducteur
                      _buildSectionTitle('Note du conducteur', colors),
                      RangeSlider(
                        values: _ratingRange,
                        min: 1,
                        max: 5,
                        divisions: 8,
                        labels: RangeLabels(
                          _ratingRange.start.toStringAsFixed(1),
                          _ratingRange.end.toStringAsFixed(1),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() => _ratingRange = values);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Horaires
                      _buildSectionTitle('Horaires', colors),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeSelector(
                              'Départ',
                              _departureTime,
                              (time) => setState(() => _departureTime = time),
                              colors,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimeSelector(
                              'Arrivée',
                              _arrivalTime,
                              (time) => setState(() => _arrivalTime = time),
                              colors,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Flexibilité
                      CheckboxListTile(
                        title: const Text('Horaire flexible (±30 min)'),
                        value: _flexibleTime,
                        onChanged: (value) {
                          setState(() => _flexibleTime = value ?? false);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),

                      // Direct seulement
                      CheckboxListTile(
                        title: const Text('Trajets directs uniquement'),
                        value: _directRideOnly,
                        onChanged: (value) {
                          setState(() => _directRideOnly = value ?? false);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),

                      // Femmes seulement
                      CheckboxListTile(
                        title: const Text('Femmes seulement'),
                        value: _womenOnly,
                        onChanged: (value) {
                          setState(() => _womenOnly = value ?? false);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),

                      // Animaux autorisés
                      CheckboxListTile(
                        title: const Text('Animaux autorisés'),
                        value: _petsAllowed,
                        onChanged: (value) {
                          setState(() => _petsAllowed = value ?? false);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        child: const Text('Réinitialiser'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _applyFilters,
                        child: const Text('Appliquer'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
    ColorScheme colors,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
