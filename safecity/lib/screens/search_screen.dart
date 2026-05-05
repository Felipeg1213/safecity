import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/bottom_nav.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  final List<Map<String, dynamic>> _recent = [
    {
      'name': 'Estación Transmilenio Av. Jiménez',
      'sub': 'Centro · 0.8 km',
      'icon': Icons.directions_bus_rounded,
      'color': Color(0xFF1565C0),
    },
    {
      'name': 'Centro Comercial Andino',
      'sub': 'Zona Rosa · 2.1 km',
      'icon': Icons.local_mall_rounded,
      'color': Color(0xFFAD1457),
    },
    {
      'name': 'Hospital Santa Clara',
      'sub': 'Restrepo · 3.4 km',
      'icon': Icons.local_hospital_rounded,
      'color': Color(0xFFB71C1C),
    },
    {
      'name': 'Parque El Virrey',
      'sub': 'Chico · 1.6 km',
      'icon': Icons.park_rounded,
      'color': Color(0xFF1B5E20),
    },
    {
      'name': 'Universidad Nacional',
      'sub': 'Teusaquillo · 4.2 km',
      'icon': Icons.school_rounded,
      'color': Color(0xFF4A148C),
    },
  ];

  final Set<int> _favorites = {};
  String _query = '';

  List<Map<String, dynamic>> get _filtered => _query.isEmpty
      ? _recent
      : _recent
          .where((r) =>
              (r['name'] as String)
                  .toLowerCase()
                  .contains(_query.toLowerCase()) ||
              (r['sub'] as String)
                  .toLowerCase()
                  .contains(_query.toLowerCase()))
          .toList();

  @override
  void dispose() {
    _ctrl.dispose();
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
        title: const Text('Buscar Ubicación'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Barra de búsqueda
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Ingresa una dirección o lugar...',
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.severityCritical,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add,
                      color: AppTheme.bgPrimary, size: 24),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              _query.isEmpty ? 'BÚSQUEDAS RECIENTES' : 'RESULTADOS',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Lista de ubicaciones
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron resultados',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final item = _filtered[i];
                        final originalIndex = _recent.indexOf(item);
                        final isFav = _favorites.contains(originalIndex);

                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppTheme.border),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (item['color'] as Color)
                                    .withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: item['color'] as Color,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              item['name'],
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              item['sub'],
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isFav
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: isFav
                                    ? AppTheme.severityMedium
                                    : AppTheme.textMuted,
                                size: 22,
                              ),
                              onPressed: () => setState(() {
                                isFav
                                    ? _favorites.remove(originalIndex)
                                    : _favorites.add(originalIndex);
                              }),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeCityBottomNav(
        currentIndex: 3,
        onTap: (i) {
          switch (i) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/alerts');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/report');
              break;
          }
        },
      ),
    );
  }
}
