import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nativeHealthProvider = Provider<NativeHealthService>((ref) {
  return NativeHealthService();
});

class NativeHealthService {
  static const platform = MethodChannel('com.buildup.app/health_services');

  Future<int> getHardwareSteps() async {
    try {
      final int steps = await platform.invokeMethod('getHardwareSteps');
      return steps;
    } on PlatformException {
      return 0;
    }
  }

  Future<int> getAndroidApiLevel() async {
    try {
      final int apiLevel = await platform.invokeMethod('getAndroidApiLevel');
      return apiLevel;
    } on PlatformException {
      return 99; // Returns a high number to hide the notice if an error occurs
    }
  }

}