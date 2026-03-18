import 'package:latlong2/latlong.dart';
import '../../data/places_data.dart';

class PlaceSuggestion {
  final String state;
  final String district;
  final String place;
  final LatLng? position;

  PlaceSuggestion({
    required this.state,
    required this.district,
    required this.place,
    this.position,
  });

  @override
  String toString() {
    if (place.toLowerCase() == district.toLowerCase()) {
      return '$place, $state';
    }
    return '$place, $district, $state';
  }
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final List<PlaceSuggestion> _allPlaces = [];
  bool _initialized = false;

  void _init() {
    if (_initialized) return;

    rawLocationData.forEach((state, districts) {
      districts.forEach((district, places) {

        // Add the district itself (if not already in places)
        final lowDistrict = district.toLowerCase();
        if (!places.keys.any((p) => p.toLowerCase() == lowDistrict)) {
          // The district coordinate is the first entry of that district (first place)
          final firstCoord = places.values.isNotEmpty ? places.values.first : null;
          _allPlaces.add(PlaceSuggestion(
            state: state,
            district: district,
            place: district,
            position: firstCoord != null
                ? LatLng(firstCoord[0], firstCoord[1])
                : null,
          ));
        }

        places.forEach((placeName, coords) {
          _allPlaces.add(PlaceSuggestion(
            state: state,
            district: district,
            place: placeName,
            position: coords.length >= 2
                ? LatLng(coords[0], coords[1])
                : null,
          ));
        });
      });
    });

    _initialized = true;
  }

  List<PlaceSuggestion> search(String query) {
    _init();
    if (query.isEmpty) return [];

    final q = query.toLowerCase().trim();

    // Priority 1: place name starts with query
    final tier1 = _allPlaces
        .where((s) => s.place.toLowerCase().startsWith(q))
        .toList();

    if (tier1.length >= 10) return tier1.take(10).toList();

    // Priority 2: place contains or district/state contains
    final tier2 = _allPlaces.where((s) {
      final low = s.place.toLowerCase();
      return !low.startsWith(q) &&
          (low.contains(q) ||
              s.district.toLowerCase().contains(q) ||
              s.state.toLowerCase().contains(q));
    }).toList();

    return [...tier1, ...tier2].take(10).toList();
  }

  LatLng? getCoordinates(String placeName) {
    _init();
    final q = placeName.toLowerCase().trim();
    try {
      return _allPlaces.firstWhere(
        (s) =>
            s.place.toLowerCase() == q ||
            s.toString().toLowerCase() == q,
      ).position;
    } catch (_) {
      return null;
    }
  }
}
