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

  void saveHardwareBaseline(int steps) {
    _box.put('hardwareBaseline', steps);
  }

  int getHardwareBaseline() {
    return _box.get('hardwareBaseline', defaultValue: 0);
  }

  List<String> getPurchasedThemes() {
    return _box.get(
        'purchasedThemes', defaultValue: <String>['default']) as List<String>;
  }

  void savePurchasedThemes(List<String> themes) {
    _box.put('purchasedThemes', themes);
  }

  String getActiveTheme() {
    return _box.get('activeTheme', defaultValue: 'default');
  }

  void saveActiveTheme(String themeId) {
    _box.put('activeTheme', themeId);
  }

  int getMonthlyHighScore() {
    return _box.get('monthlyHighScore', defaultValue: 0);
  }

  void saveMonthlyHighScore(int score) {
    _box.put('monthlyHighScore', score);
  }

  int getSavedMonth() {
    return _box.get('savedMonth', defaultValue: 0);
  }

  void saveSavedMonth(int month) {
    _box.put('savedMonth', month);
  }

  int getStepOffset() {
    return _box.get('stepOffset', defaultValue: 0);
  }

  void saveStepOffset(int offset) {
    _box.put('stepOffset', offset);
  }

  bool getGoalNotified() {
    return _box.get('goalNotified', defaultValue: false);
  }

  void saveGoalNotified(bool value) {
    _box.put('goalNotified', value);
  }

  bool getBatteryPromptShown() {
    return _box.get('batteryPromptShown', defaultValue: false);
  }

  void saveBatteryPromptShown(bool value) {
    _box.put('batteryPromptShown', value);
  }

  String getWeeklySteps() {
    final data = _box.get('weeklySteps');
    if (data == null || data is! String) {
      return '0,0,0,0,0,0,0';
    }
    return data;
  }

  void saveWeeklySteps(String data) {
    _box.put('weeklySteps', data);
  }
}