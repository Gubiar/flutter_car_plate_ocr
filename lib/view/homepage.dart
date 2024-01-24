import 'package:flutter/material.dart';
import 'package:placa_recognise/view/text_detector_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TextRecognizerView()),
                );
              },
              child: const Text('Text Recognition'))
        ],
      ),
    );
  }
}
