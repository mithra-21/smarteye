import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../utils/colors.dart';
import 'blind_sign_up_screen.dart';
import 'blind_dashboard_screen.dart';

class BlindScreen extends StatelessWidget {
  const BlindScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback color
      body: Stack(
        children: [
          // Background Image Layer (Full Screen)
          Positioned.fill(
            child: Image.asset(
              'assets/images/blind1.png', // Corrected asset name based on user request
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // High-quality fallback gradient if image is missing
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF2D161A), Color(0xFF1A111A)],
                    ),
                  ),
                );
              },
            ),
          ),

          // Top Layer: Quote with shadow for readability
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: Column(
                children: [
                   Text(
                    "Keep your face to the sunshine and you cannot see the shadows.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia', // Serif-style font
                      fontSize: 22,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 20,
                          offset: const Offset(0, 0),
                        ),
                        Shadow(
                          color: const Color(0xFFFFE0B2).withOpacity(0.8),
                          blurRadius: 30,
                          offset: const Offset(0, 0),
                        ),
                        Shadow(
                          color: Colors.orangeAccent.withOpacity(0.5),
                          blurRadius: 50,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Layer: Sign In/Sign Up Glassmorphism Card (Positioned at bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10), // User requested sigma 10
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25), // Dark translucency
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Smart Eye",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Sign In Button (The main action)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BlindDashboardScreen()),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD85D5D), Color(0xFF9E2A2A)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Icon(Icons.check_circle_outline, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Navigation to Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Need Account? ",
                              style: TextStyle(color: Colors.white60, fontSize: 16),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const BlindSignUpScreen()),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Inputs (Glass-styled placeholders)
                        _buildInputField(Icons.alternate_email, "Email Address"),
                        const SizedBox(height: 16),
                        _buildInputField(Icons.fingerprint, "Password"),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(IconData icon, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white24,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white54, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
