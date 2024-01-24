import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:placa_recognise/view/detector_view.dart';

class TextRecognizerView extends StatefulWidget {
  const TextRecognizerView({super.key});

  @override
  State<TextRecognizerView> createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  // var _script = TextRecognitionScript.latin;
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  // Padrão antigo
  final RegExp regexAntigo = RegExp(r'[A-Z]{3}-\d{4}', caseSensitive: false);
  // Padrão Mercosul
  final RegExp regexMercosul = RegExp(r'[A-Z]{3}\d[A-Z]\d{2}', caseSensitive: false);
  bool isMatched = false;
  String ultimaPlacaLida = '';

  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          body: Stack(children: [
            DetectorView(
              title: 'Text Detector',
              customPaint: _customPaint,
              text: _text,
              onImage: _processImage,
              initialCameraLensDirection: _cameraLensDirection,
              onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
            ),
          ]),
        ));
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (isMatched && Get.isBottomSheetOpen!) return;
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    if (!mounted) return;

    for (TextBlock cada in recognizedText.blocks) {
      print(cada.text);
      if (regexAntigo.hasMatch(cada.text) || regexMercosul.hasMatch(cada.text)) {
        ultimaPlacaLida = limparStringRegex(cada.text);
        isMatched = true;
        _isBusy = true;
        break;
      }
    }

    if (!Get.isBottomSheetOpen! && isMatched) {
      await Get.bottomSheet(
          isDismissible: false,
          enableDrag: false,
          PopScope(
            canPop: false,
            child: SizedBox(
              height: 200,
              child: Container(
                height: 200,
                color: Colors.amber,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Placa reconhecida $ultimaPlacaLida'),
                      ElevatedButton(
                        child: const Text('Tentar novamente'),
                        onPressed: () {
                          ultimaPlacaLida = '';
                          isMatched = false;
                          Navigator.pop(context);
                          _isBusy = false;
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ));
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
    // // Verifica se o texto reconhecido corresponde aos padrões Regex
    // if (regexAntigo.hasMatch(recognizedText.text) || regexMercosul.hasMatch(recognizedText.text)) {
    //   if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
    //     final painter = TextRecognizerPainter(
    //       recognizedText,
    //       inputImage.metadata!.size,
    //       inputImage.metadata!.rotation,
    //       _cameraLensDirection,
    //     );
    //     _customPaint = CustomPaint(painter: painter);
    //   } else {
    //     _text = 'Recognized text:\n\n${recognizedText.text}';
    //     // TODO: set _customPaint to draw boundingRect on top of image
    //     _customPaint = null;
    //   }
    // }
  }

  String limparStringRegex(String str) {
    // Encontra todas as correspondências na string
    Iterable<RegExpMatch> todasAsCorrespondencias = regexAntigo.allMatches(str).followedBy(regexMercosul.allMatches(str));

    // Se houver correspondências, retorna a primeira. Caso contrário, retorna uma string vazia.
    return todasAsCorrespondencias.isNotEmpty ? todasAsCorrespondencias.first.group(0)! : '';
  }
}
