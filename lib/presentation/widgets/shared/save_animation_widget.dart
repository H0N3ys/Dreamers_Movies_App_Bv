import 'package:flutter/material.dart';

class SaveAnimationWidget extends StatefulWidget {
  final bool isSaved;
  final VoidCallback onTap;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const SaveAnimationWidget({
    super.key,
    required this.isSaved,
    required this.onTap,
    this.size = 28,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<SaveAnimationWidget> createState() => _SaveAnimationWidgetState();
}

class _SaveAnimationWidgetState extends State<SaveAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    // Iniciar animación al hacer tap
    _animationController.forward(from: 0.0);
    // Regresar después de la animación
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Icon(
                widget.isSaved 
                    ? Icons.bookmark_rounded 
                    : Icons.bookmark_border_rounded,
                color: widget.isSaved 
                    ? (widget.activeColor ?? Colors.amber) 
                    : (widget.inactiveColor ?? Colors.white54),
                size: widget.size,
              ),
            ),
          );
        },
      ),
    );
  }
}