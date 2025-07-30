import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Classifier {
  late Interpreter _interpreter;
  late List<String> _labels;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/butterfly_model.tflite');
    final labelsRaw = await rootBundle.loadString('assets/labels.txt');
    _labels = labelsRaw.split('\n').map((label) => label.trim()).toList();
  }

  Future<List<Map<String, dynamic>>> classify(File imageFile) async {
    final rawImage = imageFile.readAsBytesSync();
    final image = img.decodeImage(rawImage)!;
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    var input = List.generate(
      1,
      (i) => List.generate(
        224,
        (j) => List.generate(224, (k) {
          final pixel = resizedImage.getPixel(k, j);
          return [
            img.getRed(pixel) / 255.0,
            img.getGreen(pixel) / 255.0,
            img.getBlue(pixel) / 255.0,
          ];
        }),
      ),
    );

    var output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
    _interpreter.run(input, output);

    // Prepare predictions with label and confidence
    final List<Map<String, dynamic>> predictions = [];
    for (int i = 0; i < _labels.length; i++) {
      predictions.add({'label': _labels[i], 'confidence': output[0][i]});
    }

    // Sort predictions by confidence (highest first)
    predictions.sort(
      (a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double),
    );

    // Return top 5 predictions (you can change the number)
    return predictions.take(5).toList();
  }
}
