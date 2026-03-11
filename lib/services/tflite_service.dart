import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String>? _labels;

  /// Retorna as labels carregadas
  List<String> get labels => _labels ?? [];

  /// Carrega o modelo selecionado e ativa a aceleração de hardware (GPU Delegate)
  Future<void> loadModel({bool useInt8 = false}) async {
    // Permite alternar entre os modelos para avaliar a acurácia em diferentes regimes de quantização
    final modelPath = useInt8
        ? 'assets/models/mobilevit_s_int8.tflite'
        : 'assets/models/mobilevit_s_fp16.tflite';

    try {
      // Configurando o suporte a GPU/NPU delegate
      var interpreterOptions = InterpreterOptions();

      if (Platform.isAndroid) {
        interpreterOptions.addDelegate(GpuDelegateV2());
      } else if (Platform.isIOS) {
        interpreterOptions.addDelegate(GpuDelegate());
      }

      // Inicializa o interpretador do TFLite com o modelo e as opções
      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: interpreterOptions,
      );
      print('Modelo carregado com sucesso: $modelPath');

      await _loadLabels();
    } catch (e) {
      print('Erro ao carregar o modelo: $e');
    }
  }

  /// Lê o arquivo de texto com as classes
  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/labels/labels.txt');
      _labels = labelData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();
      print('Labels carregadas: ${_labels?.length} classes encontradas.');
    } catch (e) {
      print('Erro ao carregar labels: $e');
    }
  }

  /// Método base para executar a inferência (será detalhado no próximo passo)
  Future<List<dynamic>> runInference(
    List<List<List<List<double>>>> inputTensor,
  ) async {
    if (_interpreter == null) {
      throw Exception('O interpretador não foi inicializado.');
    }

    // O MobileViT-S espera uma saída de formato [1, 10] (1 imagem, 10 classes)
    var outputTensor = List.filled(1 * 10, 0.0).reshape([1, 10]);

    // Executa o modelo
    _interpreter!.run(inputTensor, outputTensor);

    return outputTensor;
  }
}
