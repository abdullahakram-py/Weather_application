import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class AppTheme {
  // Primary Blue & White Color Scheme
  static const Color primaryBlue = Color(0xFF0F52BA); // Sapphire Royal Blue
  static const Color deepNavy = Color(0xFF0A192F);
  static const Color skyBlue = Color(0xFF4A90E2);
  static const Color iceBlue = Color(0xFFE8F1F5);
  static const Color pureWhite = Colors.white;

  // Glossy Card Styles
  static final Border glossyBorder = Border.all(
    color: Colors.white.withValues(alpha: 0.35),
    width: 1.5,
  );

  static final Border glossyBorderLight = Border.all(
    color: Colors.white.withValues(alpha: 0.20),
    width: 1.0,
  );

  static List<BoxShadow> get glossyShadow => [
    BoxShadow(
      color: const Color(0xFF0A192F).withValues(alpha: 0.18),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.25),
      blurRadius: 10,
      spreadRadius: -2,
      offset: const Offset(-4, -4),
    ),
  ];

  // Dynamic Weather Gradient Themes
  static List<Color> getBackgroundGradient(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return const [
          Color(0xFF0F4C81), // Deep Sapphire Top
          Color(0xFF1E88E5), // Ocean Sky Middle
          Color(0xFF64B5F6), // Bright Azure
          Color(0xFFFFD54F), // Sunburst Solar Glow Accent
        ];
      case WeatherCondition.cloudy:
        return const [
          Color(0xFF1C2D42), // Deep Slate Navy
          Color(0xFF37474F), // Overcast Nimbus Grey
          Color(0xFF455A64), // Atmospheric Grey-Blue
          Color(0xFF90A4AE), // Cool Mist Blue
        ];
      case WeatherCondition.rainy:
        return const [
          Color(0xFF0B192C), // Midnight Storm Navy
          Color(0xFF1E3A5F), // Deep Rain Water
          Color(0xFF2E5B88), // Aqua Rain Pulse
          Color(0xFF4A7C59), // Rain Teal Reflection
        ];
      case WeatherCondition.thunderstorm:
        return const [
          Color(0xFF050C1A), // Dark Abyss
          Color(0xFF161F33), // Storm Thunder Gray
          Color(0xFF2A3B5C), // Lightning Indigo
          Color(0xFF483D8B), // Electric Purple Mist
        ];
    }
  }

  // Accent Colors for Metrics
  static Color getAccentColor(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return const Color(0xFFFFB300); // Solar Amber
      case WeatherCondition.cloudy:
        return const Color(0xFF81D4FA); // Soft Cyan
      case WeatherCondition.rainy:
        return const Color(0xFF4FC3F7); // Water Droplet Blue
      case WeatherCondition.thunderstorm:
        return const Color(0xFFE040FB); // Electric Violet
    }
  }
}
