// save_confirmation_overlay.dart
import 'package:flutter/material.dart';

class SaveConfirmationOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isSaving; // true = guardar, false = quitar guardado

  const SaveConfirmationOverlay({
    super.key,
    required this.onComplete,
    this.isSaving = true,
  });

  @override
  State<SaveConfirmationOverlay> createState() => _SaveConfirmationOverlayState();
}

class _SaveConfirmationOverlayState extends State<SaveConfirmationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // Auto-cerrar después de 1.8 segundos
    Future.delayed(const Duration(milliseconds: 1800), () {
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
                color: Colors.black.withOpacity(_opacityAnimation.value * 0.4),
              ),
              // Animación principal
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * (widget.isSaving ? 1 : -1),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: (widget.isSaving ? Colors.amber : Colors.red).withOpacity(_opacityAnimation.value * 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isSaving ? Colors.amber : Colors.red).withOpacity(0.5 * _opacityAnimation.value),
                            blurRadius: 40,
                            spreadRadius: 20 * _opacityAnimation.value,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Icono principal
                          Icon(
                            widget.isSaving ? Icons.bookmark_rounded : Icons.bookmark_remove_rounded,
                            color: Colors.white,
                            size: 60 * _scaleAnimation.value,
                          ),
                          // Animación de partículas para quitar guardado
                          if (!widget.isSaving)
                            ...List.generate(8, (index) {
                              final angle = (index / 8) * 2 * 3.14159;
                              final distance = 40 * (1 - _opacityAnimation.value) * 1.5;
                              return Positioned(
                                left: 30 + distance * (1 - _scaleAnimation.value) * 0.5,
                                top: 30 + distance * (1 - _scaleAnimation.value) * 0.5,
                                child: Transform.translate(
                                  offset: Offset(
                                    (30 + distance) * (1 - _opacityAnimation.value) * 1.5 * (1 - _scaleAnimation.value),
                                    (30 + distance) * (1 - _opacityAnimation.value) * 1.5 * (1 - _scaleAnimation.value),
                                  ),
                                  child: Opacity(
                                    opacity: (1 - _opacityAnimation.value),
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.white.withOpacity(0.6),
                                      size: 8 * (1 + _scaleAnimation.value * 0.5),
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
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
                    child: Column(
                      children: [
                        Text(
                          widget.isSaving ? '' : '',
                          style: const TextStyle(
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
                        if (!widget.isSaving)
                          const Text(
                            '',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black38,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                      ],
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