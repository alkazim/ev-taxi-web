import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mappls_gl/mappls_gl.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import '../../theme/app_theme.dart';
import '../../services/location_service.dart';

// ─── Constants ───────────────────────────────────────────────────────────────
const _kCachePrefix = 'ev_stations_';
const _kCacheTtlMs = 30 * 60 * 1000; // 30 minutes

// Hardcoded fallback list (used for along-route station display)
const _kFallbackStations = [
  {'name': 'Kochi Fast Charger', 'lat': 9.9312, 'lng': 76.2673},
  {'name': 'Trivandrum Hub', 'lat': 8.4875, 'lng': 76.9492},
  {'name': 'Calicut Power Station', 'lat': 11.2588, 'lng': 75.7804},
  {'name': 'Thrissur Charging Point', 'lat': 10.5276, 'lng': 76.2144},
  {'name': 'Palakkad Green Port', 'lat': 10.7867, 'lng': 76.6547},
  {'name': 'Coimbatore EV Hub', 'lat': 11.0168, 'lng': 76.9558},
  {'name': 'Mysuru Charge Zone', 'lat': 12.2958, 'lng': 76.6394},
  {'name': 'Bangalore Power Bay', 'lat': 12.9716, 'lng': 77.5946},
  {'name': 'Salem Station', 'lat': 11.6643, 'lng': 78.1460},
  {'name': 'Chennai FastCharge', 'lat': 13.0827, 'lng': 80.2707},
  {'name': 'Ernakulam Central', 'lat': 9.9816, 'lng': 76.2999},
  {'name': 'Kollam Charge Hub', 'lat': 8.8832, 'lng': 76.5940},
  {'name': 'Kannur EV Point', 'lat': 11.8745, 'lng': 75.3704},
  {'name': 'Mangalore Station', 'lat': 12.9141, 'lng': 74.8560},
  {'name': 'Hosur Green Bay', 'lat': 12.7409, 'lng': 77.8253},
  {'name': 'Dharwad EV Hub', 'lat': 15.4589, 'lng': 75.0078},
  {'name': 'Hubli ChargePoint', 'lat': 15.3647, 'lng': 75.1240},
  {'name': 'Tiruppur Fast', 'lat': 11.1085, 'lng': 77.3411},
  {'name': 'Madurai EV Bay', 'lat': 9.9252, 'lng': 78.1198},
];

// ─── Mode Enum ───────────────────────────────────────────────────────────────
enum _MapMode { idle, nearest, route }

// ─── Station Model ────────────────────────────────────────────────────────────
class _Station {
  final String name;
  final String address;
  final LatLng position;
  _Station({required this.name, required this.address, required this.position});
}

class EVStationsSection extends StatefulWidget {
  const EVStationsSection({super.key});

  @override
  State<EVStationsSection> createState() => _EVStationsSectionState();
}

class _EVStationsSectionState extends State<EVStationsSection> {
  MapplsMapController? _mapController;
  LatLng? _userLocation;

  _MapMode _mode = _MapMode.idle;
  bool _isLocating = false;
  bool _isRouting = false;

  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  LatLng? _fromLatLng;
  LatLng? _toLatLng;

  Timer? _debounceTimer;
  List<PlaceSuggestion> _fromSuggestions = [];
  List<PlaceSuggestion> _toSuggestions = [];
  bool _showFromSuggestions = false;
  bool _showToSuggestions = false;

  // Map elements
  final List<Circle> _drawnCircles = [];
  Line? _drawnRoute;

  // Station info list (for panel display)
  List<_Station> _stationList = [];
  String _routeInfo = '';

  // ─── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ─── Map Callbacks ──────────────────────────────────────────────────────────
  void _onMapCreated(MapplsMapController controller) {
    _mapController = controller;
  }

  void _onStyleLoaded() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _fetchUserLocation(centerMap: true, silent: true);
    });
  }

  // ─── Location ───────────────────────────────────────────────────────────────
  void _fetchUserLocation({bool centerMap = false, bool silent = false}) {
    if (!mounted) return;
    if (!silent) setState(() => _isLocating = true);
    try {
      web.window.navigator.geolocation.getCurrentPosition(
        (web.GeolocationPosition pos) {
          if (!mounted) return;
          _userLocation = LatLng(pos.coords.latitude, pos.coords.longitude);
          if (!silent) setState(() => _isLocating = false);
          _drawUserDot();
          if (centerMap) _panToUser();
        }.toJS,
        (web.GeolocationPositionError err) {
          if (!mounted) return;
          if (!silent) setState(() => _isLocating = false);
        }.toJS,
      );
    } catch (e) {
      if (!silent) setState(() => _isLocating = false);
    }
  }

  void _panToUser() {
    if (_mapController == null || _userLocation == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _userLocation!, zoom: 12.0),
      ),
    );
  }

  Future<void> _drawUserDot() async {
    final ctrl = _mapController;
    if (ctrl == null || _userLocation == null) return;
    await ctrl.addCircle(
      CircleOptions(
        geometry: _userLocation!,
        circleRadius: 22,
        circleColor: '#3B82F6',
        circleOpacity: 0.18,
        circleStrokeWidth: 0,
      ),
    );
    await ctrl.addCircle(
      CircleOptions(
        geometry: _userLocation!,
        circleRadius: 10,
        circleColor: '#1D4ED8',
        circleOpacity: 1.0,
        circleStrokeWidth: 3,
        circleStrokeColor: '#FFFFFF',
        circleStrokeOpacity: 1.0,
      ),
    );
  }

  // ─── Map Cleanup ─────────────────────────────────────────────────────────────
  Future<void> _clearMap() async {
    final ctrl = _mapController;
    if (ctrl == null) return;
    for (final c in _drawnCircles) {
      await ctrl.removeCircle(c);
    }
    _drawnCircles.clear();
    if (_drawnRoute != null) {
      await ctrl.removeLine(_drawnRoute!);
      _drawnRoute = null;
    }
  }

  Future<void> _drawStationDot(LatLng pos) async {
    final ctrl = _mapController;
    if (ctrl == null) return;
    final c = await ctrl.addCircle(
      CircleOptions(
        geometry: pos,
        circleRadius: 10,
        circleColor: '#16A34A',
        circleOpacity: 1.0,
        circleStrokeWidth: 2,
        circleStrokeColor: '#FFFFFF',
        circleStrokeOpacity: 1.0,
      ),
    );
    _drawnCircles.add(c);
  }

  // ─── XHR Helper ──────────────────────────────────────────────────────────────
  Future<String?> _xhrGet(String url) {
    final completer = Completer<String?>();
    final xhr = web.XMLHttpRequest();
    xhr.open('GET', url);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.onload = (web.Event _) {
      if (xhr.status >= 200 && xhr.status < 300) {
        completer.complete(xhr.responseText);
      } else {
        completer.complete(null);
      }
    }.toJS;
    xhr.onerror = (web.Event _) {
      completer.complete(null);
    }.toJS;
    xhr.send();
    return completer.future;
  }

  // ─── localStorage Cache ───────────────────────────────────────────────────────
  String? _readCache(String key) {
    try {
      final raw = web.window.localStorage.getItem(key);
      if (raw == null) return null;
      final obj = jsonDecode(raw) as Map<String, dynamic>;
      final ts = obj['ts'] as int? ?? 0;
      if (DateTime.now().millisecondsSinceEpoch - ts > _kCacheTtlMs) {
        web.window.localStorage.removeItem(key);
        return null;
      }
      return obj['data'] as String?;
    } catch (_) {
      return null;
    }
  }

  void _writeCache(String key, String data) {
    try {
      final obj = jsonEncode({
        'ts': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      });
      web.window.localStorage.setItem(key, obj);
    } catch (_) {}
  }

  // ─── Overpass API: Nearest EV Stations ───────────────────────────────────────
  Future<List<_Station>> _fetchOverpassStations(
    double lat,
    double lng,
    int radiusM,
  ) async {
    final cacheKey =
        '$_kCachePrefix${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}_$radiusM';
    final cached = _readCache(cacheKey);
    if (cached != null) {
      try {
        final list = jsonDecode(cached) as List<dynamic>;
        return list.map((e) {
          final m = e as Map<String, dynamic>;
          return _Station(
            name: m['name'] as String? ?? 'EV Charging Station',
            address: m['address'] as String? ?? '',
            position: LatLng(
              (m['lat'] as num).toDouble(),
              (m['lng'] as num).toDouble(),
            ),
          );
        }).toList();
      } catch (_) {}
    }

    final query =
        '[out:json][timeout:15];'
        'node["amenity"="charging_station"](around:$radiusM,$lat,$lng);'
        'out tags;';
    final url =
        'https://overpass-api.de/api/interpreter'
        '?data=${Uri.encodeComponent(query)}';

    try {
      final body = await _xhrGet(url);
      if (body == null) return [];
      final data = jsonDecode(body) as Map<String, dynamic>;
      final elements = data['elements'] as List<dynamic>? ?? [];
      final stations = elements
          .whereType<Map<String, dynamic>>()
          .where((e) => e['lat'] != null && e['lon'] != null)
          .map((e) {
            final tags = e['tags'] as Map<String, dynamic>? ?? {};
            final name =
                tags['name'] as String? ??
                tags['operator'] as String? ??
                tags['brand'] as String? ??
                'EV Charging Station';
            final addr = [
              tags['addr:street'],
              tags['addr:city'],
            ].where((v) => v != null).join(', ');
            return _Station(
              name: name,
              address: addr,
              position: LatLng(
                (e['lat'] as num).toDouble(),
                (e['lon'] as num).toDouble(),
              ),
            );
          })
          .toList();

      final toCache = stations
          .map(
            (s) => {
              'name': s.name,
              'address': s.address,
              'lat': s.position.latitude,
              'lng': s.position.longitude,
            },
          )
          .toList();
      _writeCache(cacheKey, jsonEncode(toCache));
      return stations;
    } catch (e) {
      debugPrint('Overpass error: $e');
      return [];
    }
  }

  // ─── Option 1: Find Nearest Stations ─────────────────────────────────────────
  Future<void> _findNearestStations() async {
    if (_isLocating || _isRouting) return;
    if (_userLocation == null) {
      setState(() => _isLocating = true);
      web.window.navigator.geolocation.getCurrentPosition(
        (web.GeolocationPosition pos) {
          if (!mounted) return;
          _userLocation = LatLng(pos.coords.latitude, pos.coords.longitude);
          setState(() => _isLocating = false);
          _drawUserDot();
          _runNearestSearch();
        }.toJS,
        (web.GeolocationPositionError err) {
          if (!mounted) return;
          setState(() => _isLocating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please allow location access first')),
          );
        }.toJS,
      );
      return;
    }
    _runNearestSearch();
  }

  Future<void> _runNearestSearch() async {
    final user = _userLocation;
    if (user == null || _mapController == null) return;

    setState(() {
      _mode = _MapMode.nearest;
      _isRouting = true;
      _stationList = [];
      _routeInfo = '';
    });
    await _clearMap();
    await _drawUserDot();

    final lat = user.latitude;
    final lng = user.longitude;

    List<_Station> found = await _fetchOverpassStations(lat, lng, 25000);
    if (found.isEmpty) found = await _fetchOverpassStations(lat, lng, 100000);
    if (found.isEmpty) {
      found =
          _kFallbackStations
              .map(
                (s) => _Station(
                  name: s['name'] as String,
                  address: '',
                  position: LatLng(s['lat'] as double, s['lng'] as double),
                ),
              )
              .toList()
            ..sort(
              (a, b) =>
                  _distKm(
                    lat,
                    lng,
                    a.position.latitude,
                    a.position.longitude,
                  ).compareTo(
                    _distKm(
                      lat,
                      lng,
                      b.position.latitude,
                      b.position.longitude,
                    ),
                  ),
            );
    }

    for (final s in found.take(10)) {
      await _drawStationDot(s.position);
    }

    if (mounted) setState(() => _stationList = found.take(10).toList());

    if (found.isNotEmpty) {
      final allLats = [lat, ...found.take(10).map((s) => s.position.latitude)];
      final allLngs = [lng, ...found.take(10).map((s) => s.position.longitude)];
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              allLats.reduce(math.min) - 0.05,
              allLngs.reduce(math.min) - 0.05,
            ),
            northeast: LatLng(
              allLats.reduce(math.max) + 0.05,
              allLngs.reduce(math.max) + 0.05,
            ),
          ),
          left: 40,
          top: 40,
          right: 40,
          bottom: 40,
        ),
      );
    }
    if (mounted) setState(() => _isRouting = false);
  }

  // ─── OSRM Route ───────────────────────────────────────────────────────────────
  Future<List<LatLng>> _fetchOsrmRoute(List<LatLng> waypoints) async {
    final coordStr = waypoints
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');
    final url =
        'https://router.project-osrm.org/route/v1/driving/$coordStr'
        '?overview=full&geometries=geojson';
    try {
      final body = await _xhrGet(url);
      if (body == null) return [];
      final data = jsonDecode(body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>?;
      if (routes != null && routes.isNotEmpty) {
        final first = routes.first as Map<String, dynamic>;
        final geometry = first['geometry'] as Map<String, dynamic>;
        final coords = geometry['coordinates'] as List<dynamic>;
        final distM = first['distance'] as num? ?? 0;
        final durS = first['duration'] as num? ?? 0;
        if (mounted) {
          setState(
            () => _routeInfo =
                '${(distM / 1000).toStringAsFixed(1)} km  •  ${(durS / 60).toStringAsFixed(0)} min',
          );
        }
        return coords
            .map(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('OSRM error: $e');
    }
    return [];
  }

  // ─── Simple distance helper ────────────────────────────────────────────────────
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

  // ─── Suggestions ────────────────────────────────────────────────────────────
  void _fetchSuggestions(String query, bool isFrom) {
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
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final results = LocationService().search(query, limit: 10);
      if (mounted) {
        setState(() {
          if (isFrom) {
            _fromSuggestions = results;
            _showFromSuggestions = _fromSuggestions.isNotEmpty;
          } else {
            _toSuggestions = results;
            _showToSuggestions = _toSuggestions.isNotEmpty;
          }
        });
      }
    });
  }

  // ─── Option 2: Plan Route ─────────────────────────────────────────────────────
  Future<void> _planRoute() async {
    final fromLatLng = _fromLatLng;
    final toLatLng = _toLatLng;

    if (fromLatLng == null || toLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select locations from the suggestions list.'),
        ),
      );
      return;
    }

    setState(() {
      _mode = _MapMode.route;
      _isRouting = true;
      _stationList = [];
      _routeInfo = '';
    });
    await _clearMap();
    await _drawUserDot();

    final waypoints = <LatLng>[fromLatLng];
    waypoints.add(toLatLng);

    List<LatLng> routePoints = await _fetchOsrmRoute(waypoints);
    if (routePoints.length < 2) {
      routePoints = waypoints;
    }

    final line = await _mapController!.addLine(
      LineOptions(
        geometry: routePoints,
        lineColor: '#4F46E5',
        lineWidth: 5.5,
        lineOpacity: 0.92,
      ),
    );
    _drawnRoute = line;

    await _mapController!.addCircle(
      CircleOptions(
        geometry: fromLatLng,
        circleRadius: 13,
        circleColor: '#1D4ED8',
        circleOpacity: 1.0,
        circleStrokeWidth: 3,
        circleStrokeColor: '#FFFFFF',
      ),
    );
    await _mapController!.addCircle(
      CircleOptions(
        geometry: toLatLng,
        circleRadius: 13,
        circleColor: '#DC2626',
        circleOpacity: 1.0,
        circleStrokeWidth: 3,
        circleStrokeColor: '#FFFFFF',
      ),
    );

    const kThresholdKm = 15.0;
    const kStep = 10;
    final List<_Station> routeStations = [];
    for (final s in _kFallbackStations) {
      final sLat = s['lat'] as double;
      final sLng = s['lng'] as double;
      double minDist = double.infinity;
      for (
        int i = 0;
        i < routePoints.length - 1;
        i += (routePoints.length > 200 ? kStep : 1)
      ) {
        final next = i + 1 < routePoints.length ? i + 1 : i;
        final d = _distToSegKm(
          sLat,
          sLng,
          routePoints[i].latitude,
          routePoints[i].longitude,
          routePoints[next].latitude,
          routePoints[next].longitude,
        );
        if (d < minDist) minDist = d;
        if (minDist < 1) break;
      }
      if (minDist <= kThresholdKm) {
        routeStations.add(
          _Station(
            name: s['name'] as String,
            address: '',
            position: LatLng(sLat, sLng),
          ),
        );
        await _drawStationDot(LatLng(sLat, sLng));
      }
    }

    if (mounted) setState(() => _stationList = routeStations);

    final allLats = routePoints.map((p) => p.latitude).toList();
    final allLngs = routePoints.map((p) => p.longitude).toList();
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            allLats.reduce(math.min) - 0.1,
            allLngs.reduce(math.min) - 0.1,
          ),
          northeast: LatLng(
            allLats.reduce(math.max) + 0.1,
            allLngs.reduce(math.max) + 0.1,
          ),
        ),
        left: 60,
        top: 60,
        right: 60,
        bottom: 60,
      ),
    );

    if (mounted) setState(() => _isRouting = false);
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isMobile = sw < 600;
    final isTablet = sw >= 600 && sw < 1024;
    final isDesktop = sw >= 1024;
    final isModern = context.isModernStyle;

    final activeGreen = context.isYellowTheme
        ? const Color(0xFFF59E0B)
        : const Color(0xFF16A34A);
    final activeAmber = const Color(0xFFF59E0B);
    final textDark = const Color(0xFF111827);

    if (!isModern) return _buildClassic(context, isMobile);

    final hPad = isMobile ? 20.0 : isTablet ? 40.0 : 80.0;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF9FAFB),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: hPad,
      ),
      child: Column(
        children: [
          Text(
            'CHARGING NETWORK',
            style: GoogleFonts.notoSans(
              color: activeGreen,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Powering Your Journey',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              fontSize: isMobile ? 28 : isTablet ? 38 : 48,
              fontWeight: FontWeight.w800,
              color: textDark,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: isMobile ? double.infinity : 600,
            child: Text(
              'Explore EV charging stations across South India — find the nearest charger or plan your route with stops along the way.',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                color: const Color(0xFF6B7280),
                fontSize: isMobile ? 13 : 16,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 40 : 60),

          Wrap(
            spacing: isMobile ? 12 : 20,
            runSpacing: isMobile ? 12 : 20,
            alignment: WrapAlignment.center,
            children: [
              _statCard('50+', 'Active Stations', FontAwesomeIcons.chargingStation, activeGreen, isMobile),
              _statCard('4', 'States Covered', FontAwesomeIcons.mapLocationDot, activeAmber, isMobile),
              _statCard('24/7', 'Availability', FontAwesomeIcons.clock, const Color(0xFF3B82F6), isMobile),
              _statCard('100%', 'Green Energy', FontAwesomeIcons.leaf, const Color(0xFF10B981), isMobile),
            ],
          ),
          SizedBox(height: isMobile ? 48 : 80),

          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildMap(isMobile, activeGreen)),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 4,
                      child: _buildControlPanel(context, isMobile, activeGreen, activeAmber),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildMap(isMobile, activeGreen),
                    const SizedBox(height: 32),
                    _buildControlPanel(context, isMobile, activeGreen, activeAmber),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildMap(bool isMobile, Color green) {
    return Container(
      height: isMobile ? 320 : 560,
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
            MapplsMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(10.8505, 76.2711),
                zoom: 6.5,
              ),
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoaded,
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.93),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _legendDot(const Color(0xFF1D4ED8)),
                    const SizedBox(width: 6),
                    Text('You', style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                    const SizedBox(width: 12),
                    _legendDot(const Color(0xFF16A34A)),
                    const SizedBox(width: 6),
                    Text('Station', style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                    if (_mode == _MapMode.route) ...[
                      const SizedBox(width: 12),
                      _legendDot(const Color(0xFF4F46E5), size: 10),
                      const SizedBox(width: 6),
                      Text('Route', style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton.small(
                onPressed: _isLocating ? null : () => _fetchUserLocation(centerMap: true),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1D4ED8),
                elevation: 4,
                child: _isLocating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const FaIcon(FontAwesomeIcons.crosshairs, size: 16),
              ),
            ),
            if (_isRouting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.18),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF4F46E5))),
                          const SizedBox(width: 14),
                          Text(
                            _mode == _MapMode.nearest ? 'Finding Stations...' : 'Planning Route...',
                            style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
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

  Widget _legendDot(Color color, {double size = 9}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _buildControlPanel(BuildContext context, bool isMobile, Color green, Color amber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          isActive: _mode == _MapMode.nearest,
          badgeColor: green,
          badgeLabel: 'Option 1',
          icon: FontAwesomeIcons.locationCrosshairs,
          iconColor: green,
          title: 'Find Nearest Stations',
          subtitle: 'Show the closest EV charging stations to your current location using Overpass API.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isLocating || _isRouting) ? null : _findNearestStations,
                  icon: (_isLocating || (_isRouting && _mode == _MapMode.nearest))
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const FaIcon(FontAwesomeIcons.boltLightning, size: 16),
                  label: Text('Find Nearest Charging', style: GoogleFonts.notoSans(fontWeight: FontWeight.w700, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: context.isYellowTheme ? Colors.black87 : Colors.white,
                    elevation: 3,
                    shadowColor: green.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              if (_mode == _MapMode.nearest && _stationList.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildStationList(green),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionCard(
          isActive: _mode == _MapMode.route,
          badgeColor: const Color(0xFF4F46E5),
          badgeLabel: 'Option 2',
          icon: FontAwesomeIcons.route,
          iconColor: const Color(0xFF4F46E5),
          title: 'Plan Route with Chargers',
          subtitle: 'Enter your journey and see the route with EV stations along the way powered by OSRM.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRouteInputField(
                controller: _fromCtrl,
                label: 'From',
                hint: 'e.g. Ernakulam',
                icon: FontAwesomeIcons.locationDot,
                iconColor: const Color(0xFF1D4ED8),
                isFrom: true,
              ),
              const SizedBox(height: 10),
              _buildRouteInputField(
                controller: _toCtrl,
                label: 'To',
                hint: 'e.g. Bangalore',
                icon: FontAwesomeIcons.flagCheckered,
                iconColor: const Color(0xFFDC2626),
                isFrom: false,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: (_isLocating || _isRouting) ? null : _planRoute,
                icon: _isRouting && _mode == _MapMode.route
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const FaIcon(FontAwesomeIcons.route, size: 16),
                label: Text('Show Route & Stations', style: GoogleFonts.notoSans(fontWeight: FontWeight.w700, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              if (_routeInfo.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.route, size: 14, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 8),
                      Text(_routeInfo, style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5))),
                    ],
                  ),
                ),
              ],
              if (_mode == _MapMode.route && _stationList.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildStationList(const Color(0xFF4F46E5)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              const FaIcon(FontAwesomeIcons.circleInfo, size: 15, color: Color(0xFF16A34A)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Route calculations use real-time traffic data via OSRM.',
                  style: GoogleFonts.notoSans(fontSize: 12, color: const Color(0xFF15803D), height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStationList(Color color) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _stationList.length,
        itemBuilder: (context, index) => _StationTile(station: _stationList[index]),
      ),
    );
  }

  Widget _buildRouteInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required bool isFrom,
  }) {
    final suggestions = isFrom ? _fromSuggestions : _toSuggestions;
    final showSuggestions = isFrom ? _showFromSuggestions : _showToSuggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
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
          style: GoogleFonts.notoSans(fontSize: 14, color: const Color(0xFF111827)),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: GoogleFonts.notoSans(fontSize: 13, color: const Color(0xFFD1D5DB)),
            labelStyle: GoogleFonts.notoSans(fontSize: 13, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500),
            prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: FaIcon(icon, size: 16, color: iconColor)),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
          ),
        ),
        if (showSuggestions && suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(suggestion.displayName, style: GoogleFonts.notoSans(fontSize: 13, color: const Color(0xFF374151))),
                  onTap: () {
                    setState(() {
                      controller.text = suggestion.displayName;
                      final ll = LatLng(suggestion.latLng!.latitude, suggestion.latLng!.longitude);
                      if (isFrom) {
                        _fromLatLng = ll;
                        _showFromSuggestions = false;
                      } else {
                        _toLatLng = ll;
                        _showToSuggestions = false;
                      }
                      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(ll, 12));
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          FaIcon(icon, color: color, size: isMobile ? 20 : 24),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.notoSans(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.w800, color: const Color(0xFF111827))),
          Text(label, style: GoogleFonts.notoSans(fontSize: isMobile ? 10 : 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildClassic(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: MediaQuery.of(context).size.width >= 1024 ? 80 : 20),
      child: Column(
        children: [
          Text('CHARGING NETWORK', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A), letterSpacing: 3)),
          const SizedBox(height: 20),
          const Text('Classic View Enabled'),
        ],
      ),
    );
  }
}

class _StationTile extends StatelessWidget {
  final _Station station;
  const _StationTile({required this.station});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBBF7D0))),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(station.name, style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (station.address.isNotEmpty)
                  Text(station.address, style: GoogleFonts.notoSans(fontSize: 10.5, color: const Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final bool isActive;
  final Color badgeColor;
  final String badgeLabel;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({required this.isActive, required this.badgeColor, required this.badgeLabel, required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isActive ? badgeColor.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.06), width: isActive ? 2 : 1),
        boxShadow: [BoxShadow(color: isActive ? badgeColor.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04), blurRadius: isActive ? 20 : 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(badgeLabel, style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor)),
              ),
              const Spacer(),
              FaIcon(icon, size: 18, color: iconColor),
            ],
          ),
          const SizedBox(height: 14),
          Text(title, style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
          const SizedBox(height: 6),
          Text(subtitle, style: GoogleFonts.notoSans(fontSize: 12.5, color: const Color(0xFF6B7280), height: 1.5)),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
