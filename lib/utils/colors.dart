import 'package:flutter/material.dart';

class AppColors {
  // ── Red Palette (300–800) ──
  static const Color red300 = Color(0xFFFF9696);
  static const Color red400 = Color(0xFFFF5A5A);
  static const Color red500 = Color(0xFFFF2626);
  static const Color red600 = Color(0xFFFC0606);
  static const Color red700 = Color(0xFFD40101);
  static const Color red800 = Color(0xFFAF0505);

  // Main Background Gradient
  static const Color backgroundTop = Color(0xFFAF0505);     // 800
  static const Color backgroundBottom = Color(0xFFFF9696);   // 300

  // SmartEye Home Theme
  static const Color smarteyeBgTop = Color(0xFFD40101);     // 700
  static const Color smarteyeBgBottom = Color(0xFFFF2626);   // 500

  // Healthcare Theme
  static const Color healthcareBgTop = Color(0xFFFF9696);   // 300
  static const Color healthcareBgBottom = Color(0xFFFFFFFF); // White
  static const Color healthcareTextPrimary = Color(0xFF333333);
  static const Color healthcareTextSecondary = Color(0xFF666666);
  static const Color healthcareAccent = Color(0xFFFC0606);   // 600

  // Dark Theme
  static const Color darkPinkBgTop = Color(0xFFD40101);     // 700
  static const Color darkPinkBgBottom = Color(0xFFAF0505);   // 800
  static const Color titlePink = Color(0xFFFF9696);          // 300

  // Button Gradients
  static const Color buttonRedStart = Color(0xFFFC0606);    // 600
  static const Color buttonRedEnd = Color(0xFFAF0505);       // 800

  static const Color buttonOrangeStart = Color(0xFFFF5A5A); // 400
  static const Color buttonOrangeEnd = Color(0xFFFF9696);   // 300

  // Blind Dashboard Colors (UNCHANGED)
  static const Color dashboardBg = Color(0xFF1A111A);
  static const Color dashboardCardDark = Color(0xFF3B1F2B);
  static const Color dashboardCardPink = Color(0xFFD386A8);
  static const Color dashboardEmergencyRed = Color(0xFFE53935);
  static const Color dashboardEmergencyDarkRed = Color(0xFFB71C1C);

  // Voice Message Colors (UNCHANGED)
  static const Color voiceCancelBg = Color(0xFF2C1B28);
  static const Color voiceSendStart = Color(0xFFF06292);
  static const Color voiceSendEnd = Color(0xFFF4511E);

  // Text Colors
  static const Color textLight = Colors.white;
  static const Color textDark = Color(0xFFAF0505); // 800

  // Glassmorphism Values
  static const Color glassWhite = Colors.white;
  static const double glassOpacityLight = 0.2;
  static const double glassOpacityMedium = 0.4;
  static const double glassBlur = 15.0;

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundBottom],
  );

  static const LinearGradient buttonRedGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [buttonRedStart, buttonRedEnd],
  );

  static const LinearGradient buttonOrangeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [buttonOrangeStart, buttonOrangeEnd],
  );

  static const LinearGradient smarteyeHomeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [smarteyeBgTop, smarteyeBgBottom],
  );

  static const LinearGradient smarteyeButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFD40101), Colors.white], // 700 to white
  );

  static const LinearGradient healthcareBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [healthcareBgTop, healthcareBgBottom],
  );

  static const LinearGradient healthcareButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF5A5A), Color(0xFFAF0505)], // 400 to 800
  );

  static const LinearGradient darkPinkBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkPinkBgTop, darkPinkBgBottom],
  );

  static const LinearGradient whiteRoseGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, Color(0xFFFF9696)], // White to 300
  );

  // Caretaker Specific
  static const Color caretakerBgTop = Color(0xFFAF0505);    // 800
  static const Color caretakerBgBottom = Color(0xFFD40101);  // 700

  static const LinearGradient caretakerBackgroundGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [caretakerBgTop, caretakerBgBottom],
  );

  static const LinearGradient caretakerButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, Color(0xFFFC0606)], // White to 600
  );

  static const LinearGradient voiceSendGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [voiceSendStart, voiceSendEnd],
  );

  static const LinearGradient emergencyRedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [dashboardEmergencyRed, dashboardEmergencyDarkRed],
  );
}
