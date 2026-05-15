import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';

class KostMapScreen extends StatelessWidget {
  final double lat;
  final double lng;
  final String title;

  const KostMapScreen({
    super.key,
    required this.lat,
    required this.lng,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final targetPosition = LatLng(lat, lng);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: targetPosition,
              initialZoom: 16.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ngekoskiye',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: targetPosition,
                    width: 100,
                    height: 100,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LOKASI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const Icon(
                          Icons.circle,
                          color: AppColors.primary,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Material(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black26,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => context.pop(),
                tooltip: 'Kembali',
              ),
            ),
          ),

          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PETA LOKASI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
