import 'package:flutter/material.dart';

// Modern color palette
const _primaryColor = Color(0xFFFF6B35);
const _secondaryColor = Color(0xFFFF8F61);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primaryColor,
    brightness: Brightness.light,
  ).copyWith(
    primary: _primaryColor,
    secondary: _secondaryColor,
  ),
  fontFamily: null, // System default
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    elevation: 0,
    backgroundColor: Colors.white.withValues(alpha:0.95),
    indicatorColor: _primaryColor.withValues(alpha:0.12),
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
  ),
  chipTheme: ChipThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: _primaryColor,
    inactiveTrackColor: _primaryColor.withValues(alpha:0.15),
    thumbColor: _primaryColor,
    overlayColor: _primaryColor.withValues(alpha:0.12),
  ),
  scaffoldBackgroundColor: const Color(0xFFF8F6F3),
  dialogTheme: DialogThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);

// Shared gradient for backgrounds
const appGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFFFF5EE),
    Color(0xFFF8F6F3),
  ],
);

// Accent gradient for buttons/highlights
const accentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFF6B35),
    Color(0xFFFF8F61),
  ],
);
