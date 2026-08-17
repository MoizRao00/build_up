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

  const StepState({
    required this.currentSteps,
    required this.goalSteps,
    required this.calories,
    required this.distanceKm,
    required this.isRestMode,
    this.pedestrianStatus = 'stopped',
  });

  StepState copyWith({
    int? currentSteps,
    int? goalSteps,
    double? calories,
    double? distanceKm,
    bool? isRestMode,
    String? pedestrianStatus,
  }) {
    return StepState(
      currentSteps: currentSteps ?? this.currentSteps,
      goalSteps: goalSteps ?? this.goalSteps,
      calories: calories ?? this.calories,
      distanceKm: distanceKm ?? this.distanceKm,
      isRestMode: isRestMode ?? this.isRestMode,
      pedestrianStatus: pedestrianStatus ?? this.pedestrianStatus,
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

    return StepState(
      currentSteps: savedSteps,
      goalSteps: 10000,
      calories: savedSteps * 0.04,
      distanceKm: savedSteps * 0.00075,
      isRestMode: false,
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
        onStepCount: (steps) {
          if (state.isRestMode) return;
          state = state.copyWith(
            currentSteps: steps,
            calories: steps * 0.04,
            distanceKm: steps * 0.00075,
          );

          storage.saveSteps(steps);
          widgetService.updateWidgetData(steps, state.goalSteps);

          if (steps % 10 == 0) {
            _syncStepsToFirestore(steps);
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