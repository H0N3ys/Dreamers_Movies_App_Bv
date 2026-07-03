import 'package:flutter/services.dart';

class EmailBlockFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Bloquear caracteres no permitidos
    final RegExp validChars = RegExp(r'^[a-zA-Z0-9._%+-@]*$');
    if (!validChars.hasMatch(newValue.text)) {
      return oldValue;
    }
    
    // Bloquear puntos consecutivos
    if (newValue.text.contains('..') || 
        newValue.text.contains('.@') || 
        newValue.text.contains('@.')) {
      return oldValue;
    }
    
    // BLOQUEAR .com.com EN TIEMPO REAL
    if (newValue.text.contains('@')) {
      final parts = newValue.text.split('@');
      if (parts.length == 2) {
        final domain = parts[1];
        final domainParts = domain.split('.');
        
        // Si el dominio tiene 3+ partes, verificar que no sea .com.com
        if (domainParts.length >= 3) {
          final lastTwo = domainParts.sublist(domainParts.length - 2);
          final secondLast = lastTwo[0].toLowerCase();
          final commonTlds = ['com', 'org', 'net', 'edu', 'gov', 'mil'];
          
          // Bloquear si la penúltima parte es un TLD común
          if (commonTlds.contains(secondLast)) {
            return oldValue;
          }
        }
      }
    }
    
    return newValue;
  }
}