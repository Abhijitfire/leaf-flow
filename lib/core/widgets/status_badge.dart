import 'package:flutter/material.dart';
import '../theme/color_schemes.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'active':
        bgColor = lightColorScheme.primaryContainer;
        textColor = lightColorScheme.onPrimaryContainer;
        break;
      case 'resting':
        bgColor = lightColorScheme.surfaceContainerHighest;
        textColor = lightColorScheme.onSurfaceVariant;
        break;
      case 'pruning':
        bgColor = lightColorScheme.tertiaryContainer;
        textColor = lightColorScheme.onTertiaryContainer;
        break;
      case 'severe':
      case 'critical':
        bgColor = lightColorScheme.errorContainer;
        textColor = lightColorScheme.onErrorContainer;
        break;
      default:
        bgColor = lightColorScheme.surfaceContainerHighest;
        textColor = lightColorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
