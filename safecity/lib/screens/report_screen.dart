import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/alert_model.dart';
import '../widgets/bottom_nav.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Severity? _selectedSeverity;
  String? _selectedType;
  final _descCtrl = TextEditingController();
  File? _imageFile;
  bool _submitting = false;

  final List<Map<String, dynamic>> _severities = [
    {
      'label': 'Bajo',
      'value': Severity.low,
      'color': AppTheme.severityLow,
    },
    {
      'label': 'Medio',
      'value': Severity.medium,
      'color': AppTheme.severityMedium,
    },
    {
      'label': 'Alto',
      'value': Severity.high,
      'color': AppTheme.severityHigh,
    },
    {
      'label': 'Crítico',
      'value': Severity.critical,
      'color': AppTheme.severityCritical,
    },
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submitReport() async {
    if (_selectedSeverity == null ||
        _selectedType == null ||
        _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final position = await Geolocator.getCurrentPosition();
      final user = FirebaseAuth.instance.currentUser!;

      await FirebaseFirestore.instance.collection('alerts').add({
        'type': _selectedType,
        'description': _descCtrl.text,
        'location': 'Ubicación actual',
        'severity': _selectedSeverity!.name,
        'coordinates': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'imageUrl': null, // TODO: Firebase Storage
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte enviado correctamente'),
            backgroundColor: AppTheme.severityLow,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.severityCritical,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nuevo Reporte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severidad
            const Text('NIVEL DE SEVERIDAD', style: _labelStyle),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.5,
              children: _severities.map((s) {
                final selected = _selectedSeverity == s['value'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedSeverity = s['value']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected
                          ? (s['color'] as Color).withOpacity(0.2)
                          : AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? s['color'] as Color
                            : AppTheme.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: s['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          s['label'],
                          style: TextStyle(
                            color: selected
                                ? s['color'] as Color
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Text('TIPO DE INCIDENTE', style: _labelStyle),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedType,
              dropdownColor: AppTheme.bgCard2,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Seleccionar tipo...',
              ),
              items: AppConstants.incidentTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v),
            ),

            const SizedBox(height: 24),
            const Text('DESCRIPCIÓN DEL INCIDENTE', style: _labelStyle),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText:
                    'Describe el incidente con el mayor detalle posible...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),
            const Text('EVIDENCIA FOTOGRÁFICA', style: _labelStyle),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showImageOptions(context),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              color: AppTheme.textMuted, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Agregar foto o video',
                            style:
                                TextStyle(color: AppTheme.textMuted),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submitReport,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.bgPrimary,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Enviar Reporte'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: SafeCityBottomNav(
        currentIndex: 2,
        onTap: (i) {
          switch (i) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/alerts');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/search');
              break;
          }
        },
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: AppTheme.accent),
              title: const Text('Tomar foto',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: AppTheme.accent),
              title: const Text('Elegir de galería',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }
}

const _labelStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppTheme.textMuted,
  letterSpacing: 1.2,
);
