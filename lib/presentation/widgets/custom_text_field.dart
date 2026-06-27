import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 IMPORTANTE: Agregado para los InputFormatters

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  
  // 👈 NUEVA VARIABLE PARA FILTRAR EL TECLADO
  final List<TextInputFormatter>? inputFormatters; 

  const CustomTextField({
    super.key,
    required this.label,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onEditingComplete,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters, // 👈 Se agrega al constructor
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final obscureNotifier = ValueNotifier<bool>(obscureText);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        ValueListenableBuilder<bool>(
          valueListenable: obscureNotifier,
          builder: (context, isObscured, child) {
            return TextFormField(
              controller: controller,
              obscureText: isObscured,
              keyboardType: keyboardType,
              onChanged: onChanged,
              onFieldSubmitted: onSubmitted,
              validator: validator,
              enabled: enabled,
              textInputAction: textInputAction,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              maxLines: obscureText ? 1 : maxLines,
              minLines: minLines,
              
              // 👇 AQUÍ SE APLICAN LAS REGLAS DE LÍMITE Y FORMATO
              maxLength: maxLength,
              inputFormatters: inputFormatters, 
              
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: hintText,
                errorText: errorText,
                counterText: '', // 👈 Esto oculta el texto feo de "0/10" debajo del campo
                prefixIcon: icon != null ? Icon(icon, size: 22) : null,
                suffixIcon: obscureText
                    ? GestureDetector(
                        onTap: () {
                          obscureNotifier.value = !obscureNotifier.value;
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            isObscured
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 22,
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.35,
                            ),
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}