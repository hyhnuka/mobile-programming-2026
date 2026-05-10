import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/classifier_service.dart';
import '../services/db_helper.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final ClassifierService classifier;

  const ResultScreen({Key? key, required this.imageFile, required this.classifier}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isProcessing = true;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    final result = await widget.classifier.classify(widget.imageFile.path);
    setState(() {
      _result = result;
      _isProcessing = false;
    });
  }

  Future<void> _saveToDatabase() async {
    if (_result == null) return;
    final now = DateTime.now();
    final formattedDate = "${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}";
    
    final data = {
      'imagePath': widget.imageFile.path,
      'label': _result!['label'],
      'cause': _result!['cause'],
      'treatment': _result!['treatment'],
      'date': formattedDate,
    };

    await DBHelper.insertHistory(data);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Diagnosis AI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 400,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(widget.imageFile),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                              const Color(0xFFF8F9FA),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [
                            Text(
                              _result!['label'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B5E20).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Akurasi: ${(_result!['confidence'] * 100).toStringAsFixed(1)}%",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BAGIAN PENYEBAB
                        const Text("Analisis Penyebab", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Text(
                            _result!['cause'],
                            style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // BAGIAN PENANGANAN
                        const Text("Cara Penanganan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildTreatmentCard(_result!['treatment']),

                        const SizedBox(height: 40),

                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1B5E20).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _saveToDatabase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B5E20),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 0,
                            ),
                            child: const Text("Simpan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTreatmentCard(String treatment) {
    List<String> steps = treatment.split('\n').where((s) => s.trim().isNotEmpty).toList();

    return Column(
      children: steps.map((step) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1B5E20).withOpacity(0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF1B5E20), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.replaceAll('• ', ''), 
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}