import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'glass_card.dart';

class WeeklyForecastView extends StatelessWidget {
  final List<DailyForecast> dailyForecast;
  final bool isCelsius;

  const WeeklyForecastView({
    super.key,
    required this.dailyForecast,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyForecast.isEmpty) return const SizedBox.shrink();

    // Find global min and max across all days for proportional range bars
    double globalMin = 100;
    double globalMax = -100;

    for (var day in dailyForecast) {
      final minVal = day.getTempMin(isCelsius);
      final maxVal = day.getTempMax(isCelsius);
      if (minVal < globalMin) globalMin = minVal;
      if (maxVal > globalMax) globalMax = maxVal;
    }

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      padding: const EdgeInsets.all(20.0),
      borderRadius: BorderRadius.circular(28.0),
      opacity: 0.20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                '7-DAY FORECAST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyForecast.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white12, height: 16),
            itemBuilder: (context, index) {
              final day = dailyForecast[index];
              final minTemp = day.getTempMin(isCelsius).round();
              final maxTemp = day.getTempMax(isCelsius).round();

              // Calculate range bar positioning
              final totalSpan = (globalMax - globalMin) == 0
                  ? 1.0
                  : (globalMax - globalMin);
              final leftOffset =
                  ((day.getTempMin(isCelsius) - globalMin) / totalSpan).clamp(
                    0.0,
                    1.0,
                  );
              final rightWidth =
                  ((day.getTempMax(isCelsius) - day.getTempMin(isCelsius)) /
                          totalSpan)
                      .clamp(0.1, 1.0);

              return Row(
                children: [
                  // Day name & date
                  SizedBox(
                    width: 75,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.dayName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: index == 0
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                        Text(
                          day.dateStr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Condition Icon
                  Icon(day.condition.icon, color: Colors.white, size: 22),

                  const SizedBox(width: 8),

                  // Rain chance if any
                  SizedBox(
                    width: 38,
                    child: day.rainProbability > 0
                        ? Text(
                            '${day.rainProbability}%',
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(width: 8),

                  // Min Temp
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$minTemp°',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Proportional Temperature Range Bar
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth = constraints.maxWidth;
                        return Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            Positioned(
                              left: leftOffset * barWidth,
                              width: rightWidth * barWidth,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.lightBlueAccent,
                                      Colors.amberAccent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Max Temp
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$maxTemp°',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
