import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'glass_card.dart';

class LocationHeader extends StatelessWidget {
  final LocationInfo selectedLocation;
  final ValueChanged<LocationInfo> onLocationSelected;
  final bool isCelsius;
  final ValueChanged<bool> onUnitToggled;

  const LocationHeader({
    super.key,
    required this.selectedLocation,
    required this.onLocationSelected,
    required this.isCelsius,
    required this.onUnitToggled,
  });

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _LocationSearchBottomSheet(
          selectedLocation: selectedLocation,
          onLocationSelected: (location) {
            Navigator.pop(context);
            onLocationSelected(location);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM d').format(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Location Selector Pill
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              borderRadius: BorderRadius.circular(20.0),
              onTap: () => _showLocationPicker(context),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                selectedLocation.city,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ],
                        ),
                        Text(
                          '${selectedLocation.country} • $dateStr',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // °C / °F Unit Switcher Glossy Pill
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            borderRadius: BorderRadius.circular(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUnitChip(
                  label: '°C',
                  isSelected: isCelsius,
                  onTap: () => onUnitToggled(true),
                ),
                _buildUnitChip(
                  label: '°F',
                  isSelected: !isCelsius,
                  onTap: () => onUnitToggled(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.40)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _LocationSearchBottomSheet extends StatefulWidget {
  final LocationInfo selectedLocation;
  final ValueChanged<LocationInfo> onLocationSelected;

  const _LocationSearchBottomSheet({
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  State<_LocationSearchBottomSheet> createState() =>
      __LocationSearchBottomSheetState();
}

class __LocationSearchBottomSheetState
    extends State<_LocationSearchBottomSheet> {
  late TextEditingController _searchController;
  List<LocationInfo> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredLocations = List.from(WeatherService.availableLocations);
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = List.from(WeatherService.availableLocations);
      } else {
        _filteredLocations = WeatherService.availableLocations
            .where(
              (loc) =>
                  loc.city.toLowerCase().contains(query.toLowerCase()) ||
                  loc.country.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: const Color(0xFF0F2B48).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: const [
                Icon(
                  Icons.travel_explore_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 10),
                Text(
                  'Select Weather Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search city or country...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.12),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // City List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final loc = _filteredLocations[index];
                final isSelected = loc.id == widget.selectedLocation.id;

                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  opacity: isSelected ? 0.35 : 0.15,
                  borderColor: isSelected ? Colors.amberAccent : null,
                  onTap: () => widget.onLocationSelected(loc),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.location_on
                                : Icons.location_city_rounded,
                            color: isSelected
                                ? Colors.amberAccent
                                : Colors.white70,
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.city,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.amberAccent
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                loc.country,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.amberAccent,
                          size: 22,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
