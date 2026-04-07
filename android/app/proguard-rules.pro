# Protege as classes do TensorFlow Lite contra o R8/ProGuard
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**