import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/pedometer_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/widget_service.dart';

class StepState {
  final int currentSteps;
  final int goalSteps;
  final double calories;
  final double distanceKm;
  final bool isRestMode;
  final String pedestrianStatus;
  final int coins;

  const StepState({
    required this.currentSteps,
    required this.goalSteps,
    required this.calories,
    required this.distanceKm,
    required this.isRestMode,
    this.pedestrianStatus = 'stopped',
    this.coins = 0,
  });

  String get activeDuration {
    final totalMinutes = currentSteps ~/ 100;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  StepState copyWith({
    int? currentSteps,
    int? goalSteps,
    double? calories,
    double? distanceKm,
    bool? isRestMode,
    String? pedestrianStatus,
    int? coins,
  }) {
    return StepState(
      currentSteps: currentSteps ?? this.currentSteps,
      goalSteps: goalSteps ?? this.goalSteps,
      calories: calories ?? this.calories,
      distanceKm: distanceKm ?? this.distanceKm,
      isRestMode: isRestMode ?? this.isRestMode,
      pedestrianStatus: pedestrianStatus ?? this.pedestrianStatus,
      coins: coins ?? this.coins,
    );
  }
}
final storageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final pedometerServiceProvider = Provider<PedometerService>((ref) {
  return PedometerService();
});

final widgetServiceProvider = Provider<WidgetService>((ref) {
  return WidgetService();
});

final stepNotifierProvider = NotifierProvider<StepNotifier, StepState>(StepNotifier.new);

class StepNotifier extends Notifier<StepState> {
  @override
  StepState build() {
    final storage = ref.watch(storageProvider);
    final savedSteps = storage.getSteps();
    final savedCoins = storage.getCoins();

    return StepState(
      currentSteps: savedSteps,
      goalSteps: 10000,
      calories: savedSteps * 0.04,
      distanceKm: savedSteps * 0.00075,
      isRestMode: false,
      coins: savedCoins,
    );
  }



  Future<void> initializeTracking() async {
    final permissionStatus = await Permission.activityRecognition.request();

    if (permissionStatus.isGranted) {
      final service = ref.read(pedometerServiceProvider);
      final storage = ref.read(storageProvider);
      final widgetService = ref.read(widgetServiceProvider);

      widgetService.init();

      service.startTracking(
        onStepCount: (totalDeviceSteps) {
          if (state.isRestMode) return;

          final now = DateTime.now();
          final dateStr = '${now.year}-${now.month}-${now.day}';
          String lastDate = storage.getLastDate();
          int baseline = storage.getBaselineSteps();

          if (lastDate != dateStr) {
            baseline = totalDeviceSteps;
            storage.saveBaselineSteps(baseline);
            storage.saveLastDate(dateStr);
            storage.saveLastCoinStep(0);
          }

          int todaySteps = totalDeviceSteps - baseline;

          if (todaySteps < 0) {
            baseline = 0;
            storage.saveBaselineSteps(0);
            todaySteps = totalDeviceSteps;
          }

          int lastCoinStep = storage.getLastCoinStep();
          int currentCoins = storage.getCoins();

          if (todaySteps >= lastCoinStep + 100) {
            int newCoins = (todaySteps - lastCoinStep) ~/ 100;
            currentCoins += newCoins;
            storage.saveCoins(currentCoins);
            storage.saveLastCoinStep(lastCoinStep + (newCoins * 100));
          }

          state = state.copyWith(
            currentSteps: todaySteps,
            calories: todaySteps * 0.04,
            distanceKm: todaySteps * 0.00075,
            coins: currentCoins,
          );

          storage.saveSteps(todaySteps);
          widgetService.updateWidgetData(todaySteps, state.goalSteps);

          if (todaySteps % 10 == 0) {
            _syncStepsToFirestore(todaySteps);
          }
        },
        onStatusChanged: (status) {
          state = state.copyWith(pedestrianStatus: status);
        },
        onError: (error) {
          state = state.copyWith(pedestrianStatus: 'error');
        },
      );
    } else {
      state = state.copyWith(pedestrianStatus: 'Permission Denied');
    }
  }

  void _syncStepsToFirestore(int steps) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'totalSteps': steps,
      }).catchError((_) {});
    }
  }

  void toggleRestMode() {
    state = state.copyWith(isRestMode: !state.isRestMode);
  }
}