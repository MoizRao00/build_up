import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/provider/notification_provider.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/native_health_service.dart';
import '../../../../core/services/widget_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
class StepState {
  final int currentSteps;
  final int goalSteps;
  final double calories;
  final double distanceKm;
  final bool isRestMode;
  final String pedestrianStatus;
  final int coins;
  final List<int> weeklySteps;

  const StepState({
    required this.currentSteps,
    required this.goalSteps,
    required this.calories,
    required this.distanceKm,
    required this.isRestMode,
    this.pedestrianStatus = 'stopped',
    this.coins = 0,
    this.weeklySteps = const [0, 0, 0, 0, 0, 0, 0],
  });

  String get activeDuration {
    final totalMinutes = currentSteps ~/ 100;

    if (totalMinutes < 60) {
      return '$totalMinutes min';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  StepState copyWith({
    int? currentSteps,
    int? goalSteps,
    double? calories,
    double? distanceKm,
    bool? isRestMode,
    String? pedestrianStatus,
    int? coins,
    List<int>? weeklySteps,
  }) {
    return StepState(
      currentSteps: currentSteps ?? this.currentSteps,
      goalSteps: goalSteps ?? this.goalSteps,
      calories: calories ?? this.calories,
      distanceKm: distanceKm ?? this.distanceKm,
      isRestMode: isRestMode ?? this.isRestMode,
      pedestrianStatus: pedestrianStatus ?? this.pedestrianStatus,
      coins: coins ?? this.coins,
      weeklySteps: weeklySteps ?? this.weeklySteps,

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
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month}-${now.day}';
    final lastDate = storage.getLastDate();

    // If it's a new day, start at 0 steps
    int displaySteps = 0;
    if (lastDate == dateStr) {
      displaySteps = storage.getSteps();
    } else {
      // Don't save yet, wait for initialization to confirm new baseline
    }

    final savedCoins = storage.getCoins();

    String weeklyData = storage.getWeeklySteps();

    List<int> loadedWeeklySteps = weeklyData.split(',').map((e) => int.tryParse(e) ?? 0).toList();

    if (loadedWeeklySteps.length != 7) loadedWeeklySteps = [0, 0, 0, 0, 0, 0, 0];

    return StepState(
      currentSteps: displaySteps,
      goalSteps: 10000,
      calories: displaySteps * 0.04,
      distanceKm: displaySteps * 0.00075,
      isRestMode: false,
      coins: savedCoins,
      weeklySteps: loadedWeeklySteps,
    );
  }

  Future<void> initializeTracking() async {
    _health.configure();
    final types = [HealthDataType.STEPS];

    bool hasPermissions = await _health.hasPermissions(types) ?? false;
    if (!hasPermissions) {
      try {
        hasPermissions = await _health.requestAuthorization(types);
      } catch (e) {
        hasPermissions = false;
      }
    }

    if (hasPermissions) {
      await _fetchHealthData();

      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
        if (!state.isRestMode) {
          _fetchHealthData();
        }
      });
    } else {
      final activityStatus = await Permission.activityRecognition.request();

      if (activityStatus.isGranted) {
        await _fetchFallbackData();

        _pollingTimer?.cancel();
        _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
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
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      _processSteps(steps ?? 0, 'tracking');
    } catch (e) {
      await _fetchFallbackData();
    }
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
      storage.saveSteps(0);
      _lastSyncedSteps = 0;
    }

    int baseline = storage.getHardwareBaseline();

    if (baseline == 0) {
      storage.saveHardwareBaseline(hardwareSteps);
      baseline = hardwareSteps;
    }

    int todaySteps = hardwareSteps - baseline;

    if (todaySteps < 0) {
      int savedStepsToday = storage.getSteps();
      int accumulatedSteps = savedStepsToday + hardwareSteps;

      int newBaseline = hardwareSteps - accumulatedSteps;
      storage.saveHardwareBaseline(newBaseline);

      todaySteps = accumulatedSteps;
    }

    _processSteps(todaySteps, 'fallback');
  }

  void _processSteps(int todaySteps, String trackingStatus) {
    final storage = ref.read(storageProvider);
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month}-${now.day}';
    String lastDate = storage.getLastDate();

    // 1. Handle New Day Rollover Variables
    if (lastDate != dateStr) {
      storage.saveLastDate(dateStr);
      storage.saveLastCoinStep(0);
      storage.saveGoalNotified(false);
    }

    // Failsafe for rogue sensor data
    if (todaySteps < 0) todaySteps = 0;

    // 2. Process Coins and Notifications
    int lastCoinStep = storage.getLastCoinStep();
    int currentCoins = storage.getCoins();

    if (todaySteps >= lastCoinStep + 100) {
      int newCoins = (todaySteps - lastCoinStep) ~/ 100;
      currentCoins += newCoins;
      storage.saveCoins(currentCoins);
      storage.saveLastCoinStep(lastCoinStep + (newCoins * 100));
    }

    bool hasNotified = storage.getGoalNotified();
    if (todaySteps >= state.goalSteps && !hasNotified) {
      ref.read(notificationServiceProvider).showGoalReached(todaySteps);
      storage.saveGoalNotified(true);
    }


    _updateLeaderboardScore(todaySteps);

    String weeklyData = storage.getWeeklySteps();
    List<int> weekly = weeklyData.split(',').map((e) => int.tryParse(e) ?? 0).toList();
    if (weekly.length != 7) weekly = [0, 0, 0, 0, 0, 0, 0];


    weekly[now.weekday - 1] = todaySteps;

    storage.saveWeeklySteps(weekly.join(','));

    state = state.copyWith(
      currentSteps: todaySteps,
      calories: todaySteps * 0.04,
      distanceKm: todaySteps * 0.00075,
      coins: currentCoins,
      pedestrianStatus: trackingStatus,
      weeklySteps: weekly,
    );

    storage.saveSteps(todaySteps);
    ref.read(widgetServiceProvider).updateWidgetData(todaySteps, state.goalSteps);
  }

  void _updateLeaderboardScore(int todaySteps) {
    final storage = ref.read(storageProvider);
    final now = DateTime.now();
    final currentMonth = now.month;

    int savedMonth = storage.getSavedMonth();

    if (currentMonth != savedMonth) {
      storage.saveSavedMonth(currentMonth);
      storage.saveMonthlyHighScore(0);
      _syncHighScoreToFirestore(0);
    }

    int highScore = storage.getMonthlyHighScore();

    if (todaySteps > highScore) {
      storage.saveMonthlyHighScore(todaySteps);
      _syncHighScoreToFirestore(todaySteps);
    }
  }

  void _syncHighScoreToFirestore(int score) {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'monthlyHighScore': score,
        'lastUpdated': FieldValue.serverTimestamp(),
      }).catchError((error) {
        print('Firestore sync failed: $error');
      });
    }
  }

  void _syncStepsToFirestore(int steps) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'totalSteps': steps,
        'lastUpdate': FieldValue.serverTimestamp(),
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