class ClassificationResult {
  final String className;
  final String translatedName;
  final double confidence; // De 0.0 a 1.0
  final int inferenceTime;

  ClassificationResult({
    required this.className,
    required this.translatedName,
    required this.confidence,
    required this.inferenceTime,
  });
}
