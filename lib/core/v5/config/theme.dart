import 'package:flutter/material.dart';

class BrandColors {
  BrandColors._();

  /// primary color

  static const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
    50: Color(0xFFECE6F2),
    100: Color(0xFFD1C1DF),
    200: Color(0xFFB298CA),
    300: Color(0xFF936EB4),
    400: Color(0xFF7B4FA4),
    500: Color(_primaryPrimaryValue),
    600: Color(0xFF5C2B8C),
    700: Color(0xFF522481),
    800: Color(0xFF481E77),
    900: Color(0xFF361365),
  });
  static const int _primaryPrimaryValue = 0xFF643094;

  static const MaterialColor primaryAccent = MaterialColor(_primaryAccentValue, <int, Color>{
    100: Color(0xFFC39CFF),
    200: Color(_primaryAccentValue),
    400: Color(0xFF8636FF),
    700: Color(0xFF761DFF),
  });
  static const int _primaryAccentValue = 0xFFA469FF;

  /// secondary color

  static const MaterialColor secondary = MaterialColor(_secondaryPrimaryValue, <int, Color>{
    50: Color(0xFFE0F7FA),
    100: Color(0xFFB3EBF2),
    200: Color(0xFF80DEEA),
    300: Color(0xFF4DD0E1),
    400: Color(0xFF26C6DA),
    500: Color(_secondaryPrimaryValue),
    600: Color(0xFF00B6CF),
    700: Color(0xFF00ADC9),
    800: Color(0xFF00A5C3),
    900: Color(0xFF0097B9),
  });
  static const int _secondaryPrimaryValue = 0xFF00BCD4;

  static const MaterialColor secondaryAccent = MaterialColor(_secondaryAccentValue, <int, Color>{
    100: Color(0xFFE2F9FF),
    200: Color(_secondaryAccentValue),
    400: Color(0xFF7CE3FF),
    700: Color(0xFF63DDFF),
  });
  static const int _secondaryAccentValue = 0xFFAFEEFF;

  /// gray color

  static const MaterialColor gray = MaterialColor(_grayPrimaryValue, <int, Color>{
    50: Color(0xFFF4F4F6),
    100: Color(0xFFC3C3CF),
    200: Color(0xFF9B9BB0),
    300: Color(0xFF727290),
    400: Color(0xFF545478),
    500: Color(_grayPrimaryValue),
    600: Color(0xFF303058),
    700: Color(0xFF29294E),
    800: Color(0xFF222244),
    900: Color(0xFF161633),
  });
  static const int _grayPrimaryValue = 0xFF363660;

  static const MaterialColor grayAccent = MaterialColor(_grayAccentValue, <int, Color>{
    100: Color(0xFF7474FF),
    200: Color(_grayAccentValue),
    300: Color(0xFFD2D2F5),
    400: Color(0xFFC4C4F8),
    500: Color(0xFF0E0EFF),
    700: Color(0xFF0000F4),
  });
  static const int _grayAccentValue = 0xFF4141FF;

  static const MaterialColor formtextColor = MaterialColor(_primaryAccentValue, <int, Color>{
    50: Color(0xFF94a3b8),
    100: Color(0xFF1e293b),
    200: Color(0xFF64748b),
  });
}
