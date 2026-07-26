import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'glass_card.dart';

class WeatherConditionSwitcher extends StatelessWidget {
  final WeatherCondition currentCondition;
  final ValueChanged<WeatherCondition> onConditionChanged;

  const WeatherConditionSwitcher({
    super.key,
    required this.currentCondition,
    required this.onConditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        borderRadius: BorderRadius.circular(28.0),
        opacity: 0.25,
        borderColor: Colors.white.withValues(alpha: 0.4),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.tune_rounded, color: Colors.amberAccent, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'SIMULATE WEATHER MODE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: WeatherCondition.values.map((condition) {
                final isSelected = condition == currentCondition;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onConditionChanged(condition),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.38)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.0),
                        border: isSelected
                            ? Border.all(
                                color: _getHighlightColor(condition),
                                width: 1.5,
                              )
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _getHighlightColor(
                                    condition,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            condition.icon,
                            color: isSelected
                                ? _getHighlightColor(condition)
                                : Colors.white70,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            condition.displayName,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.75),
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHighlightColor(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return Colors.amberAccent;
      case WeatherCondition.cloudy:
        return const Color(0xFF81D4FA);
      case WeatherCondition.rainy:
        return Colors.lightBlueAccent;
      case WeatherCondition.thunderstorm:
        return Colors.purpleAccent;
    }
  }
}
