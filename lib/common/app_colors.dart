import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  // Modern Professional Color Palette
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  
  // Primary Brand Colors - Professional & Modern
  static const Color primaryNavy = Color(0xFF1e3a8a);      // Deep professional blue
  static const Color primaryBlue = Color(0xFF3b82f6);      // Bright blue
  static const Color primary = primaryNavy;                 // Main brand color
  
  // Accent Colors - Vibrant & Professional
  static const Color accentPurple = Color(0xFF8b5cf6);     // Professional purple
  static const Color accentTeal = Color(0xFF06b6d4);       // Modern teal
  static const Color accentGreen = Color(0xFF10b981);      // Success green
  static const Color accentOrange = Color(0xFFf59e0b);     // Warning orange
  static const Color accentRed = Color(0xFFef4444);        // Error red
  static const Color accent = accentTeal;                  // Default accent
  
  // Text Colors - Professional hierarchy
  static const Color textPrimary = Color(0xFF0f172a);      // Dark slate
  static const Color textSecondary = Color(0xFF475569);    // Medium slate
  static const Color textTertiary = Color(0xFF94a3b8);     // Light slate
  static const Color textLight = Color(0xFFe2e8f0);        // Very light
  static const Color textWhite = Colors.white;
  
  // Background Colors - Clean & Modern
  static const Color backgroundPrimary = Color(0xFFffffff);    // Pure white
  static const Color backgroundSecondary = Color(0xFFf8fafc);  // Off white
  static const Color backgroundTertiary = Color(0xFFf1f5f9);   // Light gray
  static const Color backgroundDark = Color(0xFF0f172a);       // Dark slate
  static const Color backgroundLight = backgroundSecondary;    // Alias
  
  // Surface Colors - Cards and containers
  static const Color surfaceLight = Color(0xFFffffff);
  static const Color surfaceMedium = Color(0xFFf8fafc);
  static const Color surfaceDark = Color(0xFF1e293b);
  static const Color surfaceElevated = Color(0xFFffffff);
  
  // Border Colors - Subtle divisions
  static const Color borderLight = Color(0xFFe2e8f0);
  static const Color borderMedium = Color(0xFFcbd5e1);
  static const Color borderDark = Color(0xFF475569);
  
  // Status Colors - Semantic meanings
  static const Color successGreen = Color(0xFF10b981);
  static const Color warningAmber = Color(0xFFf59e0b);
  static const Color errorRed = Color(0xFFef4444);
  static const Color infoBlue = Color(0xFF3b82f6);
  
  // Aliases for common usage
  static const Color success = successGreen;
  static const Color warning = warningAmber;
  static const Color error = errorRed;
  static const Color info = infoBlue;
  
  // Modern Gradient Collections
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF667eea),
      Color(0xFF764ba2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      Color(0xFF06b6d4),
      Color(0xFF8b5cf6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [
      Color(0xFF10b981),
      Color(0xFF059669),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    colors: [
      Color(0xFFf59e0b),
      Color(0xFFef4444),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [
      Color(0xFF1e293b),
      Color(0xFF0f172a),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Glassmorphism effects
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x40ffffff),
      Color(0x10ffffff),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Legacy support (deprecated - use new colors)
  @deprecated
  static const Color textColor = textPrimary;
  @deprecated
  static const Color textColor2 = textSecondary;
  @deprecated
  static const Color textColor3 = textTertiary;
  @deprecated
  static const Color blueColor = primaryBlue;
  @deprecated
  static const Color grey = surfaceMedium;
  @deprecated
  static const Color grey01 = surfaceMedium;
  @deprecated
  static const Color red = errorRed;
  @deprecated
  static const Color errorColor = errorRed;
  @deprecated
  static const Color green = successGreen;
  @deprecated
  static const Color greenDark = Color.fromARGB(255, 50, 116, 52);
  @deprecated
  static final Color lightBorder = borderMedium;
  
  // Additional legacy colors
  static const Color colorE3E3E3 = Color(0XFFE3E3E3);
  static const Color color7D818A = Color(0XFF7D818A);
  static const Color color949494 = Color(0XFF949494);
  static const Color colorD9D9D9 = Color(0XFFD9D9D9);
  static const Color colorC56469 = Color(0XFFC56469);
  static const Color colorFFE734 = Color(0XFFFFE734);
  static const Color color585858 = Color(0XFF585858);
  static const Color webLinkColor = Color(0xFFFFDCAC);
}
