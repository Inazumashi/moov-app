// File: lib/features/search/widgets/search_filters_sheet.dart
import 'package:flutter/material.dart';

class SearchFiltersSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  
  const SearchFiltersSheet({
    super.key,
    required this.onFiltersChanged,
  });

  @override
  State<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends State<SearchFiltersSheet> {
  int _minSeats = 1;
  double _maxPrice = 100.0;
  bool _onlyPremium = false;
  bool _onlyAvailable = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: colors.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filtres de recherche',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          // Places minimales
          Row(
            children: [
              Icon(Icons.people, size: 20, color: colors.onSurface.withOpacity(0.7)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Places disponibles : $_minSeats+',
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Slider(
                      value: _minSeats.toDouble(),
                      min: 1,
                      max: 7,
                      divisions: 6,
                      onChanged: (value) {
                        setState(() {
                          _minSeats = value.toInt();
                        });
                        _applyFilters();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Prix maximum
          Row(
            children: [
              Icon(Icons.attach_money, size: 20, color: colors.onSurface.withOpacity(0.7)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prix max : ${_maxPrice.toInt()} DH',
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Slider(
                      value: _maxPrice,
                      min: 20,
                      max: 200,
                      divisions: 9,
                      onChanged: (value) {
                        setState(() {
                          _maxPrice = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Options booléennes
          Column(
            children: [
              SwitchListTile(
                title: Text(
                  'Conducteurs Premium uniquement',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface,
                  ),
                ),
                value: _onlyPremium,
                onChanged: (value) {
                  setState(() {
                    _onlyPremium = value;
                  });
                  _applyFilters();
                },
                dense: true,
              ),
              SwitchListTile(
                title: Text(
                  'Trajets disponibles uniquement',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface,
                  ),
                ),
                value: _onlyAvailable,
                onChanged: (value) {
                  setState(() {
                    _onlyAvailable = value;
                  });
                  _applyFilters();
                },
                dense: true,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _minSeats = 1;
                    _maxPrice = 100.0;
                    _onlyPremium = false;
                    _onlyAvailable = true;
                  });
                  _applyFilters();
                },
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    widget.onFiltersChanged({
      'minSeats': _minSeats,
      'maxPrice': _maxPrice,
      'onlyPremium': _onlyPremium,
      'onlyAvailable': _onlyAvailable,
    });
  }
}