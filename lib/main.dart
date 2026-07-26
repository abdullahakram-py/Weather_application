import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/weather_model.dart';
import 'services/weather_service.dart';
import 'theme/app_theme.dart';
import 'widgets/animations/weather_background.dart';
import 'widgets/hero_temperature_card.dart';
import 'widgets/hourly_forecast_view.dart';
import 'widgets/location_header.dart';
import 'widgets/weather_condition_switcher.dart';
import 'widgets/weather_metrics_grid.dart';
import 'widgets/weekly_forecast_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const GlossyWeatherApp());
}

class GlossyWeatherApp extends StatelessWidget {
  const GlossyWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Weather - Glossy Edition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primaryColor: AppTheme.primaryBlue,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: AppTheme.deepNavy,
      ),
      home: const WeatherHomeScreen(),
    );
  }
}

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  late LocationInfo _selectedLocation;
  late WeatherData _currentWeatherData;
  bool _isCelsius = true;

  @override
  void initState() {
    super.initState();
    _selectedLocation = WeatherService.defaultLocation; // Tokyo
    _currentWeatherData = WeatherService.getFallbackWeatherData(_selectedLocation);
    _loadWeatherData(_selectedLocation);
  }

  Future<void> _loadWeatherData(LocationInfo location) async {
    setState(() {
      _selectedLocation = location;
      _currentWeatherData = WeatherService.getFallbackWeatherData(location);
    });

    final weatherData = await WeatherService.getWeatherForLocation(location);
    if (!mounted) return;

    setState(() {
      _currentWeatherData = weatherData;
    });
  }

  void _changeCondition(WeatherCondition newCondition) {
    setState(() {
      _currentWeatherData =
          _currentWeatherData.copyWithCondition(newCondition);
    });
  }

  void _toggleUnit(bool useCelsius) {
    setState(() {
      _isCelsius = useCelsius;
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _loadWeatherData(_selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    final activeCondition = _currentWeatherData.condition;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: WeatherBackground(
        condition: activeCondition,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: Colors.white,
            backgroundColor: AppTheme.primaryBlue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                children: [
                  // Top Header: Location Selector & °C/°F Unit Switcher
                  LocationHeader(
                    selectedLocation: _selectedLocation,
                    onLocationSelected: _loadWeatherData,
                    isCelsius: _isCelsius,
                    onUnitToggled: _toggleUnit,
                  ),

                  // Weather Mode Simulator Pill (Sunny, Cloudy, Rainy, Thunderstorm)
                  WeatherConditionSwitcher(
                    currentCondition: activeCondition,
                    onConditionChanged: _changeCondition,
                  ),

                  // Main Temperature Hero Display Card
                  HeroTemperatureCard(
                    weatherData: _currentWeatherData,
                    isCelsius: _isCelsius,
                  ),

                  const SizedBox(height: 8),

                  // 24-Hour Forecast Carousel
                  HourlyForecastView(
                    hourlyForecast: _currentWeatherData.hourlyForecast,
                    isCelsius: _isCelsius,
                  ),

                  const SizedBox(height: 8),

                  // 7-Day Weekly Forecast Card
                  WeeklyForecastView(
                    dailyForecast: _currentWeatherData.dailyForecast,
                    isCelsius: _isCelsius,
                  ),

                  // Comprehensive Weather Metrics Grid (UV, Air Quality, Wind, Humidity, etc.)
                  WeatherMetricsGrid(
                    metrics: _currentWeatherData.metrics,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
