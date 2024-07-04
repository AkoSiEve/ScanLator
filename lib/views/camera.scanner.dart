// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class CameraScanner extends StatefulWidget {
  const CameraScanner({
    Key? key,
    required this.camera,
  }) : super(key: key);
  final CameraDescription camera;
  @override
  State<CameraScanner> createState() => _CameraScannerState();
}

class _CameraScannerState extends State<CameraScanner> {
  Timer? timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initCamera(widget.camera);
    // timer = Timer.periodic(Duration(seconds: 3), (Timer t) => _takePicture());
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) => barUpSideDown());
    Timer.periodic(Duration(seconds: 5), (Timer t) => resetToDefaultText());
  }

  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
    // timer?.cancel();
    super.dispose();
  }

  late CameraController _cameraController;
  Future initCamera(CameraDescription cameraDescription) async {
// create a CameraController
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.low);
// Next, initialize the controller. This returns a Future.
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _cameraController.value.isInitialized
                  ? Stack(
                      children: [
                        AspectRatio(
                            aspectRatio: 0.8,
                            child: CameraPreview(_cameraController)),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: 350,
                              width: 350,
                              child: CustomPaint(
                                // painter: ShapePainter(),
                                painter: ShapePainterv2(),
                                child: Container(),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              alignment: Alignment.center,
                              // color: Colors.black45,
                              width: MediaQuery.sizeOf(context).width / 1.2,
                              height: MediaQuery.sizeOf(context).height / 2.7,
                              child: Container(
                                color: Colors.black45,
                                child: Text(
                                  "${recognizeText != null ? recognizeText : ""}",
                                  // "qweqwe",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              // width: 100,
                              child: InkWell(
                                onTap: () {
                                  _takePicture();
                                  print(
                                      "ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
                                },
                                child: Image.asset(
                                  "assets/images/output-onlinegiftools.gif",
                                  height: 60.0,
                                  width: 50.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                            child: Container(
                          // color: Colors.blue,
                          padding: EdgeInsets.only(bottom: 90, top: 90),
                          child: animationLineScann(),
                        )),
                      ],
                    )
                  : Center(child: CircularProgressIndicator()),
              Text(translatedWorld != null ? "Translated world" : " "),
              // Text(pathJPG != null ? "path : ${pathJPG}" : " "),
              SizedBox(
                  child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                // color: Colors.red,
                child: Text(
                  "${translatedWorld != null ? translatedWorld : ''}",
                  style: TextStyle(color: Colors.red),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  String? recognizeText;
  String? translatedWorld;
  String? pathJPG;
  _takePicture() async {
    final image = await _cameraController.takePicture();
    final RecognizedText =
        await processImage(InputImage.fromFile(File(image.path)));

    if (RecognizedText == null) return;
    final checkTranslate = await translateDetector(RecognizedText);

    setState(() {
      pathJPG = image.path;
      translatedWorld = checkTranslate;
      recognizeText = RecognizedText;
    });
    // evictImage(image.path);
    print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa${RecognizedText}");
  }

  Future<String?> processImage(InputImage inputImage) async {
    try {
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      return null;
    }
  }

  Future<String?> translateDetector(String text) async {
    try {
      final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
      final languageCode = await languageIdentifier.identifyLanguage(text);
      print(
          "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd${languageCode}");
      print(
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa${languageCodeFixer(languageCode)}");
      languageIdentifier.close();
      final translator = OnDeviceTranslator(
          sourceLanguage: TranslateLanguage.values.firstWhere(
              (element) => element.bcpCode == languageCodeFixer(languageCode)),
          targetLanguage: TranslateLanguage.english);

      final String response = await translator.translateText(text);

      return response;
    } catch (e) {
      return null;
    }
  }

  languageCodeFixer(String code) {
    switch (code) {
      case "fil":
        return "tl";
      default:
        return code;
    }
  }

  bool selected = false;
  animationLineScann() {
    return AnimatedAlign(
      alignment: selected ? Alignment.topCenter : Alignment.bottomCenter,
      duration: Duration(seconds: 2),
      child: SizedBox(
        width: 200,
        child: Divider(
          thickness: 3,
          color: Colors.red,
        ),
      ),
    );
  }

  barUpSideDown() {
    setState(() {
      selected = !selected;
    });
  }

  resetToDefaultText() {
    setState(() {
      recognizeText = null;
      pathJPG = null;
      translatedWorld = null;
    });
  }
}

class ShapePainterv2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double padding = 20;
    final double frameSFactor = .1;
    final frameHWidth = size.width * frameSFactor;
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var path = Path();

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(0, 0, size.width, size.height),
          Radius.circular(18),
        ),
        paint);

    /// top left
    canvas.drawLine(
      Offset(0 + padding, padding),
      Offset(
        padding + frameHWidth,
        padding,
      ),
      paint..color = const Color.fromARGB(255, 241, 0, 0),
    );

    canvas.drawLine(
      Offset(0 + padding, padding),
      Offset(
        padding,
        padding + frameHWidth,
      ),
      paint..color = const Color.fromARGB(255, 241, 0, 0),
    );

    /// top Right
    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(size.width - padding - frameHWidth, padding),
      paint..color = const Color.fromARGB(255, 241, 0, 0),
    );
    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(size.width - padding, padding + frameHWidth),
      paint..color = const Color.fromARGB(255, 241, 0, 0),
    );

    /// Bottom Right
    canvas.drawLine(
      Offset(size.width - padding, size.height - padding),
      Offset(size.width - padding - frameHWidth, size.height - padding),
      paint..color = const Color.fromARGB(255, 241, 0, 0),
    );
    canvas.drawLine(
        Offset(size.width - padding, size.height - padding),
        Offset(size.width - padding, size.height - padding - frameHWidth),
        paint..color = const Color.fromARGB(255, 241, 0, 0));

    /// Bottom Left
    canvas.drawLine(
      Offset(0 + padding, size.height - padding),
      Offset(0 + padding + frameHWidth, size.height - padding),
      paint..color = const Color.fromARGB(255, 241, 0, 0),
    );
    canvas.drawLine(
      Offset(0 + padding, size.height - padding),
      Offset(0 + padding, size.height - padding - frameHWidth),
      paint..color = const Color.fromARGB(255, 241, 0, 0),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
