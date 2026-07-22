import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';


class AppRefreshIndicator extends StatefulWidget {
  /// Callback que dispara la recarga de datos de la pantalla.
  final Future<void> Function() onRefresh;

  /// Contenido scrolleable (ScrollView, CustomScrollView, ListView, etc.)
  final Widget child;

  /// Color del spinner. Por defecto usa el color secundario de la app.
  final Color color;

  /// Color de fondo del círculo del indicador.
  final Color backgroundColor;

  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color = Colors.white,
    this.backgroundColor = AppColors.secondaryColor,
  });

  @override
  State<AppRefreshIndicator> createState() => _AppRefreshIndicatorState();
}

class _AppRefreshIndicatorState extends State<AppRefreshIndicator> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    // Evita disparar dos refrescos en paralelo.
    if (_isRefreshing) return;

    _isRefreshing = true;
    HapticFeedback.lightImpact();

    try {
      await widget.onRefresh();
    } finally {
      // mounted se revisa por si la pantalla se destruyó durante el await.
      if (mounted) {
        _isRefreshing = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.color,
      backgroundColor: widget.backgroundColor,
      strokeWidth: 2.5,
      displacement: 50,
      child: widget.child,
    );
  }
}
