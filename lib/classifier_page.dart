import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'classifier.dart';
import 'butterfly_info.dart';
import 'history.dart';

class ClassifyPage extends StatefulWidget {
  const ClassifyPage({super.key});

  @override
  _ClassifyPageState createState() => _ClassifyPageState();
}

class _ClassifyPageState extends State<ClassifyPage> {
  final picker = ImagePicker();
  File? _image;
  String _result = "Upload an image to classify";
  late Classifier _classifier;
  bool _modelLoaded = false;
  bool _isPredicting = false;
  List<Map<String, dynamic>> _topPredictions = [];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    _classifier = Classifier();
    await _classifier.loadModel();
    setState(() => _modelLoaded = true);
  }

  Future<void> _getImage() async {
    if (!_modelLoaded) return;

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final image = File(pickedFile.path);
    setState(() {
      _image = image;
      _result = "Classifying...";
      _isPredicting = true;
    });

    try {
      final predictions = await _classifier.classify(image);
      final topPrediction = predictions[0];

      setState(() {
        _topPredictions = predictions.take(5).toList();
        _result = topPrediction['label'];
        _isPredicting = false;
      });

      await addToHistory(topPrediction['label'], image.path);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ButterflyDetailPage(
            commonName: _topPredictions[0]['label'],
            alternatives: _topPredictions,
            selectedIndex: 0,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _result = "Error: $e";
        _isPredicting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Butterfly Classifier')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Image.asset('assets/TATRlogoblack.png', height: 200)),
            const SizedBox(height: 20),
            _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _image!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "No image selected",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            _isPredicting
                ? const Center(child: CircularProgressIndicator())
                : _image == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _result,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 6, 6, 6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 128, 55, 184),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _modelLoaded ? _getImage : null,
              icon: const Icon(Icons.image),
              label: Text(
                _modelLoaded ? 'Upload an Image' : 'Loading Model...',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (_topPredictions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ButterflyDetailPage(
                          commonName: _topPredictions[0]['label'],
                          alternatives: _topPredictions,
                          selectedIndex: 0,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, color: Colors.teal),
                  label: const Text(
                    'More details',
                    style: TextStyle(fontSize: 16, color: Colors.teal),
                  ),
                  style: OutlinedButton.styleFrom(
                    //backgroundColor: const Color.fromARGB(255, 206, 249, 245),
                    side: const BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
