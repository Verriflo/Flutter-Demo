import 'package:flutter/material.dart';

import 'join_screen.dart';
import '../widgets/gradient_button.dart';

/*
 * Home Screen
 * 
 * Landing page showcasing the SDK demo app.
 * Provides entry point to the join flow.
 */
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF320757),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Logo with ambient glow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF320757).withValues(alpha: 0.8),
                        blurRadius: 60,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                  child: Image.asset('assets/logo.png', height: 120),
                ),

                const SizedBox(height: 24),

                // App title
                const Text(
                  'Verriflo Classroom',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                const Text(
                  'Experience the future of live learning.\nSeamless, interactive, and powerful.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                // CTA button
                GradientButton(
                  text: 'Test Connection',
                  onPressed: () => _navigateToJoinScreen(context),
                ),

                const SizedBox(height: 16),

                // Version label
                const Text(
                  'SDK Demo v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToJoinScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const JoinScreen()),
    );
  }
}
