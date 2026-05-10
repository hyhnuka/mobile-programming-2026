import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ClassifierService {
  Map<String, dynamic>? _explainData;
  bool _isModelLoaded = false;

  Future<void> initModel() async {
    if (_isModelLoaded) return;
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
    String jsonString = await rootBundle.loadString('assets/explain-label.json');
    _explainData = jsonDecode(jsonString);
    _isModelLoaded = true;
  }

  Future<Map<String, dynamic>?> classify(String imagePath) async {
    var output = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 1,
      threshold: 0.1,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (output != null && output.isNotEmpty) {
      String rawLabel = output[0]['label'];
      String cleanLabel = rawLabel.replaceAll(RegExp(r'^[0-9]+\s'), '').trim();
      var detail = _explainData?[cleanLabel];
      
      String treatmentStr = "-";
      if (detail != null && detail['penanganan'] != null) {
        if (detail['penanganan'] is List) {
          treatmentStr = (detail['penanganan'] as List).map((e) => "• $e").join("\n");
        } else {
          treatmentStr = detail['penanganan'].toString();
        }
      }

      return {
        "label": cleanLabel,
        "confidence": output[0]['confidence'],
        "cause": detail?['penyebab'] ?? "Penyebab tidak ditemukan.",
        "treatment": treatmentStr,
      };
    }
    return null;
  }
}