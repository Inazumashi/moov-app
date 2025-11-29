import 'package:flutter/material.dart';

class ReservationFilter extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;
  final Map<String, int> stats;

  const ReservationFilter({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrer par statut:',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'Toutes (${stats['total'] ?? 0})'),
                _buildFilterChip('confirmed', 'Confirmées (${stats['confirmed'] ?? 0})'),
                _buildFilterChip('completed', 'Terminées (${stats['completed'] ?? 0})'),
                _buildFilterChip('cancelled', 'Annulées (${stats['cancelled'] ?? 0})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status, String label) {
    final isSelected = currentFilter == status;
    
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          onFilterChanged(status);
        },
        backgroundColor: isSelected ? Color(0xFF1E3A8A) : Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
        checkmarkColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}