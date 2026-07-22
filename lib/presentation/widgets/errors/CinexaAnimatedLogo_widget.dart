import 'package:flutter/material.dart';
import 'dart:math' as math;

enum CinexaErrorType { notFound404, noConnection, server500 }

class CinexaAnimatedLogo extends StatefulWidget {
  final CinexaErrorType errorType;
  final double size;

  const CinexaAnimatedLogo({
    super.key,
    required this.errorType,
    this.size = 150.0,
  });

  @override
  State<CinexaAnimatedLogo> createState() => _CinexaAnimatedLogoState();
}

class _CinexaAnimatedLogoState extends State<CinexaAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Configuramos la duración dependiendo del efecto
    Duration duration;
    switch (widget.errorType) {
      case CinexaErrorType.notFound404:
        duration = const Duration(seconds: 4); // Giro lento y continuo
        break;
      case CinexaErrorType.noConnection:
        duration = const Duration(seconds: 1); // Latido constante
        break;
      case CinexaErrorType.server500:
        duration = const Duration(milliseconds: 100); // Temblor muy rápido
        break;
    }

    _controller = AnimationController(vsync: this, duration: duration);

    // Configuramos cómo se comporta la animación
    if (widget.errorType == CinexaErrorType.notFound404) {
      // El giro de 404 va en una sola dirección de 0 a 1 infinitamente
      _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
      _controller.repeat(); 
    } else if (widget.errorType == CinexaErrorType.noConnection) {
      // El latido va y viene (escala de 0.8 a 1.1)
      _animation = Tween<double>(begin: 0.85, end: 1.15).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.repeat(reverse: true);
    } else {
      // El temblor del 500 va de un lado a otro (-5 a 5 píxeles)
      _animation = Tween<double>(begin: -5, end: 5).animate(_controller);
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // ¡Súper importante para no gastar memoria!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reemplaza esto con la ruta real de tu logo en assets
    Widget logoImage = Image.asset(
      'assets/images/logoBueno.png', 
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
    );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        switch (widget.errorType) {
          
          case CinexaErrorType.notFound404:
            // Rota la imagen 360 grados infinitamente
            return Transform.rotate(
              angle: _animation.value * 2 * math.pi,
              child: child,
            );
            
          case CinexaErrorType.noConnection:
            // Escala (agranda y achica) la imagen
            return Transform.scale(
              scale: _animation.value,
              child: child,
            );
            
          case CinexaErrorType.server500:
            // Traslada (mueve de izquierda a derecha) la imagen
            return Transform.translate(
              offset: Offset(_animation.value, 0),
              child: child,
            );
        }
      },
      child: logoImage,
    );
  }
}