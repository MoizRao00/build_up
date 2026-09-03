import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'app/app.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/native_health_service.dart';
import 'core/services/widget_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    final storage = LocalStorageService();
    await storage.init();

    final nativeHealth = NativeHealthService();
    int hardwareSteps = await nativeHealth.getHardwareSteps();

    if (hardwareSteps == 0) return Future.value(true);

    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month}-${now.day}';
    String lastDate = storage.getLastDate();
    int baseline = storage.getHardwareBaseline();

    // 1. Process Daily and Weekly Resets
    if (lastDate != dateStr) {
      storage.saveLastDate(dateStr);
      storage.saveSteps(0);
      storage.saveLastCoinStep(0);
      storage.saveGoalNotified(false);

      storage.saveHardwareBaseline(hardwareSteps);
      baseline = hardwareSteps;

      String weeklyData = storage.getWeeklySteps();
      List<int> weekly = weeklyData.split(',').map((e) => int.tryParse(e) ?? 0).toList();
      if (weekly.length != 7) weekly = [0, 0, 0, 0, 0, 0, 0];

      // Fixes the Monday Problem
      if (now.weekday == DateTime.monday) {
        weekly = [0, 0, 0, 0, 0, 0, 0];
      } else {
        weekly[now.weekday - 1] = 0;
      }
      storage.saveWeeklySteps(weekly.join(','));
    }

    // 2. Calculate Actual Steps
    int todaySteps = hardwareSteps - baseline;

    if (todaySteps < 0) {
      int savedStepsToday = storage.getSteps();
      int accumulatedSteps = savedStepsToday + hardwareSteps;
      storage.saveHardwareBaseline(hardwareSteps - accumulatedSteps);
      todaySteps = accumulatedSteps;
    }

    // 3. Process Coins
    int lastCoinStep = storage.getLastCoinStep();
    int currentCoins = storage.getCoins();

    if (todaySteps >= lastCoinStep + 100) {
      int newCoins = (todaySteps - lastCoinStep) ~/ 100;
      currentCoins += newCoins;
      storage.saveCoins(currentCoins);
      storage.saveLastCoinStep(lastCoinStep + (newCoins * 100));
    }

    // 4. Update Hive and Widget
    storage.saveSteps(todaySteps);

    String weeklyData = storage.getWeeklySteps();
    List<int> weekly = weeklyData.split(',').map((e) => int.tryParse(e) ?? 0).toList();
    if (weekly.length == 7) {
      weekly[now.weekday - 1] = todaySteps;
      storage.saveWeeklySteps(weekly.join(','));
    }

    final widgetService = WidgetService();
    await widgetService.init();
    widgetService.updateWidgetData(todaySteps, storage.getStepGoal());

    // 5. Silent Firebase Sync
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firebaseDateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      int totalWeeklySteps = weekly.reduce((a, b) => a + b);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'currentCoins': currentCoins,
        'todaySteps': todaySteps,
        'todayCalories': todaySteps * 0.04,
        'todayDistanceKm': todaySteps * 0.00075,
        'weeklySteps': weekly,
        'weeklyCalories': totalWeeklySteps * 0.04,
        'lastUpdated': FieldValue.serverTimestamp(),
        'dailyHistory': {
          firebaseDateStr: todaySteps,
        }
      }, SetOptions(merge: true));
    }

    return Future.value(true);
  });
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final storage = LocalStorageService();
  await storage.init();

  final widgetService = WidgetService();
  await widgetService.init();

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  Workmanager().registerPeriodicTask(
    "step_tracker_task_id",
    "process_background_steps",
    frequency: const Duration(minutes: 15),
  );

  runApp(
    const ProviderScope(
      child: BuildUpApp(),
    ),
  );
}