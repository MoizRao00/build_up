import 'package:home_widget/home_widget.dart';

class WidgetService {
  Future<void> init() async {}

  Future<void> updateWidgetData(int steps, int goalSteps) async {
    await HomeWidget.saveWidgetData<String>('_currentSteps', steps.toString());
    await HomeWidget.updateWidget(
      name: 'StepWidgetProvider',
      androidName: 'StepWidgetProvider',
    );
  }
}