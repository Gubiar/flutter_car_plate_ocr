import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:placa_recognise/controller/controller.dart';
import 'package:placa_recognise/view/detector_view.dart';

class TextRecognizerView extends StatefulWidget {
  const TextRecognizerView({Key? key}) : super(key: key);

  @override
  _TextRecognizerViewState createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final RegExp _regexAntigo = RegExp(r'[A-Z]{3}-\d{4}', caseSensitive: false);
  final RegExp _regexMercosul = RegExp(r'[A-Z]{3}\d[A-Z]\d{2}', caseSensitive: false);
  var _cameraLensDirection = CameraLensDirection.back;
  bool _canProcess = true;
  bool _isBusy = false;
  bool _isMatched = false;
  String _lastReadPlate = '';

  @override
  void dispose() {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Identificação da placa veicular',
            style: TextStyle(fontSize: 16),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              _lastReadPlate = '';
              _isMatched = false;
              Navigator.pop(context);
              Navigator.pop(context, '');
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: Stack(
          children: [
            DetectorView(
              title: 'Detector de placa',
              onImage: _processImage,
              initialCameraLensDirection: _cameraLensDirection,
              onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (_isMatched && Get.isBottomSheetOpen!) return;
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    if (!mounted) return;

    for (TextBlock block in recognizedText.blocks) {
      if (_regexAntigo.hasMatch(block.text) || _regexMercosul.hasMatch(block.text)) {
        _lastReadPlate = _cleanStringRegex(block.text);
        _isMatched = true;
        break;
      }
    }

    if (!Get.isBottomSheetOpen! && _isMatched) {
      final retorno = await _showBottomSheet(context);

      if (retorno) {
        Navigator.pop(context); //retornar valor para tela anterior
        return;
      }
    }

    setState(() {
      _isBusy = false;
    });
  }

  Future<dynamic> _showBottomSheet(BuildContext context) {
    return Get.bottomSheet(
      isDismissible: false,
      enableDrag: false,
      PopScope(
        canPop: false,
        child: SizedBox(
          height: 180,
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Placa reconhecida:'),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black87,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white),
                    alignment: Alignment.center,
                    child: Text(
                      _lastReadPlate,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            _lastReadPlate = '';
                            _isMatched = false;
                            Navigator.pop(context, false);
                          },
                          child: const Text('Tentar Novamente')),
                      ElevatedButton(
                        child: const Text('Confirmar'),
                        onPressed: () {
                          Controller.placaLida = _lastReadPlate;
                          Navigator.pop(context, true); //closeModal
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _cleanStringRegex(String str) {
    Iterable<RegExpMatch> allMatches = _regexAntigo.allMatches(str).followedBy(_regexMercosul.allMatches(str));
    return allMatches.isNotEmpty ? allMatches.first.group(0)! : '';
  }
}
