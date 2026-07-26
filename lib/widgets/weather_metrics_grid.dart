import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'glass_card.dart';

class WeatherMetricsGrid extends StatelessWidget {
  final WeatherMetrics metrics;

  const WeatherMetricsGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Row(
              children: const [
                Icon(Icons.widgets_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'WEATHER DETAILS',
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
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 1. UV Index
              _buildMetricTile(
                icon: Icons.wb_sunny_outlined,
                title: 'UV INDEX',
                value: '${metrics.uvIndex}',
                subtitle: _getUvCategory(metrics.uvIndex),
                accentColor: _getUvColor(metrics.uvIndex),
                progress: (metrics.uvIndex / 12.0).clamp(0.0, 1.0),
              ),

              // 2. Air Quality Index
              _buildMetricTile(
                icon: Icons.air_rounded,
                title: 'AIR QUALITY',
                value: '${metrics.airQualityIndex} AQI',
                subtitle: metrics.airQualityLabel,
                accentColor: _getAqiColor(metrics.airQualityIndex),
                progress: (metrics.airQualityIndex / 300.0).clamp(0.0, 1.0),
              ),

              // 3. Wind Speed & Direction
              _buildMetricTile(
                icon: Icons.cyclone_rounded,
                title: 'WIND',
                value: '${metrics.windSpeedKmH} km/h',
                subtitle: 'Direction: ${metrics.windDirection}',
                accentColor: Colors.cyanAccent,
                progress: (metrics.windSpeedKmH / 60.0).clamp(0.0, 1.0),
              ),

              // 4. Humidity
              _buildMetricTile(
                icon: Icons.water_drop_outlined,
                title: 'HUMIDITY',
                value: '${metrics.humidityPercent}%',
                subtitle: 'Dew point is ${metrics.dewPointC.round()}°',
                accentColor: Colors.lightBlueAccent,
                progress: (metrics.humidityPercent / 100.0).clamp(0.0, 1.0),
              ),

              // 5. Barometer Pressure
              _buildMetricTile(
                icon: Icons.speed_rounded,
                title: 'PRESSURE',
                value: '${metrics.pressureHpa} hPa',
                subtitle: metrics.pressureHpa > 1013
                    ? 'High Pressure'
                    : 'Low Pressure',
                accentColor: Colors.amberAccent,
                progress: ((metrics.pressureHpa - 950) / 100.0).clamp(0.0, 1.0),
              ),

              // 6. Visibility
              _buildMetricTile(
                icon: Icons.visibility_outlined,
                title: 'VISIBILITY',
                value: '${metrics.visibilityKm} km',
                subtitle: metrics.visibilityKm >= 10
                    ? 'Clear view'
                    : 'Hazy view',
                accentColor: Colors.tealAccent,
                progress: (metrics.visibilityKm / 10.0).clamp(0.0, 1.0),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Sunrise & Sunset Glass Tile
          GlassCard(
            borderRadius: BorderRadius.circular(24.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            opacity: 0.20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wb_twilight_rounded,
                        color: Colors.amberAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SUNRISE',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          metrics.sunrise,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(width: 1, height: 36, color: Colors.white24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.nights_stay_rounded,
                        color: Colors.orangeAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SUNSET',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          metrics.sunset,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color accentColor,
    required double progress,
  }) {
    return GlassCard(
      borderRadius: BorderRadius.circular(24.0),
      padding: const EdgeInsets.all(16.0),
      opacity: 0.18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: accentColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  String _getUvCategory(double uv) {
    if (uv <= 2) return 'Low';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High';
    if (uv <= 10) return 'Very High';
    return 'Extreme';
  }

  Color _getUvColor(double uv) {
    if (uv <= 2) return Colors.greenAccent;
    if (uv <= 5) return Colors.yellowAccent;
    if (uv <= 7) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.greenAccent;
    if (aqi <= 100) return Colors.yellowAccent;
    if (aqi <= 150) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
