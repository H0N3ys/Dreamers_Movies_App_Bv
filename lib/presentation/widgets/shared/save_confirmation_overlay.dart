import 'package:flutter/material.dart';

class SaveConfirmationOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const SaveConfirmationOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<SaveConfirmationOverlay> createState() => _SaveConfirmationOverlayState();
}

class _SaveConfirmationOverlayState extends State<SaveConfirmationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Auto-cerrar después de 1.5 segundos
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _animationController.reverse().then((_) {
          widget.onComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return IgnorePointer(
          child: Stack(
            children: [
              // Fondo semitransparente
              Container(
                color: Colors.black.withOpacity(_opacityAnimation.value * 0.3),
              ),
              // Animación del ícono
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _scaleAnimation.value * 0.3,
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(_opacityAnimation.value * 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5 * _opacityAnimation.value),
                            blurRadius: 40,
                            spreadRadius: 20 * _opacityAnimation.value,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.bookmark_rounded,
                        color: Colors.white,
                        size: 60 * _scaleAnimation.value,
                      ),
                    ),
                  ),
                ),
              ),
              // Texto de confirmación
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: const Text(
                      '¡Guardado! 📚',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black38,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}