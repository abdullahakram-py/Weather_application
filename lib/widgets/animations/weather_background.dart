import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import '../../theme/app_theme.dart';
import 'cloud_painter.dart';
import 'rain_painter.dart';
import 'sunny_painter.dart';

class WeatherBackground extends StatelessWidget {
  final WeatherCondition condition;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = AppTheme.getBackgroundGradient(condition);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Weather Condition Specific Custom Animation Layer
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: _buildWeatherAnimation(condition),
          ),

          // Main App Content Layer
          child,
        ],
      ),
    );
  }

  Widget _buildWeatherAnimation(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return const SunnyWidget(key: ValueKey('sunny'));
      case WeatherCondition.cloudy:
        return const CloudWidget(key: ValueKey('cloudy'));
      case WeatherCondition.rainy:
        return const RainWidget(key: ValueKey('rainy'), dropCount: 80);
      case WeatherCondition.thunderstorm:
        return Stack(
          key: const ValueKey('thunderstorm'),
          children: const [
            CloudWidget(cloudCount: 8),
            RainWidget(dropCount: 120, isHeavy: true),
          ],
        );
    }
  }
}
