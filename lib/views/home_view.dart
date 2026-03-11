import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/scanner_viewmodel.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Inicia o carregamento do modelo assim que a tela abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScannerViewModel>(context, listen: false).initModel();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças do ViewModel
    final viewModel = Provider.of<ScannerViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('PFC2 - MobileViT Tomate'),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Área de exibição da imagem
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: viewModel.selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          viewModel.selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(Icons.image, size: 100, color: Colors.grey[400]),
              ),
              SizedBox(height: 30),

              // Área de exibição do resultado
              if (viewModel.isLoading)
                CircularProgressIndicator()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    viewModel.predictionResult,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              SizedBox(height: 40),

              // Botões de Ação
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text('Tirar Foto'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onPressed: () => viewModel.pickImage(ImageSource.camera),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.photo_library),
                    label: Text('Galeria'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onPressed: () => viewModel.pickImage(ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
