import 'package:flutter/material.dart';
import 'package:torch_controller/torch_controller.dart';

class flashfy extends StatefulWidget {
  const flashfy({super.key});

  @override
  State<flashfy> createState() => _flashfyState();
}

class _flashfyState extends State<flashfy> {
  bool isFlashFy = false;
  var controller = TorchController();
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
                  isFlashFy ? 'assets/flash_on.png' : 'assets/flash_off.png',
                  width: 300,
                  height: 300,
                  // color: isFlashFy?Colors.transparent: Colors.white.withOpacity(0.8),
                ),
                SizedBox(
                  height: size.height * 0.1,
                ),
                CircleAvatar(
                  minRadius: 30,
                  maxRadius: 45,
                  child: Transform.scale(
                    scale: 1.5,
                    child: IconButton(
                        onPressed: () {
                          controller.toggle();
                          isFlashFy = !isFlashFy;
                          setState(() {});
                        },
                        icon: const Icon(Icons.power_settings_new)),
                  ),
                ),
              ],
            ),
          ),
        )),
        const Text(
          "Developed By Chowdhury Elab",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.0),
        ),
        SizedBox(
          height: size.height * 0.010,
        ),
      ]),
    );
  }
}
