# 🍅 TomatoViT (Detecção de Doenças Foliares em Tomateiro)

![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![TFLite](https://img.shields.io/badge/TensorFlow_Lite-Edge_AI-FF6F00?logo=tensorflow)
![Status](https://img.shields.io/badge/Status-Concluído-success)

Aplicativo mobile desenvolvido como Projeto Final de Curso (PFC2) em Engenharia de Computação. O objetivo é fornecer a produtores rurais e agrônomos uma ferramenta de diagnóstico instantâneo e **totalmente offline** para doenças em folhas de tomateiro, utilizando Inteligência Artificial na borda (Edge Computing) e Vision Transformers.

---

## 📱 Visão Geral e Funcionalidades

O aplicativo captura imagens (via câmera ou galeria), processa os tensores nativamente no dispositivo e classifica a folha em uma das 10 categorias baseadas no dataset *PlantVillage* (9 doenças e 1 saudável), apresentando o laudo com tradução para português e o grau de confiança da rede neural.

* 📸 **Captura Integrada:** Suporte para câmera e galeria do dispositivo.
* 🧠 **Inferência Offline:** Processamento local sem necessidade de conexão com a internet.
* ⚡ **Alta Performance:** Utilização de modelo quantizado (FP16) para otimização de RAM e processamento em smartphones.
* 🎨 **Interface Responsiva:** Feedback visual de estados baseado na confiabilidade da predição.

---

## 🛠️ Arquitetura e Tecnologias

O projeto foi construído utilizando **Flutter** e segue princípios da **Clean Architecture** combinada com o padrão **MVVM (Model-View-ViewModel)** para garantir a separação de responsabilidades:

* **UI/Presentation Layer (`screens/`, `viewmodels/`):** Construída com widgets do Flutter. O gerenciamento de estado reativo é feito exclusivamente pelo pacote **Provider**, garantindo que a interface reaja fluidamente às mudanças de estado da IA.
* **Domain Layer (`entities/`):** Contém as regras de negócio puras, como a entidade `ClassificationResult` que unifica os dados do laudo.
* **Data Layer (`services/`):** Onde reside o `TFLiteService`. Isola a complexidade da manipulação de ponteiros C++ e buffers de imagem (redimensionamento para 224x224, normalização ImageNet e ArgMax) do restante do aplicativo.

### Modelo de Inteligência Artificial
* **Arquitetura:** MobileViT-S (Vision Transformer leve otimizado para dispositivos móveis).
* **Quantização:** Float16 (FP16) via TensorFlow Lite, reduzindo o tamanho do modelo sem perda significativa de acurácia.
* **Dataset de Origem:** PlantVillage (Recorte específico para a cultura do tomate).

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.0 ou superior).
* Dispositivo físico Android/iOS ou Emulador configurado.

### Passos para Instalação

1. Clone este repositório:
   ```bash
   git clone [https://github.com/lucasvitorrt/tomato_vit.git](https://github.com/lucasvitorrt/tomato_vit.git)

2. Navegue até o diretório do projeto:
    ```Bash
    cd nome-do-repositorio

3. Baixe as dependências do Flutter:
    ```Bash
    flutter pub get

4. Importante: Devido a restrições do GitHub, o  arquivo de pesos do modelo IA (mobilevit_s_fp16.tflite) pode não estar no repositório. Certifique-se de colocar o arquivo do modelo dentro da pasta assets/ na raiz do projeto.

5. Execute o aplicativo:
    ```Bash
    flutter run