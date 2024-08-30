import 'package:flashfy/flashfy_activity.dart';
import 'package:flutter/material.dart';
import 'package:torch_controller/torch_controller.dart';
import 'package:home_widget/home_widget.dart';

void main() {
  TorchController().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlashFy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const Flashfy(),
    );
  }
}

Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'toggleflashlight') {
    final controller = TorchController();
    bool isOn = await HomeWidget.getWidgetData<bool>('flashlight_state') ?? false;
    isOn = !isOn;
    controller.toggle();
    await HomeWidget.saveWidgetData<bool>('flashlight_state', isOn);
    await HomeWidget.updateWidget(
      name: 'FlashlightWidgetProvider',
      iOSName: 'FlashlightWidget',
    );
  }
}