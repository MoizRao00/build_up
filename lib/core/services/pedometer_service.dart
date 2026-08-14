import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class PedometerService {
  StreamSubscription<StepCount>? _stepCountStream;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;

  Future<bool> requestPermissions() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  void startTracking({
    required Function(int) onStepCount,
    required Function(String) onStatusChanged,
    required Function(dynamic) onError,
  }) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    _stepCountStream = Pedometer.stepCountStream.listen(
          (StepCount event) => onStepCount(event.steps),
      onError: onError,
    );

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream.listen(
          (PedestrianStatus event) => onStatusChanged(event.status),
      onError: onError,
    );
  }

  void stopTracking() {
    _stepCountStream?.cancel();
    _pedestrianStatusStream?.cancel();
  }
}