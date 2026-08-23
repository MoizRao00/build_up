import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/native_health_service.dart';
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

final widgetServiceProvider = Provider<WidgetService>((ref) {
  return WidgetService();
});

final stepNotifierProvider = NotifierProvider<StepNotifier, StepState>(StepNotifier.new);

final Health _health = Health();
class StepNotifier extends Notifier<StepState> {
  Timer? _pollingTimer;
  int _lastSyncedSteps = 0;

  @override
  StepState build() {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

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
    _health.configure();
    final types = [HealthDataType.STEPS];

    bool hasPermissions = await _health.hasPermissions(types) ?? false;
    if (!hasPermissions) {
      hasPermissions = await _health.requestAuthorization(types);
    }

    if (hasPermissions) {
      await _fetchHealthData();

      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (!state.isRestMode) {
          _fetchHealthData();
        }
      });
    } else {
      final activityStatus = await Permission.activityRecognition.request();

      if (activityStatus.isGranted) {
        await _fetchFallbackData();

        _pollingTimer?.cancel();
        _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
          if (!state.isRestMode) {
            _fetchFallbackData();
          }
        });
      } else {
        state = state.copyWith(pedestrianStatus: 'Permission Denied');
      }
    }
  }
  Future<void> _fetchHealthData() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    int? steps = await _health.getTotalStepsInInterval(midnight, now);

    _processSteps(steps ?? 0, 'tracking');
  }

  Future<void> _fetchFallbackData() async {
    final nativeHealth = ref.read(nativeHealthProvider);
    final hardwareSteps = await nativeHealth.getHardwareSteps();

    if (hardwareSteps == 0) return;

    final storage = ref.read(storageProvider);
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month}-${now.day}';
    String lastDate = storage.getLastDate();

    if (lastDate != dateStr) {
      storage.saveLastDate(dateStr);
      storage.saveHardwareBaseline(hardwareSteps);
      storage.saveLastCoinStep(0);
    }

    int baseline = storage.getHardwareBaseline();

    if (baseline == 0) {
      storage.saveHardwareBaseline(hardwareSteps);
      baseline = hardwareSteps;
    }

    int todaySteps = hardwareSteps - baseline;

    if (todaySteps < 0) {
      storage.saveHardwareBaseline(0);
      baseline = 0;
      todaySteps = hardwareSteps;
    }

    _processSteps(todaySteps, 'tracking_fallback');
  }
  void _processSteps(int todaySteps, String trackingStatus) {
    final storage = ref.read(storageProvider);
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month}-${now.day}';
    String lastDate = storage.getLastDate();

    if (lastDate != dateStr) {
      storage.saveLastDate(dateStr);
      storage.saveLastCoinStep(0);
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
      pedestrianStatus: trackingStatus,
    );

    storage.saveSteps(todaySteps);
    ref.read(widgetServiceProvider).updateWidgetData(todaySteps, state.goalSteps);

    if (todaySteps >= _lastSyncedSteps + 10) {
      _syncStepsToFirestore(todaySteps);
      _lastSyncedSteps = todaySteps;
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

  bool deductCoins(int amount) {
    final storage = ref.read(storageProvider);
    int currentCoins = storage.getCoins();

    if (currentCoins >= amount) {
      int newBalance = currentCoins - amount;
      storage.saveCoins(newBalance);
      state = state.copyWith(coins: newBalance);
      return true;
    }
    return false;
  }

}