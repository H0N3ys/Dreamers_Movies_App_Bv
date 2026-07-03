import 'package:flutter/services.dart';

class NameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si está vacío, retornar vacío
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Dividir el texto en palabras
    final words = newValue.text.split(' ');
    final List<String> formattedWords = [];

    for (String word in words) {
      if (word.isEmpty) {
        formattedWords.add('');
        continue;
      }

      if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ]+$').hasMatch(word)) {
        return oldValue;
      }

      final String formattedWord = 
          word[0].toUpperCase() + word.substring(1).toLowerCase();
      
      formattedWords.add(formattedWord);
    }

    final String formattedText = formattedWords.join(' ');

    int newCursorPosition = newValue.selection.baseOffset;
    
    if (newCursorPosition > formattedText.length) {
      newCursorPosition = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}

class NameBlockFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final RegExp validNamePattern = RegExp(
      r'^[A-ZÁÉÍÓÚÑ][a-záéíóúñ]*(?:\s[A-ZÁÉÍÓÚÑ][a-záéíóúñ]*)*$'
    );

    if (validNamePattern.hasMatch(newValue.text)) {
      return newValue;
    }

    if (newValue.text.endsWith(' ')) {
      // Verificar que lo anterior sea válido
      final String beforeSpace = newValue.text.substring(0, newValue.text.length - 1);
      if (beforeSpace.isEmpty || validNamePattern.hasMatch(beforeSpace)) {
        return newValue;
      }
    }

    final words = newValue.text.split(' ');
    final List<String> formattedWords = [];

    for (String word in words) {
      if (word.isEmpty) {
        formattedWords.add('');
        continue;
      }

      if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ]+$').hasMatch(word)) {
        return oldValue;
      }

      final String formattedWord = 
          word[0].toUpperCase() + word.substring(1).toLowerCase();
      
      formattedWords.add(formattedWord);
    }

    final String formattedText = formattedWords.join(' ');

    int newCursorPosition = newValue.selection.baseOffset;
    if (newCursorPosition > formattedText.length) {
      newCursorPosition = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}

class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Permitir solo caracteres válidos para email
    final RegExp validChars = RegExp(r'^[a-zA-Z0-9._%+-@]*$');
    
    if (validChars.hasMatch(newValue.text)) {
      return newValue;
    }
    
    // Si el carácter no es válido, retornar el valor anterior
    return oldValue;
  }
}