import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/alert_model.dart';
import '../widgets/bottom_nav.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  int _currentIndex = 0;

  // Bogotá centro
  static const CameraPosition _bogota = CameraPosition(
    target: LatLng(4.6097, -74.0817),
    zoom: 12,
  );

  Set<Marker> _markers = {};
  StreamSubscription? _alertsSub;

  @override
  void initState() {
    super.initState();
    _listenToAlerts();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    await Geolocator.requestPermission();
  }

  void _listenToAlerts() {
    _alertsSub = FirebaseFirestore.instance
        .collection('alerts')
        .where(
          'timestamp',
          isGreaterThan: Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 24)),
          ),
        )
        .snapshots()
        .listen((snapshot) {
      final markers = snapshot.docs.map((doc) {
        final alert = AlertModel.fromFirestore(doc);
        return Marker(
          markerId: MarkerId(alert.id),
          position: LatLng(
            alert.coordinates.latitude,
            alert.coordinates.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _severityHue(alert.severity),
          ),
          infoWindow: InfoWindow(
            title: alert.type,
            snippet: alert.severityLabel,
          ),
        );
      }).toSet();

      if (mounted) setState(() => _markers = markers);
    });
  }

  double _severityHue(Severity s) {
    switch (s) {
      case Severity.critical: return BitmapDescriptor.hueRed;
      case Severity.high:     return BitmapDescriptor.hueOrange;
      case Severity.medium:   return BitmapDescriptor.hueYellow;
      case Severity.low:      return BitmapDescriptor.hueGreen;
    }
  }

  @override
  void dispose() {
    _alertsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _bogota,
            onMapCreated: (controller) {
              _controller.complete(controller);
              controller.setMapStyle(AppConstants.darkMapStyle);
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Header flotante
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FloatingIconButton(
                    icon: Icons.menu,
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  // Logo centro
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSecondary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined,
                            color: AppTheme.accent, size: 18),
                        const SizedBox(width: 6),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                            children: [
                              TextSpan(
                                  text: 'Safe',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary)),
                              TextSpan(
                                  text: 'City',
                                  style:
                                      TextStyle(color: AppTheme.accent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notificaciones
                  Stack(
                    children: [
                      _FloatingIconButton(
                        icon: Icons.notifications_outlined,
                        onPressed: () =>
                            Navigator.pushNamed(context, '/alerts'),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.severityCritical,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Botón mi ubicación
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _goToMyLocation,
              backgroundColor: AppTheme.bgSecondary,
              child: const Icon(Icons.my_location,
                  color: AppTheme.accent, size: 20),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeCityBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => _onNavTap(i, context),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    final position = await Geolocator.getCurrentPosition();
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
  }

  void _onNavTap(int i, BuildContext context) {
    setState(() => _currentIndex = i);
    switch (i) {
      case 1:
        Navigator.pushNamed(context, '/alerts');
        break;
      case 2:
        Navigator.pushNamed(context, '/report');
        break;
      case 3:
        Navigator.pushNamed(context, '/search');
        break;
    }
  }
}

class _FloatingIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _FloatingIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.bgSecondary.withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AppTheme.textPrimary, size: 22),
        ),
      ),
    );
  }
}
