import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'glass_card.dart';

class HourlyForecastView extends StatelessWidget {
  final List<HourlyForecast> hourlyForecast;
  final bool isCelsius;

  const HourlyForecastView({
    super.key,
    required this.hourlyForecast,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            children: const [
              Icon(Icons.access_time_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                '24-HOUR FORECAST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: hourlyForecast.length,
            itemBuilder: (context, index) {
              final item = hourlyForecast[index];
              final temp = item.getTemperature(isCelsius).round();

              return GlassCard(
                margin: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 4.0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                borderRadius: BorderRadius.circular(24.0),
                opacity: index == 0 ? 0.35 : 0.18,
                borderColor: index == 0
                    ? Colors.white.withValues(alpha: 0.5)
                    : null,
                child: SizedBox(
                  width: 65,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.time,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(item.condition.icon, color: Colors.white, size: 26),
                      if (item.precipitationChance > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.water_drop,
                              color: Colors.lightBlueAccent,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${item.precipitationChance}%',
                              style: const TextStyle(
                                color: Colors.lightBlueAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox(height: 12),
                      Text(
                        '$temp°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
