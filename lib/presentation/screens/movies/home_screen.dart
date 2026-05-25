import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {

  // Sirve para rutas de navegacion
  static const name = 'home--screen'; //nombre ala cual podremos llegar a este componente

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Placeholder(),
    );
  }
}