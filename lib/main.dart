import 'package:flashfy/flashfy_activity.dart';
import 'package:flutter/material.dart';
import 'package:torch_controller/torch_controller.dart';

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
      home: const flashfy(),
    );
  }
}