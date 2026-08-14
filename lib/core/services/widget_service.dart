import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String appGroupId = 'group.com.example.buildup';
  static const String androidWidgetName = 'StepWidgetProvider';
  static const String iosWidgetName = 'StepWidget';

  Future<void> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  Future<void> updateWidgetData(int currentSteps, int goalSteps) async {
    await HomeWidget.saveWidgetData<int>('current_steps', currentSteps);
    await HomeWidget.saveWidgetData<int>('goal_steps', goalSteps);

    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: iosWidgetName,
    );
  }
}