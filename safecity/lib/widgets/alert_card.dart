import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  const AlertCard({super.key, required this.alert});

  IconData get _icon {
    switch (alert.type.toLowerCase()) {
      case 'robo':
        return Icons.warning_amber_rounded;
      case 'accidente':
        return Icons.car_crash_rounded;
      case 'inundación':
        return Icons.water_drop_rounded;
      case 'vandalismo':
        return Icons.report_problem_rounded;
      case 'animal en vía pública':
        return Icons.pest_control_rounded;
      case 'congestión':
        return Icons.people_rounded;
      default:
        return Icons.bug_report_rounded;
    }
  }

  Color get _severityColor {
    switch (alert.severity) {
      case Severity.critical: return AppTheme.severityCritical;
      case Severity.high:     return AppTheme.severityHigh;
      case Severity.medium:   return AppTheme.severityMedium;
      case Severity.low:      return AppTheme.severityLow;
    }
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(alert.timestamp);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24)   return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono de categoría
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _severityColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _severityColor, size: 22),
          ),
          const SizedBox(width: 14),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.type,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  alert.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Badge severidad
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _severityColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    alert.severityLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tiempo
          Text(
            _timeAgo,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
