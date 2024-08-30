import 'package:flutter/material.dart';
import 'package:torch_controller/torch_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Flashfy extends StatefulWidget {
  const Flashfy({Key? key}) : super(key: key);

  @override
  State<Flashfy> createState() => _FlashfyState();
}

class _FlashfyState extends State<Flashfy> with WidgetsBindingObserver {
  bool isFlashOn = false;
  var controller = TorchController();
  Timer? autoOffTimer;
  Timer? countdownTimer;
  int? autoOffDuration;
  int remainingTime = 0;

  final List<int?> durationOptions = [null, 60, 300, 600, 900, 1800];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadFlashState();
    startPeriodicCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    autoOffTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      startAutoOffTimer();
    } else if (state == AppLifecycleState.resumed) {
      autoOffTimer?.cancel();
      checkFlashlightState();
    }
  }

  void loadFlashState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFlashOn = prefs.getBool('isFlashOn') ?? false;
      int? savedDuration = prefs.getInt('autoOffDuration');
      autoOffDuration = durationOptions.contains(savedDuration) ? savedDuration : null;
      if (isFlashOn) {
        controller.toggle();
        startAutoOffTimer();
      }
    });
    checkFlashlightState();
  }

  void saveFlashState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFlashOn', isFlashOn);
    if (autoOffDuration != null) {
      await prefs.setInt('autoOffDuration', autoOffDuration!);
    } else {
      await prefs.remove('autoOffDuration');
    }
  }

  void toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
      controller.toggle();
      saveFlashState();
      if (isFlashOn) {
        startAutoOffTimer();
      } else {
        autoOffTimer?.cancel();
        countdownTimer?.cancel();
        remainingTime = 0;
      }
    });
  }

  void startAutoOffTimer() {
    autoOffTimer?.cancel();
    countdownTimer?.cancel();
    if (autoOffDuration != null) {
      remainingTime = autoOffDuration!;
      autoOffTimer = Timer(Duration(seconds: autoOffDuration!), () {
        if (isFlashOn) {
          toggleFlash();
        }
      });
      startCountdown();
    } else {
      remainingTime = 0;
    }
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void setAutoOffDuration(int? seconds) {
    setState(() {
      autoOffDuration = seconds;
      saveFlashState();
      if (isFlashOn) {
        startAutoOffTimer();
      }
    });
  }

  void checkFlashlightState() async {
    bool? deviceFlashState = await controller.isTorchActive;
    if (deviceFlashState != isFlashOn) {
      setState(() {
        isFlashOn = deviceFlashState ?? false;
        saveFlashState();
        if (isFlashOn) {
          startAutoOffTimer();
        } else {
          autoOffTimer?.cancel();
          countdownTimer?.cancel();
          remainingTime = 0;
        }
      });
    }
  }

  void startPeriodicCheck() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      checkFlashlightState();
    });
  }

  String formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff292727),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Text(
          "FlashFy",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.timer),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Set Auto-Off Timer"),
                    content: DropdownButton<int?>(
                      value: autoOffDuration,
                      items: durationOptions.map((int? value) {
                        return DropdownMenuItem<int?>(
                          value: value,
                          child: Text(value == null ? "No time limit" : "${value ~/ 60} minutes"),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setAutoOffDuration(newValue);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    isFlashOn ? 'assets/flash_on.png' : 'assets/flash_off.png',
                    width: 300,
                    height: 300,
                  ),
                  SizedBox(height: size.height * 0.1),
                  CircleAvatar(
                    minRadius: 30,
                    maxRadius: 45,
                    child: Transform.scale(
                      scale: 1.5,
                      child: IconButton(
                        onPressed: toggleFlash,
                        icon: const Icon(Icons.power_settings_new),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    isFlashOn
                        ? autoOffDuration != null
                        ? "Auto-off in: ${formatDuration(remainingTime)}"
                        : "No auto-off time limit"
                        : "Flashlight is off",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Text(
          "Developed By Chowdhury Elab",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
        ),
        SizedBox(height: size.height * 0.010),
      ]),
    );
  }
}