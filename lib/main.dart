import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'presentation/viewmodels/inference_viewmodel.dart';
import 'presentation/screens/home_screen.dart';
import 'data/services/tflite_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // criamos o serviço e o injetamos direto no ViewModel
        ChangeNotifierProvider(
          create: (_) => InferenceViewModel(TFLiteService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobileViT - Saúde do Tomateiro',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
