import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _boxName = 'buildUpData';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  void saveSteps(int steps) {
    _box.put('currentSteps', steps);
  }

  int getSteps() {
    return _box.get('currentSteps', defaultValue: 0);
  }

  void saveCoins(int coins) {
    _box.put('coins', coins);
  }

  int getCoins() {
    return _box.get('coins', defaultValue: 0);
  }

  void saveBaselineSteps(int steps) {
    _box.put('baselineSteps', steps);
  }

  int getBaselineSteps() {
    return _box.get('baselineSteps', defaultValue: 0);
  }

  void saveLastDate(String date) {
    _box.put('lastDate', date);
  }

  String getLastDate() {
    return _box.get('lastDate', defaultValue: '');
  }
  void saveLastCoinStep(int steps) {
    _box.put('lastCoinStep', steps);
  }

  int getLastCoinStep() {
    return _box.get('lastCoinStep', defaultValue: 0);
  }
}