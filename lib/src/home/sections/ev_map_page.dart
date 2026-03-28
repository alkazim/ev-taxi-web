import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi_demo/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/location_service.dart';

// ─── Mode ─────────────────────────────────────────────────────────────────────
enum _MapMode { idle, nearest, route }

// ─── Station Model ─────────────────────────────────────────────────────────────
class _Station {
  final String name;
  final String address;
  final LatLng position;
  final String? chargerType;
  final String source; // 'ecabbz' or 'others'

  _Station({
    required this.name,
    required this.address,
    required this.position,
    this.chargerType,
    this.source = 'others',
  });
}

// ─── ecabbz Sample Data ──────────────────────────────────────────────────────
final List<_Station> _ecabbzStations = [
  _Station(
    name: 'ecabbz - Edappally',
    address: 'Near Edappally Metro Station, Kochi',
    position: const LatLng(10.0236, 76.3115),
    chargerType: 'DC Fast Charger (60kW)',
    source: 'ecabbz',
  ),
  _Station(
    name: 'ecabbz - Palarivattom',
    address: 'Palarivattom Bypass Junction, Kochi',
    position: const LatLng(10.0075, 76.3055),
    chargerType: 'AC Type 2 (22kW)',
    source: 'ecabbz',
  ),
  _Station(
    name: 'ecabbz - Kaloor',
    address: 'Kaloor Stadium Road, Kochi',
    position: const LatLng(9.9930, 76.3015),
    chargerType: 'DC Fast Charger (30kW)',
    source: 'ecabbz',
  ),
  _Station(
    name: 'ecabbz - MG Road',
    address: 'MG Road, Near Maharaja\'s College Kochi',
    position: const LatLng(9.9816, 76.2999),
    chargerType: 'AC Type 2 (7kW)',
    source: 'ecabbz',
  ),
];

// ─── Crosshair / GPS Painter ──────────────────────────────────────────────────
class _CrosshairPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _CrosshairPainter({this.color = Colors.white, this.strokeWidth = 2.2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.32;   // Outer circle radius
    final gap = size.width * 0.14; // Gap between crosshair line and circle

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), r, paint);
    // Inner dot
    final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.07, dotPaint);
    // Top tick
    canvas.drawLine(Offset(cx, cy - r - gap), Offset(cx, cy - r - gap - size.width * 0.12), paint);
    // Bottom tick
    canvas.drawLine(Offset(cx, cy + r + gap), Offset(cx, cy + r + gap + size.width * 0.12), paint);
    // Left tick
    canvas.drawLine(Offset(cx - r - gap, cy), Offset(cx - r - gap - size.width * 0.12, cy), paint);
    // Right tick
    canvas.drawLine(Offset(cx + r + gap, cy), Offset(cx + r + gap + size.width * 0.12, cy), paint);
  }

  @override
  bool shouldRepaint(_CrosshairPainter old) => old.color != color;
}

// ─── EVMapPage ────────────────────────────────────────────────────────────────
class EVMapPage extends StatefulWidget {
  const EVMapPage({super.key});

  @override
  State<EVMapPage> createState() => _EVMapPageState();
}

class _EVMapPageState extends State<EVMapPage> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  LatLng? _userLatLng;
  _MapMode _mode = _MapMode.idle;
  bool _isLocating = false;
  bool _isRouting = false;
  bool _isLoadingLocation = true; // Tracks the initial GPS load
  int? _watchId;

  bool _showEcabbzOnly = true; // Default to showing ecabbz chargers

  Timer? _debounceTimer;
  List<Map<String, dynamic>> _fromSuggestions = [];
  List<Map<String, dynamic>> _toSuggestions = [];
  bool _showFromSuggestions = false;
  bool _showToSuggestions = false;

  final _fromCtrl = TextEditingController();
  final _viaCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  List<LatLng> _routePoints = [];
  List<_Station> _stationList = [];
  LatLng? _fromLatLng;
  LatLng? _toLatLng;
  LatLng? _viaLatLng;

  int _selectedRouteIndex = 0;
  List<Map<String, dynamic>> _routeAlternatives = [];

  // ─── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Start fetching location immediately (parallel with map loading).
    // By the time _onMapReady fires, location may already be available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserLocation(centerMap: true, silent: true);
    });
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _viaCtrl.dispose();
    _toCtrl.dispose();
    if (_watchId != null) {
      web.window.navigator.geolocation.clearWatch(_watchId!);
    }
    super.dispose();
  }

  // ─── Location ───────────────────────────────────────────────────────────────
  // ─── Map Ready ──────────────────────────────────────────────────────────────
  void _onMapReady() {
    setState(() => _mapReady = true);
    if (_showEcabbzOnly) {
      _applyEcabbzFilter();
    } else if (_userLatLng != null) {
      _findNearestStations();
    }
  }

  void _applyEcabbzFilter() {
    setState(() {
      _stationList = _ecabbzStations;
      _mode = _MapMode.nearest;
    });
    if (_mapReady && _stationList.isNotEmpty) {
      _fitMap(_stationList.map((s) => s.position).toList());
    }
  }

  Future<void> _fetchUserLocation({
    bool centerMap = false,
    bool silent = false,
  }) async {
    if (_isLocating && _watchId == null) return;
    debugPrint('📍 [Location] Requesting real-time GPS position...');
    if (!silent) setState(() => _isLocating = true);

    if (_watchId != null) {
      web.window.navigator.geolocation.clearWatch(_watchId!);
    }

    try {
      _watchId = web.window.navigator.geolocation.watchPosition(
        (web.GeolocationPosition pos) {
          if (!mounted) return;
          final lat = pos.coords.latitude;
          final lng = pos.coords.longitude;
          final accuracy = pos.coords.accuracy;
          debugPrint('✅ [Location] Received coordinates: $lat, $lng (accuracy: ${accuracy.toStringAsFixed(0)}m)');
          
          setState(() {
            _userLatLng = LatLng(lat, lng);
            if (!silent) _isLocating = false;
            _isLoadingLocation = false;
          });
          
          if (_mapReady && centerMap) {
            _mapController.move(_userLatLng!, 14.0);
            centerMap = false; // Prevent subsequent background updates from moving the map
          }
        }.toJS,
        (web.GeolocationPositionError error) {
          if (!mounted) return;
          debugPrint('⚠️ [Location] Geolocation error or denied. Code: ${error.code}');
          final bool wasLoading = _isLoadingLocation;
          setState(() {
            // Fallback to Kochi, India
            _userLatLng = const LatLng(9.9312, 76.2673);
            if (!silent) _isLocating = false;
            _isLoadingLocation = false;
          });
          
          if (_mapReady && centerMap) {
            _mapController.move(_userLatLng!, 14.0);
            _findNearestStations();
            centerMap = false; // Prevent subsequent map moves
          }
          
          if (!silent || wasLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied. Showing Kochi as fallback.')),
            );
          }
        }.toJS,
        web.PositionOptions(
          enableHighAccuracy: true,
          timeout: 15000,
          maximumAge: 0,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocating = false;
          _isLoadingLocation = false;
        });
      }
    }
  }

  // ─── Reverse Geocode ───────────────────────────────────────────────────────
  // REMOVED: Offline-only requirement. Reverse geocoding (Nominatim) is disabled.
  /*
  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final resp = await http.get(url, headers: {'User-Agent': 'EVTaxiDemo/1.0'});
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return data['display_name'] as String?;
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
    return null;
  }
  */

  Future<void> _onGPSShortcutClicked() async {
    if (_userLatLng != null && _mapReady) {
      _mapController.move(_userLatLng!, 15.0);
      
      // Since Nominatim is disabled, we directly set to "My Location"
      if (mounted) {
        setState(() {
          _fromCtrl.text = 'My Location';
          _fromLatLng = _userLatLng;
        });
      }
    } else {
      _fetchUserLocation(centerMap: true, silent: false);
    }
  }

  // ─── Suggestions ────────────────────────────────────────────────────────────
  Future<void> _fetchSuggestions(String query, bool isFrom) async {
    if (query.length < 2) {
      setState(() {
        if (isFrom) {
          _fromSuggestions = [];
          _showFromSuggestions = false;
        } else {
          _toSuggestions = [];
          _showToSuggestions = false;
        }
      });
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final List<Map<String, dynamic>> suggestions = [];
        final Set<String> seen = {};

        // 1. Offline Search First (Priority)
        final offlineResults = LocationService().search(query, limit: 10);
        for (final res in offlineResults) {
          final display = res.displayName;
          if (seen.add(display)) {
            suggestions.add({
              'display': display,
              'lat': res.latLng?.latitude,
              'lng': res.latLng?.longitude,
              'suggestion': res, // Add the full object
              'priority': 1,
            });
          }
        }

        // 2. Nominatim Fallback REMOVED
        // We now strictly use the offline dataset.

        if (mounted) {
          setState(() {
            if (isFrom) {
              _fromSuggestions = suggestions.take(8).toList();
              _showFromSuggestions = _fromSuggestions.isNotEmpty;
            } else {
              _toSuggestions = suggestions.take(8).toList();
              _showToSuggestions = _toSuggestions.isNotEmpty;
            }
          });
        }
      } catch (e) {
        debugPrint('Suggestion error: $e');
      }
    });
  }

  void _hideAllSuggestions() {
    if (_showFromSuggestions || _showToSuggestions) {
      debugPrint('🙈 [UI] Hiding suggestions...');
      setState(() {
        _showFromSuggestions = false;
        _showToSuggestions = false;
      });
    }
  }

  /// Custom map control button — premium styled, text-based (no icon font needed).
  Widget _mapControlBtn({
    required String label,
    required String tooltip,
    VoidCallback? onTap,
    Color color = const Color(0xFF1D4ED8),
    Widget? child,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF0F4FF)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E7FF), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D4ED8).withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: child ??
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.0,
                  ),
                ),
              ),
        ),
      ),
    );
  }

  // ─── External Navigation ────────────────────────────────────────────────────
  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Google Maps')),
        );
      }
    }
  }

  // ─── Geocode ────────────────────────────────────────────────────────────────

  // ─── OpenChargeMap API ────────────────────────────────────────────────────
  Future<List<_Station>> _fetchOpenChargeMap(
    double lat,
    double lng,
    int distanceKm, {
    int maxResults = 40,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.openchargemap.io/v3/poi'
        '?distance=$distanceKm'
        '&latitude=$lat'
        '&longitude=$lng'
        '&maxresults=$maxResults',
      );
      final resp = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) {
        debugPrint('OpenChargeMap error ${resp.statusCode}');
        return [];
      }

      final list = jsonDecode(resp.body) as List<dynamic>;
      final stations = <_Station>[];
      for (final item in list) {
        try {
          final m = item as Map<String, dynamic>;
          final al = m['AddressInfo'] as Map<String, dynamic>?;
          if (al == null) continue;
          final title = al['Title'] as String? ?? 'EV Station';
          final line1 = al['AddressLine1'] as String? ?? '';
          final town = al['Town'] as String? ?? '';
          final latNum = al['Latitude'] as num?;
          final lngNum = al['Longitude'] as num?;

          String? chargerType;
          final connections = m['Connections'] as List<dynamic>?;
          if (connections != null && connections.isNotEmpty) {
            final firstConn = connections.first as Map<String, dynamic>;
            final connType = firstConn['ConnectionType']?['Title'] as String?;
            final level = firstConn['Level']?['Title'] as String?;
            final power = firstConn['PowerKW'] as num?;
            if (connType != null) {
              chargerType = connType;
              if (power != null) chargerType += ' ($power kW)';
            } else if (level != null) {
              chargerType = level;
            }
          }

          if (latNum != null && lngNum != null) {
            stations.add(
              _Station(
                name: title,
                address: [line1, town].where((s) => s.isNotEmpty).join(', '),
                position: LatLng(latNum.toDouble(), lngNum.toDouble()),
                chargerType: chargerType,
              ),
            );
          }
        } catch (_) {
          continue;
        }
      }
      return stations;
    } catch (e) {
      debugPrint('OpenChargeMap exception: $e');
      return [];
    }
  }

  // ─── OSM Overpass – nearby EV chargers ───────────────────────────────────
  Future<List<_Station>> _fetchOverpassStations({
    double? lat,
    double? lng,
    double? radiusM,
    double? minLat,
    double? minLng,
    double? maxLat,
    double? maxLng,
  }) async {
    try {
      String spatialFilter;
      if (minLat != null &&
          minLng != null &&
          maxLat != null &&
          maxLng != null) {
        spatialFilter = '($minLat,$minLng,$maxLat,$maxLng)';
      } else if (lat != null && lng != null && radiusM != null) {
        spatialFilter = '(around:$radiusM,$lat,$lng)';
      } else {
        return [];
      }

      final query =
          '[out:json][timeout:30];'
          '(node["amenity"="charging_station"]$spatialFilter;'
          ' way["amenity"="charging_station"]$spatialFilter;);'
          'out center 600;';
      final url = Uri.parse('https://overpass-api.de/api/interpreter');
      final resp = await http
          .post(url, body: 'data=${Uri.encodeComponent(query)}')
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode != 200) return [];

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final elements = json['elements'] as List<dynamic>? ?? [];
      final stations = <_Station>[];
      for (final el in elements) {
        final m = el as Map<String, dynamic>;
        final sLat = (m['lat'] ?? m['center']?['lat']) as num?;
        final sLng = (m['lon'] ?? m['center']?['lon']) as num?;
        if (sLat == null || sLng == null) continue;
        final tags = m['tags'] as Map<String, dynamic>? ?? {};
        final name =
            (tags['name'] ?? tags['operator'] ?? 'EV Charging Station')
                as String;
        final addr = [
          tags['addr:street'],
          tags['addr:city'],
        ].where((v) => v != null).join(', ');
        
        String? chargerType;
        if (tags['socket:type2:output'] != null) {
          chargerType = 'Type 2 (${tags['socket:type2:output']})';
        } else if (tags['socket:ccs:output'] != null) {
          chargerType = 'CCS (${tags['socket:ccs:output']})';
        } else if (tags['socket:chademo'] != null) {
          chargerType = 'CHAdeMO';
        } else if (tags['capacity'] != null) {
          chargerType = '${tags['capacity']} stations';
        }

        stations.add(
          _Station(
            name: name,
            address: addr,
            position: LatLng(sLat.toDouble(), sLng.toDouble()),
            chargerType: chargerType,
          ),
        );
      }
      return stations;
    } catch (e) {
      debugPrint('Overpass error: $e');
      return [];
    }
  }

  // ─── Option 1: Find Nearest Stations ─────────────────────────────────────
  Future<void> _findNearestStations() async {
    if (_isLocating || _isRouting) return;

    if (_showEcabbzOnly) {
      _applyEcabbzFilter();
      return;
    }

    if (_userLatLng == null) {
      setState(() => _isLocating = true);
      await _fetchUserLocation(centerMap: true);
      if (_userLatLng == null) {
        if (mounted) setState(() => _isLocating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please allow location access first')),
        );
        return;
      }
    }

    setState(() {
      _mode = _MapMode.nearest;
      _isRouting = true;
      _stationList = [];
      _routePoints = [];
      _fromLatLng = null;
      _toLatLng = null;
      _viaLatLng = null;
      _routeAlternatives = [];
      _selectedRouteIndex = 0;
    });

    final lat = _userLatLng!.latitude;
    final lng = _userLatLng!.longitude;
    debugPrint('🔍 [Stations] Finding nearest stations around $lat, $lng...');

    // Try OSM Overpass first – has rich India EV station data
    List<_Station> found = await _fetchOverpassStations(
      lat: lat,
      lng: lng,
      radiusM: 30000,
    );
    if (found.isEmpty) {
      debugPrint('ℹ️ [Stations] No stations in 30km, expanding to 100km...');
      found = await _fetchOverpassStations(lat: lat, lng: lng, radiusM: 100000);
    }
    // Fallback to OpenChargeMap
    if (found.isEmpty) {
      debugPrint('ℹ️ [Stations] Trying fallback API (OpenChargeMap)...');
      found = await _fetchOpenChargeMap(lat, lng, 150);
    }
    if (found.isEmpty) {
      found = await _fetchOpenChargeMap(lat, lng, 300, maxResults: 50);
    }

    if (mounted) {
      debugPrint('✨ [Stations] Found ${found.length} stations in total.');
      setState(() {
        _stationList = found.take(15).toList();
        _isRouting = false;
      });
      if (found.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No EV stations found in your area (300 km radius).'),
          ),
        );
      }
    }

    // Fit map
    if (found.isNotEmpty) {
      final allPoints = [
        _userLatLng!,
        ...found.take(10).map((s) => s.position),
      ];
      _fitMap(allPoints);
    } else {
      _mapController.move(_userLatLng!, 11.0);
    }
  }

  // ─── Switch alternate route + refresh stations ────────────────────────────
  void _selectRoute(int index) {
    if (index < 0 || index >= _routeAlternatives.length) return;
    final geom = _routeAlternatives[index]['geometry'] as Map<String, dynamic>?;
    if (geom == null) return;
    final coordList = geom['coordinates'] as List<dynamic>? ?? [];
    final pts = coordList.map((c) {
      final pair = c as List<dynamic>;
      return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
    }).toList();

    setState(() {
      _selectedRouteIndex = index;
      _routePoints = pts;
      _stationList = [];         // Clear old stations immediately
      _isRouting = true;         // Show loading indicator
    });

    // Re-fetch stations specific to this route
    _fetchStationsForRoute(pts);
  }

  // ─── Option 2: Plan Route ─────────────────────────────────────────────────
  Future<void> _planRoute() async {
    final from = _fromCtrl.text.trim();
    final to = _toCtrl.text.trim();

    if (from.isEmpty || to.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both From and To locations'),
        ),
      );
      return;
    }
    if (_isLocating || _isRouting) return;

    setState(() {
      _mode = _MapMode.route;
      _isRouting = true;
      _stationList = [];
      _routePoints = [];
      _fromLatLng = null;
      _toLatLng = null;
      _viaLatLng = null;
      _routeAlternatives = [];
    });

    // Geocode or use Current Location
    LatLng? fromLL = _fromLatLng;
    if (fromLL == null) {
      if (from.toLowerCase().trim() == 'my location' || from == 'My Location') {
        fromLL = _userLatLng;
      } else {
        final matches = LocationService().search(from, limit: 1);
        if (matches.isNotEmpty) {
           fromLL = matches.first.latLng;
           _fromLatLng = fromLL;
        }
      }
    }
    
    LatLng? toLL = _toLatLng;
    if (toLL == null) {
      final matches = LocationService().search(to, limit: 1);
      if (matches.isNotEmpty) {
         toLL = matches.first.latLng;
         _toLatLng = toLL;
      }
    }
    
    LatLng? viaLL = _viaLatLng;

    if (fromLL == null || toLL == null) {
      if (!mounted) return;
      setState(() => _isRouting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select locations from the suggestions list.',
          ),
        ),
      );
      return;
    }

    final waypoints = <LatLng>[fromLL];
    if (viaLL != null) waypoints.add(viaLL);
    waypoints.add(toLL);

    // Fetch route from OSRM
    final routePts = await _fetchOsrmRoute(waypoints);

    if (mounted) {
      setState(() {
        _fromLatLng = fromLL;
        _toLatLng = toLL;
        _viaLatLng = viaLL;
        _routePoints = routePts.length >= 2 ? routePts : waypoints;
      });
    }

    // EV stations along route using Overpass (Bounding Box + Polyline Buffer)
    final effectivePts = routePts.length >= 2 ? routePts : waypoints;
    _fitMap(effectivePts);
    await _fetchStationsForRoute(effectivePts);
  }

  Future<void> _fetchStationsForRoute(List<LatLng> effectivePts) async {
    if (_showEcabbzOnly) {
      setState(() {
        _stationList = _ecabbzStations;
        _isRouting = false;
      });
      return;
    }

    if (!mounted || effectivePts.isEmpty) {
      if (mounted) setState(() => _isRouting = false);
      return;
    }

    try {
      // 1. Calculate approximate total distance
      double totalDist = 0;
      for (int i = 0; i < effectivePts.length - 1; i++) {
        totalDist += _distKm(
          effectivePts[i].latitude,
          effectivePts[i].longitude,
          effectivePts[i + 1].latitude,
          effectivePts[i + 1].longitude,
        );
      }

      // 2. Segment route if it's long (over 200km)
      final List<List<LatLng>> segments = [];
      if (totalDist > 200) {
        final int numSegments = (totalDist / 150).ceil();
        final int ptsPerSeg = (effectivePts.length / numSegments).ceil();
        for (int i = 0; i < effectivePts.length; i += ptsPerSeg) {
          final endIdx = math.min(i + ptsPerSeg + 1, effectivePts.length);
          segments.add(effectivePts.sublist(i, endIdx));
        }
      } else {
        segments.add(effectivePts);
      }

      debugPrint('🗺️ [Stations] Route distance: ${totalDist.toStringAsFixed(1)}km. Split into ${segments.length} segments.');

      // 3. Fetch stations for each segment
      final List<_Station> allFound = [];
      for (final segment in segments) {
        final lats = segment.map((p) => p.latitude).toList();
        final lngs = segment.map((p) => p.longitude).toList();

        final minLat = lats.reduce(math.min) - 0.08;
        final maxLat = lats.reduce(math.max) + 0.08;
        final minLng = lngs.reduce(math.min) - 0.08;
        final maxLng = lngs.reduce(math.max) + 0.08;

        final stations = await _fetchOverpassStations(
          minLat: minLat,
          minLng: minLng,
          maxLat: maxLat,
          maxLng: maxLng,
        );
        allFound.addAll(stations);
      }

      // 4. Deduplicate (by location/name)
      final uniqueMap = <String, _Station>{};
      for (final s in allFound) {
        final key = '${s.position.latitude.toStringAsFixed(5)}_${s.position.longitude.toStringAsFixed(5)}';
        uniqueMap[key] = s;
      }

      // 5. Filter for distance to the ACTUAL route line
      final filtered = uniqueMap.values
          .where(
            (s) =>
                _distToRoutePoly(
                  s.position.latitude,
                  s.position.longitude,
                  effectivePts,
                ) <=
                3.0, // increased to 3km for better highway coverage
          )
          .toList();

      debugPrint('🔍 [Stations] Found ${uniqueMap.length} unique → ${filtered.length} within 3km of route');
      if (mounted) {
        setState(() {
          _stationList = filtered;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isRouting = false);
      }
    }
  }

  // ─── OSRM Directions ───────────────────────────────────────────────────────
  Future<List<LatLng>> _fetchOsrmRoute(List<LatLng> waypoints) async {
    try {
      final coordsStr = waypoints
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$coordsStr?overview=full&geometries=geojson&alternatives=true',
      );

      final resp = await http.get(url).timeout(const Duration(seconds: 20));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          if (mounted) {
            setState(() {
              _routeAlternatives = routes.map((e) => e as Map<String, dynamic>).toList();
            });
          }

          final route = routes[_selectedRouteIndex];
          final geom = route['geometry'] as Map<String, dynamic>?;
          if (geom != null) {
            final coordList = geom['coordinates'] as List<dynamic>? ?? [];
            return coordList.map((c) {
              final pair = c as List<dynamic>;
              return LatLng(
                (pair[1] as num).toDouble(),
                (pair[0] as num).toDouble(),
              );
            }).toList();
          }
        }
      } else {
        debugPrint('OSRM error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      debugPrint('OSRM exception: $e');
    }
    return [];
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  double _distKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _distToSegKm(
    double lat,
    double lng,
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dx = lat2 - lat1, dy = lng2 - lng1;
    if (dx == 0 && dy == 0) return _distKm(lat, lng, lat1, lng1);
    final t = ((lat - lat1) * dx + (lng - lng1) * dy) / (dx * dx + dy * dy);
    final c = t.clamp(0.0, 1.0);
    return _distKm(lat, lng, lat1 + c * dx, lng1 + c * dy);
  }

  double _distToRoutePoly(double lat, double lng, List<LatLng> poly) {
    double min = double.infinity;
    // Lower step size for better accuracy on sharp turns
    const int step = 2;
    for (int i = 0; i < poly.length - 1; i += step) {
      final next = (i + step < poly.length) ? i + step : poly.length - 1;
      final d = _distToSegKm(
        lat,
        lng,
        poly[i].latitude,
        poly[i].longitude,
        poly[next].latitude,
        poly[next].longitude,
      );
      if (d < min) min = d;
      if (min < 0.05) break; // Very close
    }
    return min;
  }

  void _fitMap(List<LatLng> points) {
    if (points.isEmpty || !_mapReady) return;
    final lats = points.map((p) => p.latitude).toList();
    final lngs = points.map((p) => p.longitude).toList();
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(lats.reduce(math.min), lngs.reduce(math.min)),
          LatLng(lats.reduce(math.max), lngs.reduce(math.max)),
        ),
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  // ─── Build Markers ─────────────────────────────────────────────────────────
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_userLatLng != null) {
      markers.add(
        Marker(
          point: _userLatLng!,
          width: 36,
          height: 36,
          child: Tooltip(
            message: 'Your Location',
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D4ED8).withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    for (final s in _stationList) {
      final isEcabbz = s.source == 'ecabbz';
      markers.add(
        Marker(
          point: s.position,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _openInGoogleMaps(s.position.latitude, s.position.longitude),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Tooltip(
                message: '${s.name}\n${s.address}',
                child: Container(
                  decoration: BoxDecoration(
                    color: isEcabbz ? const Color(0xFF16A34A) : const Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isEcabbz ? Icons.bolt : Icons.ev_station,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_fromLatLng != null) {
      // Avoid showing the Start marker if it's identical to the You dot
      final isStartAtUser = _userLatLng != null && 
          (_userLatLng!.latitude - _fromLatLng!.latitude).abs() < 0.0001 &&
          (_userLatLng!.longitude - _fromLatLng!.longitude).abs() < 0.0001;

      if (!isStartAtUser) {
        markers.add(
          Marker(
            point: _fromLatLng!,
            width: 32,
            height: 32,
            child: Tooltip(
              message: 'Start: ${_fromCtrl.text}',
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.trip_origin,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        );
      }
    }

    if (_viaLatLng != null) {
      markers.add(
        Marker(
          point: _viaLatLng!,
          width: 28,
          height: 28,
          child: Tooltip(
            message: 'Via: ${_viaCtrl.text}',
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD97706),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      );
    }

    if (_toLatLng != null) {
      markers.add(
        Marker(
          point: _toLatLng!,
          width: 32,
          height: 32,
          child: Tooltip(
            message: 'Destination: ${_toCtrl.text}',
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isMobile = sw < 768; // Standard breakpoint for tablets
    final isTablet = sw >= 768 && sw < 1100;
    final isDesktop = sw >= 1100;
    final isModern = context.isModernStyle;

    final activeGreen = context.isYellowTheme
        ? const Color(0xFFF59E0B)
        : const Color(0xFF16A34A);
    final activeAmber = const Color(0xFFF59E0B);
    final textDark = const Color(0xFF111827);

    if (!isModern) return _buildClassic(context, isMobile);

    final hPad = isMobile
        ? 24.0
        : isTablet
        ? 60.0
        : 120.0;

    return GestureDetector(
      onTap: _hideAllSuggestions,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: double.infinity,
        color: const Color(0xFFF9FAFB),
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 60 : 100,
          horizontal: hPad,
        ),
        child: Column(
          children: [
          Text(
            AppLocalizations.of(context)?.chargingNetwork ?? 'CHARGING NETWORK',
            style: GoogleFonts.poppins(
              color: activeGreen,
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)?.exploreSouthIndia ?? 'Explore South India',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 32 : isTablet ? 42 : 56,
              fontWeight: FontWeight.w800,
              color: textDark,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 700),
            child: Text(
              AppLocalizations.of(context)?.chargingNetworkDescription ?? 'Find the nearest charging stations or plan your journey with optimized stops. High-speed charging at your fingertips.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF6B7280),
                fontSize: isMobile ? 15 : 18,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 48 : 64),

          // ── Stats Row ────────────────────────────────────────────────────────
          Wrap(
            spacing: isMobile ? 12 : 20,
            runSpacing: isMobile ? 12 : 20,
            alignment: WrapAlignment.center,
            children: [
              _statCard(
                '50+',
                AppLocalizations.of(context)?.stations ?? 'Stations',
                Icons.ev_station,
                activeGreen,
                isMobile,
                isTablet,
              ),
              _statCard(
                '4',
                AppLocalizations.of(context)?.states ?? 'States',
                Icons.map,
                activeAmber,
                isMobile,
                isTablet,
              ),
              _statCard(
                '24/7',
                AppLocalizations.of(context)?.availability ?? 'Availability',
                Icons.access_time,
                const Color(0xFF3B82F6),
                isMobile,
                isTablet,
              ),
              _statCard(
                '100%',
                AppLocalizations.of(context)?.reliable ?? 'Reliable',
                Icons.verified_user_outlined,
                const Color(0xFF10B981),
                isMobile,
                isTablet,
              ),
            ],
          ),
          SizedBox(height: isMobile ? 48 : 80),

          // ── Map + Controls ────────────────────────────────────────────────────
          (isDesktop || isTablet)
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isDesktop ? 65 : 60,
                        child: _buildMap(isMobile, isTablet, isDesktop, activeGreen),
                      ),
                      SizedBox(width: isDesktop ? 48 : 32),
                      Expanded(
                        flex: isDesktop ? 35 : 40,
                        child: _buildControlPanel(
                          context,
                          isMobile,
                          activeGreen,
                          activeAmber,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildMap(isMobile, isTablet, isDesktop, activeGreen),
                    const SizedBox(height: 32),
                    _buildControlPanel(
                      context,
                      isMobile,
                      activeGreen,
                      activeAmber,
                    ),
                  ],
                ),
        ],
      ),
    ),
  );
}

  // ─── Map Widget ──────────────────────────────────────────────────────────────
  Widget _buildMap(bool isMobile, bool isTablet, bool isDesktop, Color activeGreen) {
    double mapHeight = 360; // Mobile
    if (isDesktop) {
      mapHeight = 650;
    } else if (isTablet) {
      mapHeight = 580;
    }

    return Container(
      height: mapHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // ── FlutterMap ──────────────────────────────────────────────────
            if (!_isLoadingLocation)
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _userLatLng ?? const LatLng(9.9312, 76.2673),
                  initialZoom: 14.0,
                  onMapReady: _onMapReady,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.evtaxi.demo',
                  maxNativeZoom: 19,
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                // ── Alternate routes (light grey, behind) ────────────────
                if (_routeAlternatives.length > 1)
                  ..._routeAlternatives.asMap().entries
                      .where((e) => e.key != _selectedRouteIndex)
                      .map((e) {
                    final coordList = ((e.value['geometry']
                            as Map<String, dynamic>?)?['coordinates']
                        as List<dynamic>?) ??
                        [];
                    final pts = coordList.map((c) {
                      final pair = c as List<dynamic>;
                      return LatLng(
                        (pair[1] as num).toDouble(),
                        (pair[0] as num).toDouble(),
                      );
                    }).toList();
                    return GestureDetector(
                      onTap: () => _selectRoute(e.key),
                      child: PolylineLayer(
                        polylines: [
                          Polyline(
                            points: pts,
                            color: const Color(0xFFB0BEC5),
                            strokeWidth: 5.0,
                            borderColor: const Color(0xFF90A4AE),
                            borderStrokeWidth: 1.0,
                          ),
                        ],
                      ),
                    );
                  }),
                // ── Selected route (blue, on top) ────────────────────────
                if (_routePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: const Color(0xFF4F46E5),
                        strokeWidth: 5.5,
                        borderColor: const Color(0xFF3730A3),
                        borderStrokeWidth: 1.0,
                      ),
                    ],
                  ),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),

            // ── Legend pill ─────────────────────────────────────────────────
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.93),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _legendDot(const Color(0xFF1D4ED8)),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)?.youLegend ?? 'You',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _legendDot(const Color(0xFF16A34A)),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)?.stationLegend ?? 'Station',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    if (_mode == _MapMode.route) ...[
                      const SizedBox(width: 12),
                      _legendDot(const Color(0xFF4F46E5), size: 10),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)?.routeLegend ?? 'Route',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Charger Toggle ──────────────────────────────────────────────
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: _buildChargerToggle(context),
              ),
            ),

            // ── Map Controls ────────────────────────────────────────────────
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _mapControlBtn(
                    label: '+',
                    tooltip: AppLocalizations.of(context)?.zoomIn ?? 'Zoom In',
                    onTap: () {
                      final z = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, z + 1);
                    },
                  ),
                  const SizedBox(height: 8),
                  _mapControlBtn(
                    label: '−',
                    tooltip: AppLocalizations.of(context)?.zoomOut ?? 'Zoom Out',
                    onTap: () {
                      final z = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, z - 1);
                    },
                  ),
                  const SizedBox(height: 16),
                  _mapControlBtn(
                    label: '⊕',
                    tooltip: AppLocalizations.of(context)?.myLocation ?? 'My Location',
                    color: const Color(0xFF1D4ED8),
                    onTap: _isLocating ? null : () => _fetchUserLocation(centerMap: true),
                    child: _isLocating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CustomPaint(
                                painter: _CrosshairPainter(
                                  color: const Color(0xFF1D4ED8),
                                  strokeWidth: 2.0,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // ── Loading overlay ─────────────────────────────────────────────
            if (_isRouting || _isLoadingLocation)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.18),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _isLoadingLocation
                                ? (AppLocalizations.of(context)?.gettingLocation ?? 'Getting your location...')
                                : (_mode == _MapMode.nearest
                                    ? (AppLocalizations.of(context)?.findingStations ?? 'Finding Stations...')
                                    : (AppLocalizations.of(context)?.planningRoute ?? 'Planning Route...')),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargerToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn(
            label: 'ecabbz',
            isSelected: _showEcabbzOnly,
            onTap: () {
              if (!_showEcabbzOnly) {
                setState(() => _showEcabbzOnly = true);
                _applyEcabbzFilter();
              }
            },
            activeColor: const Color(0xFF16A34A),
          ),
          _toggleBtn(
            label: 'Others',
            isSelected: !_showEcabbzOnly,
            onTap: () {
              if (_showEcabbzOnly) {
                setState(() => _showEcabbzOnly = false);
                _findNearestStations();
              }
            },
            activeColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, {double size = 8}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  // ─── Control Panel ────────────────────────────────────────────────────────
  Widget _buildControlPanel(
    BuildContext context,
    bool isMobile,
    Color green,
    Color amber,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The Pill Toggle
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTabButton(AppLocalizations.of(context)?.findNearest ?? 'Find Nearest', _mode == _MapMode.nearest, () {
                      if (_mode != _MapMode.nearest) {
                        setState(() {
                          _mode = _MapMode.nearest;
                          _routePoints = [];
                          _routeAlternatives = [];
                          _fromLatLng = null;
                          _toLatLng = null;
                          _viaLatLng = null;
                          _stationList = [];
                        });
                        if (_userLatLng != null && _mapReady) {
                          _mapController.move(_userLatLng!, 14.0);
                        }
                        _findNearestStations();
                      }
                    }),
                    _buildTabButton(AppLocalizations.of(context)?.planRoute ?? 'Plan Route', _mode == _MapMode.route || _mode == _MapMode.idle, () {
                      setState(() => _mode = _MapMode.route);
                    }),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          if (_mode == _MapMode.nearest) 
            _buildNearestView() // Restore nearest simple logic
          else
            _buildRouteView(), // The main thing user wants

          const SizedBox(height: 20),

          // ── Legend info ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Green dots = EV stations  •  Blue dot = You  •  Indigo line = Route  •  Powered by OpenStreetMap',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF166534),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearestView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_isLocating || _isRouting)
                ? null
                : _findNearestStations,
            icon:
                (_isLocating || (_isRouting && _mode == _MapMode.nearest))
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.bolt, size: 18),
            label: Text(
              'Find Nearest Charging',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        if (_mode == _MapMode.nearest && _stationList.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildStationList(const Color(0xFF16A34A)),
        ],
      ],
    );
  }

  Widget _buildRouteView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Your Journey',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Calculate the best route with optimized charging stops along the way.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Input Fields
        _buildInputField(
          'Starting Point', 
          _fromCtrl, 
          'My Location',
          isFrom: true,
          onGPSClick: _onGPSShortcutClicked,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          'Destination', 
          _toCtrl, 
          'Kollam, Kerala',
          isFrom: false,
        ),
        
        const SizedBox(height: 24),
        
        // Calculate Route Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isLocating || _isRouting) ? null : () {
              // ensure we reset index when planning a new route
              _selectedRouteIndex = 0;
              _planRoute();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB), // Blue color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isRouting && _mode == _MapMode.route
                ? const SizedBox(
                    width: 20, height: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    'Calculate Route',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        
        if (_routeAlternatives.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Select Alternative Path:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_routeAlternatives.length, (index) {
                final route = _routeAlternatives[index];
                final distKm = (route['distance'] as num? ?? 0) / 1000;
                final durMin = (route['duration'] as num? ?? 0) / 60;
                final isSelected = _selectedRouteIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => _selectRoute(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Alt ${index + 1}: ${distKm.toStringAsFixed(1)} km • ${durMin.toStringAsFixed(0)} min',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],

        if (_stationList.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            '${_stationList.length} stations found',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 12),
          ...(_stationList.take(5).map((s) => _buildUIStationCard(s))),
          if (_stationList.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+ ${_stationList.length - 5} more on map',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
        ],
      ],
    );
  }


  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
              fontSize: 12.5,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label, 
    TextEditingController controller, 
    String hint, {
    bool isFrom = false,
    VoidCallback? onGPSClick,
  }) {
    final suggestions = isFrom ? _fromSuggestions : _toSuggestions;
    final showSuggestions = isFrom ? _showFromSuggestions : _showToSuggestions;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: controller,
                onChanged: (val) {
                  setState(() {
                    if (isFrom) {
                      _fromLatLng = null;
                    } else {
                      _toLatLng = null;
                    }
                  });
                  _fetchSuggestions(val, isFrom);
                },
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF111827),
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.poppins(color: const Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: const Icon(Icons.location_on, size: 18, color: Color(0xFF9CA3AF)),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFrom)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: onGPSClick,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF16A34A), Color(0xFF10B981)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF16A34A).withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CustomPaint(
                                    painter: _CrosshairPainter(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (controller.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: Colors.black87),
                          onPressed: () {
                            controller.clear();
                            setState(() {
                              if (isFrom) {
                                _fromLatLng = null;
                                _fromSuggestions = [];
                                _showFromSuggestions = false;
                              } else {
                                _toLatLng = null;
                                _toSuggestions = [];
                                _showToSuggestions = false;
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 12,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showSuggestions && suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final item = suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    item['display'],
                    style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF374151)),
                  ),
                  onTap: () {
                    final suggestion = item['suggestion'] as PlaceSuggestion?;
                    final latLng = suggestion?.latLng;
                    
                    setState(() {
                      controller.text = item['display'];
                      if (isFrom) {
                        _fromLatLng = latLng;
                        if (_fromLatLng != null) {
                          _mapController.move(_fromLatLng!, 14.0);
                        }
                        _showFromSuggestions = false;
                      } else {
                        _toLatLng = latLng;
                        if (_toLatLng != null) {
                          _mapController.move(_toLatLng!, 14.0);
                        }
                        _showToSuggestions = false;
                      }
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildUIStationCard(_Station station) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      'Near by location',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStationList(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_stationList.length} station${_stationList.length == 1 ? '' : 's'} found',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 8),
        ...(_stationList.take(5).map((s) => _StationTile(station: s))),
        if (_stationList.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '+ ${_stationList.length - 5} more on map',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statCard(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isMobile,
    bool isTablet,
  ) {
    final double padH = isMobile ? 16 : isTablet ? 20 : 28;
    final double padV = isMobile ? 12 : isTablet ? 16 : 24;
    final double iconSize = isMobile ? 36 : 48;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: iconSize * 0.5),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassic(BuildContext context, bool isMobile) {
    final isV2 = context.isV2Theme;
    final activeGreen = context.isYellowTheme
        ? const Color(0xFFF59E0B)
        : (isV2 ? const Color(0xFF16A34A) : AppTheme.primaryColor);
    return Container(
      color: isV2
          ? const Color(0xFFF9FAFB)
          : Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: MediaQuery.of(context).size.width >= 1024 ? 80 : 20,
      ),
      child: Column(
        children: [
          Text(
            'CHARGING NETWORK',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: activeGreen,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Classic View Enabled'),
        ],
      ),
    );
  }
}

// ─── Station Tile ──────────────────────────────────────────────────────────────
class _StationTile extends StatelessWidget {
  final _Station station;
  const _StationTile({required this.station});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final state = context.findAncestorStateOfType<_EVMapPageState>();
        state?._openInGoogleMaps(
          station.position.latitude,
          station.position.longitude,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFBBF7D0).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.ev_station,
                color: Colors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (station.address.isNotEmpty)
                    Text(
                      station.address,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const Icon(Icons.directions, size: 16, color: Color(0xFF166534)),
          ],
        ),
      ),
    );
  }
}

