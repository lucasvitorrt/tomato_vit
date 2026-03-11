import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tflite_service.dart';
import '../utils/image_processor.dart';

class ScannerViewModel extends ChangeNotifier {
  final TFLiteService _tfliteService = TFLiteService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String _predictionResult = '';
  bool _isLoading = false;

  File? get selectedImage => _selectedImage;
  String get predictionResult => _predictionResult;
  bool get isLoading => _isLoading;

  /// Inicializa o modelo (Float16 por padrão)
  Future<void> initModel() async {
    _isLoading = true;
    notifyListeners();

    await _tfliteService.loadModel(useInt8: false);

    _isLoading = false;
    notifyListeners();
  }

  /// Abre a Câmera ou Galeria
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      _predictionResult = 'Processando...';
      notifyListeners();

      await _analyzeImage();
    }
  }

  /// Executa o pipeline: Imagem -> Tensor -> MobileViT-S -> Resultado
  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Inicia o cronômetro para medir a latência (Requisito da Etapa 4)
      final startTime = DateTime.now();

      // 2. Pré-processamento (Resize 224x224 e Normalização ImageNet)
      var inputTensor = ImageProcessor.processImage(_selectedImage!);

      // 3. Inferência (MobileViT-S)
      var outputTensor = await _tfliteService.runInference(inputTensor);

      // 4. Pós-processamento (Encontrar a classe com maior probabilidade)
      final List<double> probabilities = outputTensor[0].cast<double>();

      double maxProb = 0;
      int maxIndex = 0;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      // 5. Finaliza o cronômetro
      final endTime = DateTime.now();
      final latency = endTime.difference(startTime).inMilliseconds;

      // 6. Formata o resultado
      final labels = _tfliteService.labels;
      final className = labels.isNotEmpty && maxIndex < labels.length
          ? labels[maxIndex]
          : 'Classe Desconhecida ($maxIndex)';

      _predictionResult =
          'Doença: $className\n'
          'Confiança: ${(maxProb * 100).toStringAsFixed(2)}%\n'
          'Latência: $latency ms';
    } catch (e) {
      _predictionResult = 'Erro na análise: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
