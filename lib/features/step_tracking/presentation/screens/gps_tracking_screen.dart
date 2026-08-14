import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/gps_route_provider.dart';

import '../widgets/glass_step_card.dart';

class GpsTrackingScreen extends ConsumerWidget {
  const GpsTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpsState = ref.watch(gpsRouteProvider);
    final centerPoint = gpsState.routePoints.isNotEmpty
        ? gpsState.routePoints.last
        : const LatLng(30.8138, 73.4534);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: centerPoint,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.buildup',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: gpsState.routePoints,
                    strokeWidth: 4.5,
                    color: AppColors.primaryEmerald,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (gpsState.routePoints.isNotEmpty)
                    Marker(
                      point: gpsState.routePoints.last,
                      width: 16,
                      height: 16,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryEmerald,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      ),
                      const Text(
                        'OUTDOOR TRACKER',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  (gpsState.distanceMeters / 1000).toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'Kilometers',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  (gpsState.currentSpeed * 3.6).toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'Speed (km/h)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (gpsState.isTracking) {
                              ref.read(gpsRouteProvider.notifier).stopTracking();
                            } else {
                              ref.read(gpsRouteProvider.notifier).startTracking();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gpsState.isTracking
                                ? Colors.redAccent
                                : AppColors.primaryEmerald,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            gpsState.isTracking ? 'Pause Tracking' : 'Start Route',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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