import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:servelq_agent/models/training_model.dart';

class DocumentLearning extends StatelessWidget {
  final TrainingAssignment material;

  const DocumentLearning({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: PDFView(filePath: material.cloudinaryUrl));
  }
}
