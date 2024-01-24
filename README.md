# Placa Recognise

## Descrição

O Placa Recognise é um aplicativo Flutter que utiliza o kit de ML do Google para identificar placas de carros brasileiros, tanto no padrão antigo quanto no padrão Mercosul, através da câmera do dispositivo.

## Versão

1.0.0+1

## SDK

O aplicativo requer um SDK Flutter de '>=3.2.3 <4.0.0'.

## Dependências

O aplicativo depende das seguintes bibliotecas:

- flutter: sdk: flutter
- cupertino_icons: ^1.0.2
- google_mlkit_commons: ^0.6.1
- google_mlkit_text_recognition: ^0.11.0
- camera: ^0.10.5+9
- path_provider: ^2.1.2
- get: ^4.6.6
- flutter_multi_formatter: ^2.12.4

## Dependências de desenvolvimento

As dependências de desenvolvimento incluem:

- flutter_test: sdk: flutter
- flutter_lints: ^2.0.0

## Recursos

O aplicativo usa design material e inclui ativos do diretório 'assets/'.

## Como usar

Para usar o aplicativo, basta apontar a câmera do dispositivo para a placa do carro. O aplicativo irá identificar e exibir o texto da placa.

## Como executar a aplicação

1. Clone o repositório para a sua máquina local usando `git clone`.
2. Navegue até a pasta do projeto usando `cd placa_recognise`.
3. Execute `flutter pub get` para baixar as dependências do projeto.
4. Certifique-se de que um dispositivo (emulador ou físico) esteja rodando. Verifique usando `flutter devices`.
5. Execute `flutter run` para iniciar a aplicação.
