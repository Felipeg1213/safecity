class AppConstants {
  static const String appName = 'SafeCity';

  // Google Maps
  static const String googleMapsApiKey = 'TU_API_KEY_AQUI';

  // Backend
  static const String backendBaseUrl = 'http://TU_IP:5000';

  // Densidad poblacional - umbrales
  static const int densityCritical = 100;
  static const int densityHigh     = 50;
  static const int densityMedium   = 20;

  // Radio de búsqueda por defecto (km)
  static const double defaultRadius = 0.5;

  // Tipos de incidente
  static const List<String> incidentTypes = [
    'Robo',
    'Accidente',
    'Inundación',
    'Vandalismo',
    'Animal en vía pública',
    'Congestión',
    'Otro',
  ];

  // Estilo mapa oscuro
  static const String darkMapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#0a0d12"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#4a5568"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#0a0d12"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1c2230"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#1c2230"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#060810"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]}
  ]''';
}
