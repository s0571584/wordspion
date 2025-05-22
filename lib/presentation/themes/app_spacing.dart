import 'package:flutter/material.dart';

class AppSpacing {
  // Private Konstruktor, um Instanziierung zu verhindern
  AppSpacing._();
  
  // Standardabstände
  static const double xxxs = 2.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double s = 12.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // Bildschirmränder
  static const EdgeInsets screenPadding = EdgeInsets.all(m);
  static const EdgeInsets cardPadding = EdgeInsets.all(m);
  
  // Komponentenabstände
  static const double buttonHeight = 56.0;
  static const double cardBorderRadius = 12.0;
  static const double inputHeight = 56.0;
  
  // Hilfsfunktionen für Abstände
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    
    return EdgeInsets.only(
      left: left ?? horizontal ?? 0.0,
      top: top ?? vertical ?? 0.0,
      right: right ?? horizontal ?? 0.0,
      bottom: bottom ?? vertical ?? 0.0,
    );
  }
  
  // Hilfsfunktionen für Abstände
  static EdgeInsets paddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }
}
