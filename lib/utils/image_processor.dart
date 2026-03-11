import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessor {
  // Constantes de normalização do ImageNet (idênticas ao seu código PyTorch)
  static const List<double> _mean = [0.485, 0.456, 0.406];
  static const List<double> _std = [0.229, 0.224, 0.225];
  static const int _inputSize = 224;

  /// Processa a imagem capturada e a converte em um tensor 4D [1, 224, 224, 3]
  static List<List<List<List<double>>>> processImage(File imageFile) {
    // 1. Decodifica o arquivo de imagem
    final bytes = imageFile.readAsBytesSync();
    img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception('Falha ao decodificar a imagem.');
    }

    // 2. Redimensionamento para 224x224 (replicando transforms.Resize)
    img.Image resizedImage = img.copyResize(
      originalImage,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    // 3. Inicializa o tensor 4D: [Batch=1][Height=224][Width=224][Channels=3]
    var tensor = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (_) => List.generate(_inputSize, (_) => List.filled(3, 0.0)),
      ),
    );

    // 4. Extrai os pixels e aplica a normalização ImageNet
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        // Obtém o pixel (a biblioteca 'image' retorna um objeto Pixel)
        img.Pixel pixel = resizedImage.getPixel(x, y);

        // Acessa os canais R, G, B garantindo que estejam no intervalo [0, 255]
        double r = pixel.r.toDouble();
        double g = pixel.g.toDouble();
        double b = pixel.b.toDouble();

        // Converte para a escala [0, 1] (replicando transforms.ToTensor)
        r /= 255.0;
        g /= 255.0;
        b /= 255.0;

        // Aplica a normalização: (valor - média) / desvio_padrao
        tensor[0][y][x][0] = (r - _mean[0]) / _std[0];
        tensor[0][y][x][1] = (g - _mean[1]) / _std[1];
        tensor[0][y][x][2] = (b - _mean[2]) / _std[2];
      }
    }

    return tensor;
  }
}
