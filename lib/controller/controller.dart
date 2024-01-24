import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Controller {
  // Padrão antigo
  RegExp regexAntigo = RegExp(r'[A-Z]{3}-\d{4}', caseSensitive: false);
// Padrão Mercosul
  RegExp regexMercosul = RegExp(r'[A-Z]{3}\d[A-Z]\d{2}', caseSensitive: false);

  Future<String> getAssetPath(String asset) async {
    final path = await getLocalPath(asset);
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  Future<String> getLocalPath(String path) async {
    return '${(await getApplicationSupportDirectory()).path}/$path';
  }
}
