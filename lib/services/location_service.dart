// lib/services/location_service.dart
// NEW FILE — create this at lib/services/location_service.dart

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _sub;

  /// Call from initState of BlindDashboardScreen.
  Future<void> startTracking() async {
    // 1. Permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }

    // 2. GPS enabled?
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Please enable GPS.');
    }

    await stopTracking(); // cancel any previous stream

    // 3. Stream: fires only when user moves ≥ 10 m (battery-friendly)
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      _upload,
      onError: (e) => print('[GPS] error: $e'),
    );
  }

  Future<void> stopTracking() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _upload(Position pos) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await Supabase.instance.client.from('live_locations').upsert({
        'blind_user_id': uid,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'blind_user_id');
    } catch (e) {
      print('[GPS] upload error: $e');
    }
  }
}