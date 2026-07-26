import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'glass_card.dart';

class HeroTemperatureCard extends StatelessWidget {
  final WeatherData weatherData;
  final bool isCelsius;

  const HeroTemperatureCard({
    super.key,
    required this.weatherData,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    final temp = weatherData.getCurrentTemp(isCelsius).round();
    final feelsLike = weatherData.getFeelsLikeTemp(isCelsius).round();
    final unitSymbol = isCelsius ? '°C' : '°F';

    // Find min and max from daily forecast if available
    final todayForecast = weatherData.dailyForecast.isNotEmpty
        ? weatherData.dailyForecast[0]
        : null;

    final tempMin = todayForecast != null
        ? todayForecast.getTempMin(isCelsius).round()
        : (temp - 4);
    final tempMax = todayForecast != null
        ? todayForecast.getTempMax(isCelsius).round()
        : (temp + 5);

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      borderRadius: BorderRadius.circular(32.0),
      opacity: 0.22,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Weather Condition & Main Temperature
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Condition Label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            weatherData.condition.icon,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            weatherData.condition.displayName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Temperature Display
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: temp.toDouble()),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, val, child) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${val.round()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                height: 0.95,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 16,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              unitSymbol,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // Feels like & High/Low
                    Row(
                      children: [
                        Text(
                          'Feels like $feelsLike$unitSymbol',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'H: $tempMax°  L: $tempMin°',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right: Animated Large Glossy Weather Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    weatherData.condition.icon,
                    color: Colors.white,
                    size: 72,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // Weather Summary Description
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.amberAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weatherData.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
