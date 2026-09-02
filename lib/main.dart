import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'app/app.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/widget_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    print('Background step tracker waking up');

    final storage = LocalStorageService();
    await storage.init();

    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month}-${now.day}';
    String lastDate = storage.getLastDate();

    if (lastDate != dateStr) {
      storage.saveLastDate(dateStr);
      storage.saveLastCoinStep(0);
      storage.saveGoalNotified(false);
      print('Background task completed midnight reset');
    }

    print('Background step tracker finished');
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