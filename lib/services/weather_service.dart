import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

const String apiKey = 'YOUR_WEATHERAPI_COM_KEY';
const String _baseUrl = 'https://api.weatherapi.com/v1/current.json';

class WeatherService {
  static final List<LocationInfo> availableLocations = const [
    LocationInfo(
      id: 'tokyo',
      city: 'Tokyo',
      country: 'Japan',
      latitude: 35.6762,
      longitude: 139.6503,
      timezone: 'Asia/Tokyo',
    ),
    LocationInfo(
      id: 'new_york',
      city: 'New York',
      country: 'USA',
      latitude: 40.7128,
      longitude: -74.0060,
      timezone: 'America/New_York',
    ),
    LocationInfo(
      id: 'london',
      city: 'London',
      country: 'United Kingdom',
      latitude: 51.5074,
      longitude: -0.1278,
      timezone: 'Europe/London',
    ),
    LocationInfo(
      id: 'paris',
      city: 'Paris',
      country: 'France',
      latitude: 48.8566,
      longitude: 2.3522,
      timezone: 'Europe/Paris',
    ),
    LocationInfo(
      id: 'sydney',
      city: 'Sydney',
      country: 'Australia',
      latitude: -33.8688,
      longitude: 151.2093,
      timezone: 'Australia/Sydney',
    ),
    LocationInfo(
      id: 'dubai',
      city: 'Dubai',
      country: 'United Arab Emirates',
      latitude: 25.2048,
      longitude: 55.2708,
      timezone: 'Asia/Dubai',
    ),
    LocationInfo(
      id: 'singapore',
      city: 'Singapore',
      country: 'Singapore',
      latitude: 1.3521,
      longitude: 103.8198,
      timezone: 'Asia/Singapore',
    ),
    LocationInfo(
      id: 'san_francisco',
      city: 'San Francisco',
      country: 'USA',
      latitude: 37.7749,
      longitude: -122.4194,
      timezone: 'America/Los_Angeles',
    ),
    LocationInfo(
      id: 'reykjavik',
      city: 'Reykjavik',
      country: 'Iceland',
      latitude: 64.1466,
      longitude: -21.9426,
      timezone: 'Atlantic/Reykjavik',
    ),
    LocationInfo(
      id: 'cairo',
      city: 'Cairo',
      country: 'Egypt',
      latitude: 30.0444,
      longitude: 31.2357,
      timezone: 'Africa/Cairo',
    ),
    LocationInfo(
      id: 'islamabad',
      city: 'Islamabad',
      country: 'Pakistan',
      latitude: 33.6844,
      longitude: 73.0479,
      timezone: 'Asia/Karachi',
    ),
  ];


  static LocationInfo get defaultLocation => availableLocations[0]; // Tokyo

  static WeatherData getFallbackWeatherData(LocationInfo location) {
    return _buildFallbackWeatherData(location);
  }

  static Future<WeatherData> getWeatherForLocation(LocationInfo location) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?q=${location.city}&key=$apiKey&aqi=no',
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return parseWeatherResponse(location: location, json: decoded);
      }
    } catch (_) {
      // Fall back to local demo data if the API request fails.
    }

    return _buildFallbackWeatherData(location);
  }

  static WeatherData parseWeatherResponse({
    required LocationInfo location,
    required Map<String, dynamic> json,
  }) {
    final current = json['current'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final weather = (current['condition'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final locationData = json['location'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final wind = current['wind_kph'] as num? ?? 0;

    final temperature = (current['temp_c'] as num?)?.toDouble() ?? 20.0;
    final feelsLike = (current['feelslike_c'] as num?)?.toDouble() ?? temperature;
    final humidity = (current['humidity'] as num?)?.toInt() ?? 50;
    final pressure = (current['pressure_mb'] as num?)?.toInt() ?? 1013;
    final windSpeed = wind.toDouble();
    final visibility = (current['vis_km'] as num?)?.toDouble() ?? 10.0;
    final sunrise = _parseTime(locationData['localtime']?.toString(), current['sunrise']?.toString());
    final sunset = _parseTime(locationData['localtime']?.toString(), current['sunset']?.toString());

    final condition = _conditionFromApi(weather['text']?.toString() ?? 'Cloudy');
    final description = _descriptionFromCondition(condition);

    final hourlyForecast = List.generate(6, (index) {
      final baseTemp = temperature + index * 0.7;
      return HourlyForecast(
        time: '${(index + 1).toString()} PM',
        temperatureC: math.max(0.0, baseTemp),
        condition: index % 3 == 0 ? condition : _nextCondition(condition, index),
        precipitationChance: index * 10 + 5,
        windSpeedKmH: math.max(0.0, windSpeed + index * 0.8),
      );
    });

    final dailyForecast = List.generate(7, (index) {
      final min = temperature - 5.0 - index * 0.3;
      final max = temperature + 3.0 + index * 0.2;
      final dailyCondition = index % 2 == 0 ? condition : _nextCondition(condition, index + 2);
      return DailyForecast(
        dayName: index == 0 ? 'Today' : _dayName(index),
        dateStr: _dateLabel(index),
        tempMinC: min,
        tempMaxC: max,
        condition: dailyCondition,
        rainProbability: index == 0 ? 0 : 10 + (index * 8),
      );
    });

    return WeatherData(
      location: location,
      currentTempC: temperature,
      feelsLikeC: feelsLike,
      condition: condition,
      description: description,
      metrics: WeatherMetrics(
        humidityPercent: humidity,
        uvIndex: 4.0 + (humidity / 100) * 3.0,
        airQualityIndex: 30 + (humidity % 20),
        airQualityLabel: _airQualityLabel(humidity),
        windSpeedKmH: windSpeed,
        windDirection: _windDirectionFromDegrees(0),
        pressureHpa: pressure,
        visibilityKm: visibility,
        dewPointC: temperature - ((100 - humidity) / 5),
        sunrise: sunrise ?? 'N/A',
        sunset: sunset ?? 'N/A',
      ),
      hourlyForecast: hourlyForecast,
      dailyForecast: dailyForecast,
      updatedAt: DateTime.now(),
    );
  }

  static WeatherCondition _conditionFromApi(String condition) {
    final normalized = condition.toLowerCase();
    if (normalized.contains('rain') || normalized.contains('drizzle')) {
      return WeatherCondition.rainy;
    }
    if (normalized.contains('thunder') || normalized.contains('storm')) {
      return WeatherCondition.thunderstorm;
    }
    if (normalized.contains('cloud')) {
      return WeatherCondition.cloudy;
    }
    return WeatherCondition.sunny;
  }

  static String _descriptionFromCondition(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return 'Bright skies and comfortable outdoor conditions.';
      case WeatherCondition.cloudy:
        return 'A mild, overcast day with soft light.';
      case WeatherCondition.rainy:
        return 'Steady rain is expected throughout the day.';
      case WeatherCondition.thunderstorm:
        return 'Stormy conditions with heavy rain and thunder.';
    }
  }

  static WeatherCondition _nextCondition(WeatherCondition condition, int index) {
    final conditions = <WeatherCondition>[
      WeatherCondition.sunny,
      WeatherCondition.cloudy,
      WeatherCondition.rainy,
      WeatherCondition.thunderstorm,
    ];
    return conditions[(conditions.indexOf(condition) + index) % conditions.length];
  }

  static String _dayName(int index) {
    final names = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(index - 1) % names.length];
  }

  static String _dateLabel(int index) {
    final now = DateTime.now();
    final date = now.add(Duration(days: index));
    return '${_monthShort(date.month)} ${date.day.toString().padLeft(2, '0')}';
  }

  static String _monthShort(int month) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String _airQualityLabel(int humidity) {
    if (humidity < 40) {
      return 'Good';
    }
    if (humidity < 70) {
      return 'Moderate';
    }
    return 'Poor';
  }

  static String _windDirectionFromDegrees(num degrees) {
    const directions = <String>['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees / 45) % 8).round() % 8;
    return directions[index.toInt()];
  }

  static String? _parseTime(String? localTime, String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return null;
    }

    final parts = timeString.split(' ');
    if (parts.length != 2) {
      return null;
    }

    return parts[0];
  }

  static WeatherData _buildFallbackWeatherData(LocationInfo location) {
    switch (location.id) {
      case 'tokyo':
        return WeatherData(
          location: location,
          currentTempC: 22.5,
          feelsLikeC: 23.0,
          condition: WeatherCondition.sunny,
          description: 'Clear sunny sky with crisp ocean breezes',
          metrics: const WeatherMetrics(
            humidityPercent: 55,
            uvIndex: 7.2,
            airQualityIndex: 32,
            airQualityLabel: 'Good',
            windSpeedKmH: 14.5,
            windDirection: 'ENE',
            pressureHpa: 1014,
            visibilityKm: 10.0,
            dewPointC: 13.2,
            sunrise: '05:24 AM',
            sunset: '06:48 PM',
          ),
          hourlyForecast: const [
            HourlyForecast(time: '12 PM', temperatureC: 22.5, condition: WeatherCondition.sunny, precipitationChance: 0, windSpeedKmH: 14.5),
            HourlyForecast(time: '1 PM', temperatureC: 24.0, condition: WeatherCondition.sunny, precipitationChance: 0, windSpeedKmH: 15.0),
            HourlyForecast(time: '2 PM', temperatureC: 25.2, condition: WeatherCondition.sunny, precipitationChance: 5, windSpeedKmH: 16.2),
            HourlyForecast(time: '3 PM', temperatureC: 24.8, condition: WeatherCondition.sunny, precipitationChance: 5, windSpeedKmH: 14.0),
            HourlyForecast(time: '4 PM', temperatureC: 23.1, condition: WeatherCondition.cloudy, precipitationChance: 15, windSpeedKmH: 12.5),
            HourlyForecast(time: '5 PM', temperatureC: 21.8, condition: WeatherCondition.cloudy, precipitationChance: 20, windSpeedKmH: 11.0),
            HourlyForecast(time: '6 PM', temperatureC: 20.2, condition: WeatherCondition.sunny, precipitationChance: 10, windSpeedKmH: 9.5),
            HourlyForecast(time: '7 PM', temperatureC: 19.0, condition: WeatherCondition.cloudy, precipitationChance: 5, windSpeedKmH: 8.2),
            HourlyForecast(time: '8 PM', temperatureC: 18.1, condition: WeatherCondition.cloudy, precipitationChance: 0, windSpeedKmH: 7.8),
          ],
          dailyForecast: const [
            DailyForecast(dayName: 'Today', dateStr: 'Jul 26', tempMinC: 17.5, tempMaxC: 25.2, condition: WeatherCondition.sunny, rainProbability: 5),
            DailyForecast(dayName: 'Mon', dateStr: 'Jul 27', tempMinC: 18.0, tempMaxC: 24.0, condition: WeatherCondition.cloudy, rainProbability: 20),
            DailyForecast(dayName: 'Tue', dateStr: 'Jul 28', tempMinC: 16.8, tempMaxC: 21.5, condition: WeatherCondition.rainy, rainProbability: 80),
            DailyForecast(dayName: 'Wed', dateStr: 'Jul 29', tempMinC: 17.2, tempMaxC: 23.1, condition: WeatherCondition.cloudy, rainProbability: 35),
            DailyForecast(dayName: 'Thu', dateStr: 'Jul 30', tempMinC: 19.0, tempMaxC: 26.8, condition: WeatherCondition.sunny, rainProbability: 10),
            DailyForecast(dayName: 'Fri', dateStr: 'Jul 31', tempMinC: 20.1, tempMaxC: 28.0, condition: WeatherCondition.sunny, rainProbability: 0),
            DailyForecast(dayName: 'Sat', dateStr: 'Aug 01', tempMinC: 19.5, tempMaxC: 26.2, condition: WeatherCondition.cloudy, rainProbability: 15),
          ],
          updatedAt: DateTime.now(),
        );

      case 'london':
        return WeatherData(
          location: location,
          currentTempC: 16.0,
          feelsLikeC: 14.8,
          condition: WeatherCondition.rainy,
          description: 'Gentle mist & rhythmic light rain showers',
          metrics: const WeatherMetrics(
            humidityPercent: 88,
            uvIndex: 2.1,
            airQualityIndex: 22,
            airQualityLabel: 'Excellent',
            windSpeedKmH: 22.0,
            windDirection: 'WSW',
            pressureHpa: 1008,
            visibilityKm: 6.5,
            dewPointC: 14.1,
            sunrise: '05:15 AM',
            sunset: '08:58 PM',
          ),
          hourlyForecast: const [
            HourlyForecast(time: '12 PM', temperatureC: 16.0, condition: WeatherCondition.rainy, precipitationChance: 85, windSpeedKmH: 22.0),
            HourlyForecast(time: '1 PM', temperatureC: 16.5, condition: WeatherCondition.rainy, precipitationChance: 90, windSpeedKmH: 24.5),
            HourlyForecast(time: '2 PM', temperatureC: 17.0, condition: WeatherCondition.thunderstorm, precipitationChance: 95, windSpeedKmH: 28.0),
            HourlyForecast(time: '3 PM', temperatureC: 16.2, condition: WeatherCondition.rainy, precipitationChance: 70, windSpeedKmH: 20.1),
            HourlyForecast(time: '4 PM', temperatureC: 15.8, condition: WeatherCondition.cloudy, precipitationChance: 40, windSpeedKmH: 18.0),
            HourlyForecast(time: '5 PM', temperatureC: 15.0, condition: WeatherCondition.cloudy, precipitationChance: 20, windSpeedKmH: 15.0),
          ],
          dailyForecast: const [
            DailyForecast(dayName: 'Today', dateStr: 'Jul 26', tempMinC: 13.0, tempMaxC: 17.0, condition: WeatherCondition.rainy, rainProbability: 90),
            DailyForecast(dayName: 'Mon', dateStr: 'Jul 27', tempMinC: 12.5, tempMaxC: 18.2, condition: WeatherCondition.cloudy, rainProbability: 40),
            DailyForecast(dayName: 'Tue', dateStr: 'Jul 28', tempMinC: 14.0, tempMaxC: 21.0, condition: WeatherCondition.sunny, rainProbability: 10),
            DailyForecast(dayName: 'Wed', dateStr: 'Jul 29', tempMinC: 13.8, tempMaxC: 19.5, condition: WeatherCondition.cloudy, rainProbability: 30),
            DailyForecast(dayName: 'Thu', dateStr: 'Jul 30', tempMinC: 11.2, tempMaxC: 16.8, condition: WeatherCondition.rainy, rainProbability: 75),
            DailyForecast(dayName: 'Fri', dateStr: 'Jul 31', tempMinC: 13.0, tempMaxC: 20.0, condition: WeatherCondition.sunny, rainProbability: 15),
            DailyForecast(dayName: 'Sat', dateStr: 'Aug 01', tempMinC: 14.2, tempMaxC: 22.1, condition: WeatherCondition.sunny, rainProbability: 5),
          ],
          updatedAt: DateTime.now(),
        );

      case 'new_york':
        return WeatherData(
          location: location,
          currentTempC: 27.8,
          feelsLikeC: 29.2,
          condition: WeatherCondition.cloudy,
          description: 'Hazy sunshine broken by scattered grey cloud layers',
          metrics: const WeatherMetrics(
            humidityPercent: 62,
            uvIndex: 6.0,
            airQualityIndex: 45,
            airQualityLabel: 'Moderate',
            windSpeedKmH: 16.8,
            windDirection: 'SSE',
            pressureHpa: 1018,
            visibilityKm: 9.0,
            dewPointC: 19.8,
            sunrise: '05:50 AM',
            sunset: '08:18 PM',
          ),
          hourlyForecast: const [
            HourlyForecast(time: '12 PM', temperatureC: 27.8, condition: WeatherCondition.cloudy, precipitationChance: 15, windSpeedKmH: 16.8),
            HourlyForecast(time: '1 PM', temperatureC: 29.0, condition: WeatherCondition.cloudy, precipitationChance: 25, windSpeedKmH: 18.0),
            HourlyForecast(time: '2 PM', temperatureC: 30.1, condition: WeatherCondition.thunderstorm, precipitationChance: 65, windSpeedKmH: 26.5),
            HourlyForecast(time: '3 PM', temperatureC: 28.5, condition: WeatherCondition.rainy, precipitationChance: 80, windSpeedKmH: 22.0),
            HourlyForecast(time: '4 PM', temperatureC: 26.0, condition: WeatherCondition.cloudy, precipitationChance: 30, windSpeedKmH: 15.0),
          ],
          dailyForecast: const [
            DailyForecast(dayName: 'Today', dateStr: 'Jul 26', tempMinC: 21.0, tempMaxC: 30.1, condition: WeatherCondition.cloudy, rainProbability: 40),
            DailyForecast(dayName: 'Mon', dateStr: 'Jul 27', tempMinC: 22.4, tempMaxC: 31.5, condition: WeatherCondition.sunny, rainProbability: 10),
            DailyForecast(dayName: 'Tue', dateStr: 'Jul 28', tempMinC: 23.0, tempMaxC: 32.8, condition: WeatherCondition.sunny, rainProbability: 5),
            DailyForecast(dayName: 'Wed', dateStr: 'Jul 29', tempMinC: 21.5, tempMaxC: 28.0, condition: WeatherCondition.rainy, rainProbability: 85),
            DailyForecast(dayName: 'Thu', dateStr: 'Jul 30', tempMinC: 20.0, tempMaxC: 27.2, condition: WeatherCondition.cloudy, rainProbability: 25),
            DailyForecast(dayName: 'Fri', dateStr: 'Jul 31', tempMinC: 21.8, tempMaxC: 29.4, condition: WeatherCondition.sunny, rainProbability: 0),
            DailyForecast(dayName: 'Sat', dateStr: 'Aug 01', tempMinC: 22.0, tempMaxC: 30.0, condition: WeatherCondition.sunny, rainProbability: 5),
          ],
          updatedAt: DateTime.now(),
        );

      case 'dubai':
        return WeatherData(
          location: location,
          currentTempC: 38.5,
          feelsLikeC: 43.0,
          condition: WeatherCondition.sunny,
          description: 'Intense golden sunshine with bright thermal glow',
          metrics: const WeatherMetrics(
            humidityPercent: 40,
            uvIndex: 11.5,
            airQualityIndex: 68,
            airQualityLabel: 'Moderate',
            windSpeedKmH: 18.0,
            windDirection: 'NW',
            pressureHpa: 1005,
            visibilityKm: 8.0,
            dewPointC: 22.0,
            sunrise: '05:38 AM',
            sunset: '07:08 PM',
          ),
          hourlyForecast: const [
            HourlyForecast(time: '12 PM', temperatureC: 38.5, condition: WeatherCondition.sunny, precipitationChance: 0, windSpeedKmH: 18.0),
            HourlyForecast(time: '1 PM', temperatureC: 40.2, condition: WeatherCondition.sunny, precipitationChance: 0, windSpeedKmH: 19.5),
            HourlyForecast(time: '2 PM', temperatureC: 41.0, condition: WeatherCondition.sunny, precipitationChance: 0, windSpeedKmH: 21.0),
            HourlyForecast(time: '3 PM', temperatureC: 40.5, condition: WeatherCondition.sunny, precipitationChance: 0, windSpeedKmH: 20.0),
            HourlyForecast(time: '4 PM', temperatureC: 39.0, condition: WeatherCondition.sunny, precipitationChance: 0, windSpeedKmH: 17.5),
          ],
          dailyForecast: const [
            DailyForecast(dayName: 'Today', dateStr: 'Jul 26', tempMinC: 30.0, tempMaxC: 41.0, condition: WeatherCondition.sunny, rainProbability: 0),
            DailyForecast(dayName: 'Mon', dateStr: 'Jul 27', tempMinC: 31.0, tempMaxC: 42.0, condition: WeatherCondition.sunny, rainProbability: 0),
            DailyForecast(dayName: 'Tue', dateStr: 'Jul 28', tempMinC: 30.5, tempMaxC: 40.8, condition: WeatherCondition.sunny, rainProbability: 0),
            DailyForecast(dayName: 'Wed', dateStr: 'Jul 29', tempMinC: 29.8, tempMaxC: 39.5, condition: WeatherCondition.cloudy, rainProbability: 5),
            DailyForecast(dayName: 'Thu', dateStr: 'Jul 30', tempMinC: 30.2, tempMaxC: 41.5, condition: WeatherCondition.sunny, rainProbability: 0),
            DailyForecast(dayName: 'Fri', dateStr: 'Jul 31', tempMinC: 31.5, tempMaxC: 42.5, condition: WeatherCondition.sunny, rainProbability: 0),
            DailyForecast(dayName: 'Sat', dateStr: 'Aug 01', tempMinC: 30.8, tempMaxC: 41.2, condition: WeatherCondition.sunny, rainProbability: 0),
          ],
          updatedAt: DateTime.now(),
        );

      default:
        // Default generic data for other locations
        return WeatherData(
          location: location,
          currentTempC: 21.0,
          feelsLikeC: 21.5,
          condition: WeatherCondition.cloudy,
          description: 'Mild overcast climate with soft blue atmosphere',
          metrics: const WeatherMetrics(
            humidityPercent: 60,
            uvIndex: 5.5,
            airQualityIndex: 35,
            airQualityLabel: 'Good',
            windSpeedKmH: 12.0,
            windDirection: 'N',
            pressureHpa: 1015,
            visibilityKm: 10.0,
            dewPointC: 12.5,
            sunrise: '06:00 AM',
            sunset: '07:30 PM',
          ),
          hourlyForecast: const [
            HourlyForecast(time: '12 PM', temperatureC: 21.0, condition: WeatherCondition.cloudy, precipitationChance: 10, windSpeedKmH: 12.0),
            HourlyForecast(time: '1 PM', temperatureC: 22.5, condition: WeatherCondition.sunny, precipitationChance: 5, windSpeedKmH: 13.0),
            HourlyForecast(time: '2 PM', temperatureC: 23.0, condition: WeatherCondition.sunny, precipitationChance: 0, windSpeedKmH: 14.0),
            HourlyForecast(time: '3 PM', temperatureC: 22.0, condition: WeatherCondition.cloudy, precipitationChance: 15, windSpeedKmH: 12.5),
            HourlyForecast(time: '4 PM', temperatureC: 20.5, condition: WeatherCondition.rainy, precipitationChance: 60, windSpeedKmH: 15.0),
          ],
          dailyForecast: const [
            DailyForecast(dayName: 'Today', dateStr: 'Jul 26', tempMinC: 16.0, tempMaxC: 23.0, condition: WeatherCondition.cloudy, rainProbability: 20),
            DailyForecast(dayName: 'Mon', dateStr: 'Jul 27', tempMinC: 17.0, tempMaxC: 24.5, condition: WeatherCondition.sunny, rainProbability: 5),
            DailyForecast(dayName: 'Tue', dateStr: 'Jul 28', tempMinC: 15.5, tempMaxC: 20.0, condition: WeatherCondition.rainy, rainProbability: 80),
            DailyForecast(dayName: 'Wed', dateStr: 'Jul 29', tempMinC: 16.2, tempMaxC: 22.1, condition: WeatherCondition.cloudy, rainProbability: 25),
            DailyForecast(dayName: 'Thu', dateStr: 'Jul 30', tempMinC: 18.0, tempMaxC: 25.0, condition: WeatherCondition.sunny, rainProbability: 0),
            DailyForecast(dayName: 'Fri', dateStr: 'Jul 31', tempMinC: 18.5, tempMaxC: 26.0, condition: WeatherCondition.sunny, rainProbability: 0),
            DailyForecast(dayName: 'Sat', dateStr: 'Aug 01', tempMinC: 17.0, tempMaxC: 23.8, condition: WeatherCondition.cloudy, rainProbability: 15),
          ],
          updatedAt: DateTime.now(),
        );
    }
  }
}
