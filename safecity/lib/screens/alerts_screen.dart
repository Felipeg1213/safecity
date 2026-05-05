import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';
import '../models/alert_model.dart';
import '../widgets/alert_card.dart';
import '../widgets/bottom_nav.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Alertas Activas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .orderBy('timestamp', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            );
          }

          final alerts = snapshot.data?.docs
                  .map((d) => AlertModel.fromFirestore(d))
                  .toList() ??
              [];

          final counts = {
            Severity.critical:
                alerts.where((a) => a.severity == Severity.critical).length,
            Severity.high:
                alerts.where((a) => a.severity == Severity.high).length,
            Severity.medium:
                alerts.where((a) => a.severity == Severity.medium).length,
            Severity.low:
                alerts.where((a) => a.severity == Severity.low).length,
          };

          return Column(
            children: [
              // Tarjetas de resumen
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _SummaryCard(
                      count: counts[Severity.critical]!,
                      label: 'Críticas',
                      color: AppTheme.severityCritical,
                    ),
                    const SizedBox(width: 10),
                    _SummaryCard(
                      count: counts[Severity.high]!,
                      label: 'Altas',
                      color: AppTheme.severityHigh,
                    ),
                    const SizedBox(width: 10),
                    _SummaryCard(
                      count: counts[Severity.medium]!,
                      label: 'Medias',
                      color: AppTheme.severityMedium,
                    ),
                    const SizedBox(width: 10),
                    _SummaryCard(
                      count: counts[Severity.low]!,
                      label: 'Bajas',
                      color: AppTheme.severityLow,
                    ),
                  ],
                ),
              ),

              // Lista
              Expanded(
                child: alerts.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay alertas activas',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: alerts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            AlertCard(alert: alerts[i]),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeCityBottomNav(
        currentIndex: 1,
        onTap: (i) {
          switch (i) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/report');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/search');
              break;
          }
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
