import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_theme.dart';
import '../viewmodels/inference_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Função para abrir a câmera ou galeria
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth:
          800, // Comprimimos um pouco para economizar RAM antes do resize de 224x224
      maxHeight: 800,
    );

    if (pickedFile != null && context.mounted) {
      // Envia o caminho da imagem para o nosso ViewModel processar no TFLite
      context.read<InferenceViewModel>().analyzeImage(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fica escutando as mudanças de estado do ViewModel
    final viewModel = context.watch<InferenceViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diagnóstico de Tomateiro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Só mostra o botão de reset se tiver uma foto carregada ou em tela de erro
          if (viewModel.state != ViewState.initial)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Limpar e recomeçar',
              onPressed: () {
                // Chama a nossa função reset() do ViewModel
                context.read<InferenceViewModel>().reset();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Área Principal (Exibição da Imagem ou Placeholder)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildImageDisplay(viewModel),
                ),
              ),

              const SizedBox(height: 24),

              // Área de Resultados (Aparece apenas no sucesso ou erro)
              Expanded(flex: 2, child: _buildResultArea(viewModel, context)),

              // Botões de Ação (Câmera e Galeria)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: viewModel.state == ViewState.loading
                          ? null
                          : () => _pickImage(context, ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Câmera'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: viewModel.state == ViewState.loading
                          ? null
                          : () => _pickImage(context, ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeria'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.verdeFolha,
                        side: const BorderSide(color: AppTheme.verdeFolha),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Define o que mostrar na caixa principal de imagem
  Widget _buildImageDisplay(InferenceViewModel viewModel) {
    if (viewModel.imagePath != null) {
      // Mostra a foto tirada
      return Image.file(File(viewModel.imagePath!), fit: BoxFit.cover);
    }

    // Placeholder inicial
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.energy_savings_leaf, size: 80, color: AppTheme.verdeFolha),
        SizedBox(height: 16),
        Text(
          'Nenhuma folha analisada',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  // Define o que mostrar na área de resultados
  // Define o que mostrar na área de resultados
  Widget _buildResultArea(InferenceViewModel viewModel, BuildContext context) {
    switch (viewModel.state) {
      case ViewState.initial:
        return const Center(
          child: Text(
            'Tire uma foto ou escolha da galeria para iniciar o diagnóstico com o MobileViT.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        );

      case ViewState.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.verdeFolha),
              SizedBox(height: 16),
              Text(
                'Analisando tensores...',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

      case ViewState.success:
        // 1. Lógica para definir o cenário (Saudável, Doente ou Não Reconhecido)
        final bool isHealthy = viewModel.predictedClass!.toLowerCase().contains(
          'healthy',
        );
        final bool isUnrecognized = viewModel.predictedClass == 'Unrecognized';

        Color color;
        IconData resultIcon;

        // 2. Define as cores e ícones dinamicamente
        if (isUnrecognized) {
          color = Colors.orange; // Cor de alerta para objetos estranhos
          resultIcon = Icons.warning_amber_rounded;
        } else if (isHealthy) {
          color = AppTheme.verdeFolha;
          resultIcon = Icons.check_circle_outline;
        } else {
          color = AppTheme.vermelhoTomate;
          resultIcon =
              Icons.coronavirus_outlined; // Ícone de alerta para doença
        }

        return SingleChildScrollView(
          // Adicionado para evitar quebra de tela em telas menores
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NOVO: Ícone visual de feedback
              Icon(resultIcon, size: 48, color: color),
              const SizedBox(height: 8),

              // NOVO: Texto muda de acordo com o contexto
              Text(
                isUnrecognized ? 'Atenção' : 'Diagnóstico Concluído',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.predictedClass!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '(${viewModel.translatedClass ?? 'Calculando...'})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),

              // Nova Barra de Progresso!
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Confiança:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(viewModel.confidence! * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: viewModel.confidence!, // Vai de 0.0 a 1.0
                        backgroundColor: Colors.grey[300],
                        color: color,
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.read<InferenceViewModel>().reset(),
                icon: const Icon(Icons.replay),
                label: const Text('Fazer Nova Análise'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.verdeFolha,
                ),
              ),
            ],
          ),
        );

      case ViewState.error:
        return Center(
          child: Text(
            viewModel.errorMessage ?? 'Ocorreu um erro desconhecido.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.vermelhoTomate),
          ),
        );
    }
  }
}
