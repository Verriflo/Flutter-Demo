import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';

/*
 * Verriflo Classroom Demo
 * 
 * Demonstrates integration of the Verriflo classroom SDK for Flutter.
 * This app shows how to:
 * - Join a live classroom using organization and room IDs
 * - Handle SDK events (class ended, kicked, connection state)
 * - Control video quality settings
 * - Implement fullscreen mode with chat overlay
 * 
 * For SDK documentation, see: https://docs.verriflo.com/sdk/flutter
 */

void main() {
  // Match status bar to app theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
  ));

  runApp(const VerrifloClassroomApp());
}

/*
 * Root application widget.
 * 
 * Sets up the Material 3 theme with Verriflo brand colors.
 * Uses dark theme throughout for optimal video viewing.
 */
class VerrifloClassroomApp extends StatelessWidget {
  const VerrifloClassroomApp({super.key});

  static const _primaryColor = Color(0xFF6B48FF);
  static const _surfaceColor = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verriflo Classroom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.dark(
          primary: _primaryColor,
          secondary: const Color(0xFF00E5FF),
          surface: _surfaceColor,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryColor, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
