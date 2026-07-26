import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application/models/weather_model.dart';
import 'package:flutter_application/services/weather_service.dart';

void main() {
  test('parseWeatherResponse maps API data into WeatherData', () {
    const location = LocationInfo(
      id: 'tokyo',
      city: 'Tokyo',
      country: 'Japan',
      latitude: 35.6762,
      longitude: 139.6503,
      timezone: 'Asia/Tokyo',
    );

    final weatherData = WeatherService.parseWeatherResponse(
      location: location,
      json: {
        'location': {
          'name': 'Tokyo',
          'localtime': '2026-07-27 12:00',
        },
        'current': {
          'temp_c': 25.0,
          'feelslike_c': 27.0,
          'humidity': 60,
          'pressure_mb': 1012,
          'wind_kph': 6.5,
          'vis_km': 10.0,
          'sunrise': '05:24 AM',
          'sunset': '06:48 PM',
          'condition': {
            'text': 'Clear',
          },
        },
      },
    );

    expect(weatherData.location.city, 'Tokyo');
    expect(weatherData.currentTempC, closeTo(25.0, 0.01));
    expect(weatherData.condition, WeatherCondition.sunny);
    expect(weatherData.metrics.humidityPercent, 60);
    expect(weatherData.hourlyForecast, isNotEmpty);
    expect(weatherData.dailyForecast, isNotEmpty);
  });
}
