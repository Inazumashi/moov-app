// File: lib/widgets/star_rating.dart
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color color;
  final bool showNumber;
  final TextStyle? textStyle;

  const StarRating({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 20,
    this.color = Colors.amber,
    this.showNumber = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Étoiles
        ...List.generate(starCount, (index) {
          final starValue = index + 1;
          IconData icon;

          if (rating >= starValue) {
            icon = Icons.star;
          } else if (rating >= starValue - 0.5) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }

          return Icon(
            icon,
            size: size,
            color: color,
          );
        }),
        // Nombre
        if (showNumber) ...[
          SizedBox(width: size * 0.3),
          Text(
            rating.toStringAsFixed(1),
            style: textStyle ??
                TextStyle(
                  fontSize: size * 0.8,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
          ),
        ],
      ],
    );
  }
}
