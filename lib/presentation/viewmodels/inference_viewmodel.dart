import 'package:flutter/material.dart';
import '../../data/services/tflite_service.dart';
// Importe suas entidades e serviços aqui no futuro

enum ViewState { initial, loading, success, error }

class InferenceViewModel extends ChangeNotifier {
  final TFLiteService _tfliteService;

  ViewState _state = ViewState.initial;
  String? _imagePath;
  String? _predictedClass;
  String? _translatedClass;
  double? _confidence;
  String? _errorMessage;
  int? _inferenceTime;
  int? get inferenceTime => _inferenceTime;

  // Construtor que recebe o serviço injetado
  InferenceViewModel(this._tfliteService) {
    // Tenta inicializar o modelo assim que o ViewModel é criado
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      await _tfliteService.initialize();
    } catch (e) {
      _errorMessage = "Erro interno: Falha ao carregar o modelo de IA.";
      _state = ViewState.error;
      notifyListeners();
    }
  }

  // Getters para a UI ler os dados
  ViewState get state => _state;
  String? get imagePath => _imagePath;
  String? get predictedClass => _predictedClass;
  String? get translatedClass => _translatedClass;
  double? get confidence => _confidence;
  String? get errorMessage => _errorMessage;

  // Função que será chamada quando o usuário tirar a foto
  Future<void> analyzeImage(String path) async {
    _imagePath = path;
    _state = ViewState.loading;
    notifyListeners();

    try {
      // Chama a inferência real do nosso serviço!
      final result = await _tfliteService.classifyImage(path);

      _predictedClass = result.className;
      _translatedClass = result.translatedName;
      _confidence = result.confidence;
      _inferenceTime = result.inferenceTime;
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = "Erro ao processar imagem: $e";
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _state = ViewState.initial;
    _imagePath = null;
    _predictedClass = null;
    _confidence = null;
    _inferenceTime = null;
    _errorMessage = null;
    notifyListeners();
  }
}
