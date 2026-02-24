import 'package:flutter/material.dart';

/// App-wide accent color for primary actions (equip, selected state, FABs, etc.).
const Color kAppAccent = Colors.amber;

/// Dark theme with amber as primary/accent. Use [kAppAccent] or theme for consistency.
ThemeData get appDarkTheme => ThemeData(
      colorScheme: ColorScheme.dark(
        primary: kAppAccent,
        secondary: Colors.amber.shade700,
        surface: Colors.grey.shade900,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      brightness: Brightness.dark,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 17),
        bodyMedium: TextStyle(fontSize: 16),
        bodySmall: TextStyle(fontSize: 14),
        titleLarge: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        labelLarge: TextStyle(fontSize: 15),
        labelMedium: TextStyle(fontSize: 14),
        labelSmall: TextStyle(fontSize: 12),
      ),
    );
