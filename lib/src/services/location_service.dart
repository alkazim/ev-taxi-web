import 'package:latlong2/latlong.dart';
import '../../data/places_data.dart';

class PlaceSuggestion {
  final String state;
  final String district;
  final String localBody;
  final String place; // ward/place name
  final LatLng? latLng;

  PlaceSuggestion({
    required this.state,
    required this.district,
    required this.localBody,
    required this.place,
    this.latLng,
  });

  String get displayName {
    // Priority: Ward, LocalBody, District, State
    // Deduplicate if identical
    final parts = <String>[];
    if (place.isNotEmpty) parts.add(place);
    if (localBody.isNotEmpty && localBody != place) parts.add(localBody);
    if (district.isNotEmpty && district != localBody) parts.add(district);
    if (state.isNotEmpty) parts.add(state);
    return parts.join(', ');
  }

  @override
  String toString() => displayName;
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
      districts.forEach((district, localBodies) {
        localBodies.forEach((localBody, wards) {
          wards.forEach((wardName, coords) {
            // "" key is the local body centroid
            final actualPlaceName = wardName.isEmpty ? localBody : wardName;
            
            _allPlaces.add(PlaceSuggestion(
              state: state,
              district: district,
              localBody: localBody,
              place: actualPlaceName,
              latLng: coords.length >= 2
                  ? LatLng(coords[0], coords[1])
                  : null,
            ));
          });
        });
      });
    });

    _initialized = true;
  }

  List<PlaceSuggestion> search(String query, {int limit = 10}) {
    _init();
    if (query.isEmpty) return [];

    final q = query.toLowerCase().trim();

    // Priority 1: place name starts with query
    final tier1 = _allPlaces
        .where((s) => s.place.toLowerCase().startsWith(q))
        .toList();

    if (tier1.length >= limit) return tier1.take(limit).toList();

    // Priority 2: place contains or hierarchy contains
    final tier2 = _allPlaces.where((s) {
      final lowPlace = s.place.toLowerCase();
      if (lowPlace.startsWith(q)) return false;
      
      final displayLow = s.displayName.toLowerCase();
      return displayLow.contains(q) ||
             lowPlace.contains(q) ||
             s.localBody.toLowerCase().contains(q) ||
             s.district.toLowerCase().contains(q) ||
             s.state.toLowerCase().contains(q);
    }).toList();

    return [...tier1, ...tier2].take(limit).toList();
  }

}
