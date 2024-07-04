import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scanlator/views/camera.scanner.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

late List<CameraDescription> _cameras;

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    camcam();
    Timer(
        const Duration(seconds: 5),
        () => Get.to(CameraScanner(
              camera: _cameras.first,
            )));
  }

  camcam() async {
    _cameras = await availableCameras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255),
              ]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 150),
                  child: Image.asset(
                    "assets/images/output-onlinegiftools.gif",
                    height: 100.0,
                    width: 300.0,
                  ),
                ),
                const Text(
                  "ScanLator",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // color: Colors.white,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
