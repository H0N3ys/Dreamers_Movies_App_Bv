import 'package:flutter/material.dart';
import 'styles.dart';  

extension TextStyleFonts on TextStyle {
  TextStyle get withPrimaryFont => copyWith(fontFamily: AppTheme.primaryFont);
  TextStyle get withSecondaryFont => copyWith(fontFamily: AppTheme.secondaryFont);
}


extension TextWidgetFonts on Text {
  Text withPrimaryFont() {
    return Text(
      data!,
      style: style?.copyWith(fontFamily: AppTheme.primaryFont),
    );
  }
}