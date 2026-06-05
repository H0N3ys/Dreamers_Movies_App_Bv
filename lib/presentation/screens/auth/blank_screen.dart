import 'package:flutter/material.dart';

class BlankScreen extends StatelessWidget {
  static const name = 'blank-screen';

  const BlankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            'Pantalla en blanco',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}