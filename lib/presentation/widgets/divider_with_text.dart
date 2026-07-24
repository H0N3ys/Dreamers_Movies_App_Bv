import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final Color color;

  const DividerWithText({
    required this.text,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: color.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: color.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
