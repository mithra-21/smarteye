import 'package:flutter/material.dart';
import 'dart:ui' as dart_ui;
import '../widgets/glass_card.dart';
import '../utils/colors.dart';
import 'caretaker_login_screen.dart';
import 'blind_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    // Smooth heart pump animation for the logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _logoAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.whiteRoseGradient, // White to Rose Pink
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- Background Glow Effect ---
            Positioned(
              top: -screenWidth * 0.2,
              right: -screenWidth * 0.2,
              child: Container(
                width: screenWidth * 0.8,
                height: screenWidth * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.healthcareAccent.withOpacity(0.05),
                ),
              ),
            ),

            // --- Layer 1: Characters (Static) ---
            Positioned(
              top: screenHeight * 0.15 + 30, // Adjusted to user's last preference
              child: Image.asset(
                'assets/images/home_character.png',
                height: screenHeight * 0.5,
                fit: BoxFit.contain,
              ),
            ),

            // --- Layer 2: Bubble Logo (Always centered) ---
            Positioned(
              top: screenHeight * 0.15 + 30,
              left: 0,
              right: 0,
              child: Center(
                child: RepaintBoundary(
                  child: ScaleTransition(
                    scale: _logoAnimation,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.1),
                          ],
                          center: const Alignment(-0.3, -0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- Layer 3: GlassCard (Overlapping characters) ---
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: dart_ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Choose Your Role',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.healthcareTextPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Empowering your independence',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.healthcareTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _InteractiveButton(
                            text: 'Blind Login',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const BlindScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _InteractiveButton(
                            text: 'Caretaker Login',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CaretakerLoginScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- Layer 4: Floating Title ---
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              child: Text(
                'SmartEye',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.healthcareAccent, // Changed to Rose Pink
                  letterSpacing: 2.0,
                ),
              ),
            ),

            // --- Layer 5: Footer ---
            Positioned(
              bottom: 15,
              child: Text(
                'Powered by BTech Project',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.healthcareTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _InteractiveButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<_InteractiveButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 1.05),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: AppColors.healthcareButtonGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.healthcareAccent.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(flex: 2),
              const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
