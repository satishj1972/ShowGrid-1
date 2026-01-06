// lib/core/theme/sg_colors.dart
// ShowGrid Complete Color System - Brand Book v2.1 + HTML Templates
import 'package:flutter/material.dart';

class SGColors {
  // ============================================
  // BRAND BOOK v2.1 - BASE COLORS
  // ============================================
  static const Color carbonBlack = Color(0xFF050507);
  static const Color deepNavy = Color(0xFF0D0F1A);
  static const Color frostWhite = Color(0xFFFFFFFF);
  static const Color softGrey = Color(0xFF9CA3AF);
  static const Color borderGrey = Color(0x59949EB8); // rgba(148,163,184,0.35)

  // ============================================
  // BRAND BOOK v2.1 - NEON ACCENTS
  // ============================================
  static const Color violetCore = Color(0xFF6C4AFF);
  static const Color electricBlue = Color(0xFF3B82F6);
  static const Color hyperPink = Color(0xFFEC4899);
  static const Color neonMint = Color(0xFF2ED1B8);
  static const Color pulseGold = Color(0xFFFACC15);

  // ============================================
  // HTML TEMPLATE COLORS
  // ============================================
  static const Color htmlBg = Color(0xFF030414);
  static const Color htmlGlass = Color(0xD90A0C28); // rgba(10,12,40,.85)
  static const Color htmlText = Color(0xFFF9F7FF);
  static const Color htmlMuted = Color(0xFFA5A8CF);
  static const Color htmlPink = Color(0xFFFF4FD8);
  static const Color htmlCyan = Color(0xFF5CF1FF);
  static const Color htmlGold = Color(0xFFFFB84D);
  static const Color htmlViolet = Color(0xFF9B7DFF);
  static const Color htmlGreen = Color(0xFF5CFFB1);
  static const Color htmlBlue = Color(0xFF5CA8FF);

  // ============================================
  // SEMANTIC ALIASES
  // ============================================
  static const Color pink = htmlPink;
  static const Color cyan = htmlCyan;
  static const Color gold = htmlGold;
  static const Color violet = htmlViolet;
  static const Color mint = htmlGreen;
  static const Color blue = htmlBlue;
  static const Color muted = htmlMuted;
  static const Color text = htmlText;
  static const Color glass = htmlGlass;
  static const Color bg = htmlBg;

  // ============================================
  // BORDER COLORS
  // ============================================
  static const Color borderSubtle = Color(0x1FFFFFFF); // rgba(255,255,255,.12)
  static const Color borderLight = Color(0x29FFFFFF); // rgba(255,255,255,.16)

  // ============================================
  // BOTTOM NAV COLORS
  // ============================================
  static const Color bottomNavBg = Color(0xF506071C); // rgba(6,7,28,.96)
  static const Color bottomNavActive = htmlPink;
  static const Color bottomNavInactive = htmlMuted;

  // ============================================
  // GRADIENTS
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [violetCore, electricBlue],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [htmlGold, htmlPink, htmlCyan],
  );

  static const LinearGradient fortuneGradient = LinearGradient(
    colors: [htmlGold, htmlPink],
  );

  static const LinearGradient fanverseGradient = LinearGradient(
    colors: [htmlPink, htmlViolet],
  );

  static const LinearGradient gridvoiceGradient = LinearGradient(
    colors: [htmlGreen, htmlBlue],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    colors: [htmlCyan, electricBlue],
  );

  static const RadialGradient backgroundGradient = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.5,
    colors: [Color(0xFF2C2250), Color(0xFF020214), Color(0xFF01000C)],
    stops: [0.0, 0.45, 1.0],
  );

  // ============================================
  // FEATURE-SPECIFIC COLORS
  // ============================================
  
  // Fortune (Orange/Gold theme)
  static const Color fortunePrimary = htmlGold;
  static const Color fortuneSecondary = htmlPink;
  
  // Fanverse (Pink/Magenta theme)
  static const Color fanversePrimary = htmlPink;
  static const Color fanverseSecondary = htmlViolet;
  
  // GridVoice (Green/Mint theme)
  static const Color gridvoicePrimary = htmlGreen;
  static const Color gridvoiceSecondary = htmlBlue;
}
