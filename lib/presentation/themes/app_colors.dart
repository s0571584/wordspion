import 'package:flutter/material.dart';

class AppColors {
  // Private Konstruktor, um Instanziierung zu verhindern
  AppColors._();
  
  // Primäre Farben
  static const Color primary = Color(0xFF3F51B5);        // Indigo
  static const Color primaryLight = Color(0xFF757DE8);   // Helles Indigo
  static const Color primaryDark = Color(0xFF002984);    // Dunkles Indigo
  
  // Akzentfarben
  static const Color accent = Color(0xFFFF4081);         // Pink
  static const Color accentLight = Color(0xFFFF79B0);    // Helles Pink
  static const Color accentDark = Color(0xFFC60055);     // Dunkles Pink
  
  // Semantische Farben
  static const Color team = Color(0xFF4CAF50);           // Grün für Team
  static const Color impostor = Color(0xFFF44336);       // Rot für Spione
  static const Color saboteur = Color(0xFFFF9800);       // Orange für Saboteure
  
  // Status Farben
  static const Color success = Color(0xFF4CAF50);        // Erfolg
  static const Color error = Color(0xFFF44336);          // Fehler
  static const Color warning = Color(0xFFFF9800);        // Warnung
  static const Color info = Color(0xFF2196F3);           // Information
  
  // UI Farben
  static const Color onPrimary = Color(0xFFFFFFFF);      // Text auf Primary
  static const Color onAccent = Color(0xFFFFFFFF);       // Text auf Accent
  static const Color outline = Color(0xFFE0E0E0);        // Umrandungen
  static const Color divider = Color(0xFFE0E0E0);        // Trennlinien
  
  // Neutralfarben
  static const Color background = Color(0xFFF5F5F5);     // Hintergrund
  static const Color surface = Color(0xFFFFFFFF);        // Oberflächen
  static const Color onSurface = Color(0xFF212121);      // Text auf Oberflächen
  static const Color onBackground = Color(0xFF212121);   // Text auf Hintergrund
  
  // Hilfsfunktionen
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
