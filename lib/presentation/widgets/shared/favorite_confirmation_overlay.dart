import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Importación de la librería Pro

class FavoriteConfirmationOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isBreaking;

  const FavoriteConfirmationOverlay({
    super.key, 
    required this.onComplete, 
    this.isBreaking = false,
  });

  @override
  State<FavoriteConfirmationOverlay> createState() => _FavoriteConfirmationOverlayState();
}

class _FavoriteConfirmationOverlayState extends State<FavoriteConfirmationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    
    // Aquí configuramos la velocidad exacta: 1.5 segundos (1500 milisegundos)
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    
    // Iniciamos la animación y cuando termine, cerramos el overlay con elegancia
    _controller.forward().then((_) {
      if (mounted) {
        setState(() => _isClosing = true); // Inicia el desvanecimiento
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) widget.onComplete(); // Remueve el widget después de desvanecerse
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedOpacity(
          // Duración del desvanecimiento final
          duration: const Duration(milliseconds: 300), 
          opacity: _isClosing ? 0.0 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Fondo oscuro translúcido
              color: widget.isBreaking ? Colors.grey.shade900.withOpacity(0.9) : Colors.black.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.isBreaking ? const Color.fromARGB(51, 255, 255, 255) : Colors.redAccent.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                )
              ]
            ),
            // REPRODUCTOR LOTTIE
            child: Lottie.asset(
              widget.isBreaking 
                  ? 'assets/animations/heart_break.json' 
                  : 'assets/animations/heart_beat.json',
              controller: _controller,
              width: 120, // Tamaño de la animación
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}