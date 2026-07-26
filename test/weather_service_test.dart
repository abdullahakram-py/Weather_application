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
        'main': {
          'temp': 298.15,
          'feels_like': 301.0,
          'humidity': 60,
          'pressure': 1012,
        },
        'weather': [
          {'main': 'Clear'}
        ],
        'wind': {
          'speed': 6.5,
        },
        'visibility': 10000,
        'sys': {
          'sunrise': 1715000000,
          'sunset': 1715050000,
        },
        'name': 'Tokyo',
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
