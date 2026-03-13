import 'package:flutter/material.dart';

class AppColors {
  // Main Background Gradient
  static const Color backgroundTop = Color(0xFF6B1B29); // Deep Red/Burgundy
  static const Color backgroundBottom = Color(0xFFEBCACF); // Light Pink

  // SmartEye Home Theme
  static const Color smarteyeBgTop = Color(0xFF5A000A); // Deep Burgundy
  static const Color smarteyeBgBottom = Color(0xFFB00010); // True Red

  // Healthcare Theme (Soft Pink)
  static const Color healthcareBgTop = Color(0xFFFFEBEF); // Shell Pink
  static const Color healthcareBgBottom = Color(0xFFFFFFFF); // White
  static const Color healthcareTextPrimary = Color(0xFF333333); // Dark Charcoal
  static const Color healthcareTextSecondary = Color(0xFF666666); // Grey
  static const Color healthcareAccent = Color(0xFFE91E63); // Rose Pink

  // Dark Pink Theme
  static const Color darkPinkBgTop = Color(0xFFAD1457); // Deep Rose
  static const Color darkPinkBgBottom = Color(0xFF880E4F); // Darker Rose
  static const Color titlePink = Color(0xFFF48FB1); // Soft Pink for Typography

  // Button Gradients
  static const Color buttonRedStart = Color(0xFFCE3A41);
  static const Color buttonRedEnd = Color(0xFF711821);

  static const Color buttonOrangeStart = Color(0xFFFF5F6D);
  static const Color buttonOrangeEnd = Color(0xFFFFC371);

  // Blind Dashboard Colors
  static const Color dashboardBg = Color(0xFF1A111A);
  static const Color dashboardCardDark = Color(0xFF3B1F2B);
  static const Color dashboardCardPink = Color(0xFFD386A8);
  static const Color dashboardEmergencyRed = Color(0xFFE53935);
  static const Color dashboardEmergencyDarkRed = Color(0xFFB71C1C);

  // Voice Message Colors
  static const Color voiceCancelBg = Color(0xFF2C1B28);
  static const Color voiceSendStart = Color(0xFFF06292);
  static const Color voiceSendEnd = Color(0xFFF4511E);

  // Text Colors
  static const Color textLight = Colors.white;
  static const Color textDark = Color(0xFF4A1523); // Dark purple/red

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
    colors: [Color(0xFF5A000A), Colors.white],
  );

  static const LinearGradient healthcareBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [healthcareBgTop, healthcareBgBottom],
  );

  static const LinearGradient healthcareButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF48FB1), Color(0xFFAD1457)], // Soft Rose to Deep Rose
  );

  static const LinearGradient darkPinkBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkPinkBgTop, darkPinkBgBottom],
  );

  static const LinearGradient whiteRoseGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, Color(0xFFFFC1CC)], // White to Rose Pink
  );

  // Caretaker Specific
  static const Color caretakerBgTop = Color(0xFF800020);
  static const Color caretakerBgBottom = Color(0xFFDC143C);

  static const LinearGradient caretakerBackgroundGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [caretakerBgTop, caretakerBgBottom],
  );

  static const LinearGradient caretakerButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, Color(0xFFFF5733)],
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
