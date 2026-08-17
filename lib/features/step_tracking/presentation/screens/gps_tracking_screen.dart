import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/gps_tracking_provider.dart';
import '../widgets/glass_step_card.dart';

class GpsTrackingScreen extends ConsumerStatefulWidget {
  const GpsTrackingScreen({super.key});

  @override
  ConsumerState<GpsTrackingScreen> createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends ConsumerState<GpsTrackingScreen> {
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gpsTrackingProvider.notifier).checkPermissionAndStart();
    });
  }

  void _showSummaryDialog(double distanceMeters, Duration duration) {
    final distanceText = distanceMeters > 1000
        ? '${(distanceMeters / 1000).toStringAsFixed(2)} km'
        : '${distanceMeters.toStringAsFixed(0)} m';

    final timeText = '${duration.inMinutes}m ${duration.inSeconds % 60}s';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Text(
          'Workout Complete',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.straighten, color: AppColors.primaryEmerald, size: 30),
                    const SizedBox(height: 8),
                    Text(distanceText, style: const TextStyle(color: Colors.white, fontSize: 18)),
                    const Text('Distance', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.timer, color: AppColors.primaryEmerald, size: 30),
                    const SizedBox(height: 8),
                    Text(timeText, style: const TextStyle(color: Colors.white, fontSize: 18)),
                    const Text('Duration', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTracking() {
    final notifier = ref.read(gpsTrackingProvider.notifier);
    final state = ref.read(gpsTrackingProvider);

    if (state.isTracking) {
      double totalDistance = 0.0;
      final distanceCalc = const Distance();

      for (int i = 0; i < state.routePoints.length - 1; i++) {
        totalDistance += distanceCalc(
            state.routePoints[i],
            state.routePoints[i + 1]
        );
      }

      final duration = state.startTime != null
          ? DateTime.now().difference(state.startTime!)
          : Duration.zero;

      notifier.stopTracking();
      _showSummaryDialog(totalDistance, duration);
    } else {
      notifier.startTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GpsTrackingState>(gpsTrackingProvider, (previous, next) {
      if (_isMapReady && next.currentPosition != null) {
        final latLng = LatLng(
          next.currentPosition!.latitude,
          next.currentPosition!.longitude,
        );
        try {
          _mapController.move(latLng, 17.0);
        } catch (_) {}
      }
    });

    final trackingState = ref.watch(gpsTrackingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          trackingState.errorMessage != null
              ? Center(
            child: Text(
              trackingState.errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
          )
              : trackingState.currentPosition == null
              ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryEmerald,
            ),
          )
              : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                trackingState.currentPosition!.latitude,
                trackingState.currentPosition!.longitude,
              ),
              initialZoom: 17.0,
              onMapReady: () => setState(() => _isMapReady = true),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.build_up',
              ),
              if (trackingState.routePoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: trackingState.routePoints,
                      color: AppColors.primaryEmerald,
                      strokeWidth: 6,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      trackingState.currentPosition!.latitude,
                      trackingState.currentPosition!.longitude,
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.backgroundDark.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trackingState.isTracking
                        ? 'TRACKING ACTIVE'
                        : 'READY TO WALK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: trackingState.isTracking
                          ? AppColors.primaryEmerald
                          : AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _toggleTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: trackingState.isTracking
                            ? Colors.redAccent
                            : AppColors.primaryEmerald,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        trackingState.isTracking ? 'Stop Route' : 'Start Route',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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