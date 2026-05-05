import 'package:dio/dio.dart';
import '../core/constants.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.backendBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Registra la ubicación activa del usuario (ping cada N minutos)
  static Future<void> pingLocation({
    required String userId,
    required double lat,
    required double lng,
  }) async {
    try {
      await _dio.post('/ping', data: {
        'user_id': userId,
        'lat': lat,
        'lng': lng,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } on DioException catch (e) {
      // Fallo silencioso — el ping no debe interrumpir la UX
      print('Ping error: ${e.message}');
    }
  }

  /// Retorna densidad de usuarios en un radio dado
  static Future<Map<String, dynamic>> getDensity({
    required double lat,
    required double lng,
    double radiusKm = AppConstants.defaultRadius,
  }) async {
    final response = await _dio.get('/density', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius': radiusKm,
    });
    return response.data as Map<String, dynamic>;
  }

  /// Health check del backend
  static Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
