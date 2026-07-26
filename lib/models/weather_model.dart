import 'package:flutter/material.dart';


enum WeatherCondition {
  sunny,
  cloudy,
  rainy,
  thunderstorm,
}

extension WeatherConditionExtension on WeatherCondition {
  String get displayName {
    switch (this) {
      case WeatherCondition.sunny:
        return 'Sunny';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.rainy:
        return 'Rainy';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
    }
  }

  IconData get icon {
    switch (this) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherCondition.cloudy:
        return Icons.cloud_rounded;
      case WeatherCondition.rainy:
        return Icons.water_drop_rounded;
      case WeatherCondition.thunderstorm:
        return Icons.thunderstorm_rounded;
    }
  }
}

class LocationInfo {
  final String id;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;

  const LocationInfo({
    required this.id,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  String get fullLocation => '$city, $country';
}

class HourlyForecast {
  final String time;
  final double temperatureC;
  final WeatherCondition condition;
  final int precipitationChance;
  final double windSpeedKmH;

  const HourlyForecast({
    required this.time,
    required this.temperatureC,
    required this.condition,
    required this.precipitationChance,
    required this.windSpeedKmH,
  });

  double getTemperature(bool isCelsius) =>
      isCelsius ? temperatureC : (temperatureC * 9 / 5) + 32;
}

class DailyForecast {
  final String dayName;
  final String dateStr;
  final double tempMinC;
  final double tempMaxC;
  final WeatherCondition condition;
  final int rainProbability;

  const DailyForecast({
    required this.dayName,
    required this.dateStr,
    required this.tempMinC,
    required this.tempMaxC,
    required this.condition,
    required this.rainProbability,
  });

  double getTempMin(bool isCelsius) =>
      isCelsius ? tempMinC : (tempMinC * 9 / 5) + 32;

  double getTempMax(bool isCelsius) =>
      isCelsius ? tempMaxC : (tempMaxC * 9 / 5) + 32;
}

class WeatherMetrics {
  final int humidityPercent;
  final double uvIndex;
  final int airQualityIndex; // AQI 1-500
  final String airQualityLabel;
  final double windSpeedKmH;
  final String windDirection;
  final int pressureHpa;
  final double visibilityKm;
  final double dewPointC;
  final String sunrise;
  final String sunset;

  const WeatherMetrics({
    required this.humidityPercent,
    required this.uvIndex,
    required this.airQualityIndex,
    required this.airQualityLabel,
    required this.windSpeedKmH,
    required this.windDirection,
    required this.pressureHpa,
    required this.visibilityKm,
    required this.dewPointC,
    required this.sunrise,
    required this.sunset,
  });
}

class WeatherData {
  final LocationInfo location;
  final double currentTempC;
  final double feelsLikeC;
  final WeatherCondition condition;
  final String description;
  final WeatherMetrics metrics;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final DateTime updatedAt;

  const WeatherData({
    required this.location,
    required this.currentTempC,
    required this.feelsLikeC,
    required this.condition,
    required this.description,
    required this.metrics,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.updatedAt,
  });

  double getCurrentTemp(bool isCelsius) =>
      isCelsius ? currentTempC : (currentTempC * 9 / 5) + 32;

  double getFeelsLikeTemp(bool isCelsius) =>
      isCelsius ? feelsLikeC : (feelsLikeC * 9 / 5) + 32;

  WeatherData copyWithCondition(WeatherCondition newCondition) {
    return WeatherData(
      location: location,
      currentTempC: currentTempC,
      feelsLikeC: feelsLikeC,
      condition: newCondition,
      description: _getDescriptionForCondition(newCondition),
      metrics: metrics,
      hourlyForecast: hourlyForecast,
      dailyForecast: dailyForecast,
      updatedAt: DateTime.now(),
    );
  }

  static String _getDescriptionForCondition(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return 'Clear blue skies with brilliant sunlight & gentle warmth';
      case WeatherCondition.cloudy:
        return 'Overcast atmosphere with drifting cool cloud layers';
      case WeatherCondition.rainy:
        return 'Steady rhythmic rain showers with refreshing cool air';
      case WeatherCondition.thunderstorm:
        return 'Heavy downpour with lightning pulses & rolling thunder';
    }
  }
}
