import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../domain/entities/classification_result.dart';

class TFLiteService {
  Interpreter? _interpreter;

  // As 10 classes do dataset PlantVillage de Tomate (na ordem exata que o Python gerou)
  // IMPORTANTE: Garanta que esta ordem é a mesma do seu 'dataset.classes' no Python
  final List<String> _labels = [
    'Tomato___Bacterial_spot',
    'Tomato___Early_blight',
    'Tomato___Late_blight',
    'Tomato___Leaf_Mold',
    'Tomato___Septoria_leaf_spot',
    'Tomato___Spider_Mites Two-spotted_spider_mite',
    'Tomato___Target_Spot',
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
    'Tomato___Tomato_Mosaic_Virus',
    'Tomato___Healthy',
  ];

  final Map<String, String> _translations = {
    'Tomato___Bacterial_spot': 'Mancha Bacteriana',
    'Tomato___Early_blight': 'Pinta Preta (Alternariose)',
    'Tomato___Late_blight': 'Requeima',
    'Tomato___Leaf_Mold': 'Bolor Foliar',
    'Tomato___Septoria_leaf_spot': 'Septoriose',
    'Tomato___Spider_Mites Two-spotted_spider_mite': 'Ácaro Rajado',
    'Tomato___Target_Spot': 'Mancha Alvo',
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus': 'Vírus do Enrolamento Amarelo',
    'Tomato___Tomato_Mosaic_Virus': 'Vírus do Mosaico',
    'Tomato___Healthy': 'Planta Saudável',
  };

  /// Inicializa o interpretador carregando o modelo fp16 dos assets
  Future<void> initialize() async {
    try {
      final options = InterpreterOptions();

      // Vamos usar 4 threads do processador do celular para garantir rapidez
      // sem precisar brigar com os drivers de NPU/GPU neste primeiro momento.
      options.threads = 4;

      // Carrega o modelo (garanta que o arquivo mobilevit_s_fp16.tflite está na pasta assets)
      // Adicionamos o "assets/" antes do nome
      _interpreter = await Interpreter.fromAsset(
        'assets/mobilevit_s_fp16.tflite',
        options: options,
      );
      print('✅ Modelo TFLite (fp16) carregado com sucesso!');
    } catch (e) {
      print('❌ Erro ao carregar o modelo: $e');
      throw Exception('Falha ao inicializar a IA.');
    }
  }

  /// Executa todo o pipeline: decodifica, redimensiona, normaliza e infere
  Future<ClassificationResult> classifyImage(String imagePath) async {
    if (_interpreter == null)
      throw Exception('Interpretador não inicializado.');

    // 1. Decodifica a imagem original do arquivo
    final imageFile = File(imagePath);
    final rawImage = img.decodeImage(imageFile.readAsBytesSync());
    if (rawImage == null) throw Exception('Não foi possível ler a imagem.');

    // 2. transforms.Resize((224, 224))
    final resizedImage = img.copyResize(rawImage, width: 224, height: 224);

    // 3. Prepara o Tensor de Entrada (Formato NHWC - Padrão TFLite)
    // [1, 224, 224, 3] -> [Batch, Altura, Largura, Canais RGB]
    var inputTensor = List.generate(
      1,
      (i) => List.generate(
        224,
        (y) => List.generate(224, (x) => List.filled(3, 0.0)),
      ),
    );

    // transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    final mean = [0.485, 0.456, 0.406];
    final std = [0.229, 0.224, 0.225];

    // 4. Preenchendo o tensor e aplicando a normalização PyTorch
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);

        // transforms.ToTensor() divide por 255.0. Depois subtrai a média e divide pelo desvio.
        inputTensor[0][y][x][0] =
            ((pixel.r / 255.0) - mean[0]) / std[0]; // Canal R
        inputTensor[0][y][x][1] =
            ((pixel.g / 255.0) - mean[1]) / std[1]; // Canal G
        inputTensor[0][y][x][2] =
            ((pixel.b / 255.0) - mean[2]) / std[2]; // Canal B
      }
    }

    // 5. Tensor de Saída [Batch, NumClasses]
    var outputTensor = List.generate(1, (i) => List.filled(10, 0.0));

    // 6. Inferência!
    _interpreter!.run(inputTensor, outputTensor);

    // A saída do PyTorch são 'logits' (números brutos). Precisamos aplicar o Softmax.
    final logits = outputTensor[0];
    final probabilities = _softmax(logits);

    // 7. Encontra a maior probabilidade (ArgMax)
    double maxConfidence = -1.0;
    int predictedIndex = -1;

    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        predictedIndex = i;
      }
    }

    String rawClass = _labels[predictedIndex];
    // Retorna a entidade limpa para a interface
    return ClassificationResult(
      className: _labels[predictedIndex]
          .replaceAll('Tomato___', '')
          .replaceAll('_', ' '),
      translatedName:
          _translations[rawClass] ?? 'Desconhecido', // Puxa do nosso dicionário
      confidence: maxConfidence,
    );
  }

  /// Função utilitária para aplicar Softmax nos logits
  List<double> _softmax(List<double> logits) {
    double maxLogit = logits.reduce(max); // Previne overflow matemático
    List<double> expValues = logits
        .map((logit) => exp(logit - maxLogit))
        .toList();
    double sumExp = expValues.reduce((a, b) => a + b);
    return expValues.map((val) => val / sumExp).toList();
  }

  void dispose() {
    _interpreter?.close();
  }
}
