import 'package:cloud_firestore/cloud_firestore.dart';

enum Severity { critical, high, medium, low }

class AlertModel {
  final String id;
  final String type;
  final String description;
  final String location;
  final Severity severity;
  final GeoPoint coordinates;
  final DateTime timestamp;
  final String? imageUrl;
  final String userId;

  AlertModel({
    required this.id,
    required this.type,
    required this.description,
    required this.location,
    required this.severity,
    required this.coordinates,
    required this.timestamp,
    this.imageUrl,
    required this.userId,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? 'Ubicación actual',
      severity: Severity.values.firstWhere(
        (e) => e.name == data['severity'],
        orElse: () => Severity.medium,
      ),
      coordinates: data['coordinates'] as GeoPoint,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type,
    'description': description,
    'location': location,
    'severity': severity.name,
    'coordinates': coordinates,
    'timestamp': Timestamp.fromDate(timestamp),
    'imageUrl': imageUrl,
    'userId': userId,
  };

  String get severityLabel {
    switch (severity) {
      case Severity.critical: return 'CRÍTICO';
      case Severity.high:     return 'ALTO';
      case Severity.medium:   return 'MEDIO';
      case Severity.low:      return 'BAJO';
    }
  }
}
