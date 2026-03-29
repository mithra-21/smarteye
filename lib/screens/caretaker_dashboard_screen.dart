// lib/screens/caretaker_dashboard_screen.dart
// CHANGES: replaced _dummyLocation with live Supabase realtime; _FullScreenMapPage also updated.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/colors.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart' as import_home;
import 'package:http/http.dart' as http;
import 'dart:convert';

class CaretakerDashboardScreen extends StatefulWidget {
  const CaretakerDashboardScreen({Key? key}) : super(key: key);

  @override
  _CaretakerDashboardScreenState createState() =>
      _CaretakerDashboardScreenState();
}

class _CaretakerDashboardScreenState extends State<CaretakerDashboardScreen> {
  int _currentIndex = 0;
  String _caretakerName = 'Loading...';

  // ── LOCATION STATE ──────────────────────────────────────────────────────────
  LatLng? _blindLocation;                           // null until first fix
  static const LatLng _fallback = LatLng(12.9716, 77.5946);
  RealtimeChannel? _channel;
  final _supabase = Supabase.instance.client;

  LatLng get _mapCenter => _blindLocation ?? _fallback;

  @override
  void initState() {
    super.initState();
    _fetchCaretakerName();
    _fetchInitialLocation();   // show last known position immediately
    _subscribeRealtime();      // then stream live updates
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  // ── Fetch caretaker name (existing team code — untouched) ───────────────────
  Future<void> _fetchCaretakerName() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      final data = await _supabase
          .from('caretakers')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();
      if (data != null && mounted) {
        setState(() => _caretakerName = data['full_name'] ?? 'Caretaker');
      }
    } catch (e) {
      print('Error fetching caretaker name: $e');
    }
  }

  // ── Fetch last stored location on screen open ────────────────────────────────
  Future<void> _fetchInitialLocation() async {
    try {
      final data = await _supabase
          .from('live_locations')
          .select()
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (data != null && mounted) _applyRow(data);
    } catch (e) {
      print('[Caretaker] initial fetch: $e');
    }
  }

  // ── Realtime subscription ───────────────────────────────────────────────────
  void _subscribeRealtime() {
    _channel = _supabase
        .channel('live_locations_ch')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'live_locations',
          callback: (payload) {
            if (payload.newRecord.isNotEmpty && mounted) {
              _applyRow(payload.newRecord);
            }
          },
        )
        .subscribe();
  }

  void _applyRow(Map<String, dynamic> row) {
    final lat = (row['latitude'] as num).toDouble();
    final lng = (row['longitude'] as num).toDouble();
    setState(() => _blindLocation = LatLng(lat, lng));
  }

  // ── Navigation / dialogs (unchanged) ────────────────────────────────────────
  void _onTabTapped(int i) => setState(() => _currentIndex = i);

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Emergency',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text(
            'This will send an immediate SOS alert to all emergency contacts and local authorities.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Emergency SOS Sent!'),
                  backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('SEND SOS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openFullScreenMap() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _FullScreenMapPage(location: _mapCenter),
    ));
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeView(),
              _buildSystemSettingsView(),
              _buildSettingsView(),
              _buildAlertsView(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ── HOME TAB ─────────────────────────────────────────────────────────────────
  Widget _buildHomeView() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white), onPressed: () {}),
          title: const Text('Smart Eye Care',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
                icon: const Icon(Icons.account_circle, color: Colors.white),
                onPressed: () => _onTabTapped(2)),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _openFullScreenMap,
                  child: GlassCard(
                    padding: const EdgeInsets.all(0),
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          _blindLocation != null
                              ? _StaticMapView(location: _blindLocation!)
                              : _WaitingMapPlaceholder(),
                          Positioned(
                            top: 16, left: 16,
                            child: _LiveTrackingBadge(active: _blindLocation != null),
                          ),
                          const Positioned(
                            bottom: 16, right: 16,
                            child: Icon(Icons.open_in_full, color: Colors.black54, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _StatusCard(hasLocation: _blindLocation != null),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _openFullScreenMap,
                        child: GlassCard(
                          height: 120,
                          padding: const EdgeInsets.all(16),
                          child: _ActionButtonContent(
                              icon: Icons.location_on, label: 'Track Location'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _showEmergencyDialog,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                              gradient: AppColors.buttonRedGradient,
                              borderRadius: BorderRadius.circular(24)),
                          child: _ActionButtonContent(
                              icon: Icons.notifications_active,
                              label: 'Emergency',
                              isPrimary: true),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _RecentActivityList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── SYSTEM TAB (unchanged) ───────────────────────────────────────────────────
  Widget _buildSystemSettingsView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device Status',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text("Blind person's device info",
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildDeviceInfoCard(icon: Icons.battery_3_bar_rounded, iconColor: Colors.green, title: 'Battery', value: '72%', subtitle: 'Charging · Est. 1h 20m to full', trailing: _buildBatteryIndicator(0.72)),
                const SizedBox(height: 12),
                _buildDeviceInfoCard(icon: Icons.wifi_rounded, iconColor: Colors.blue, title: 'Wi-Fi', value: 'Connected', subtitle: 'SmartEye_Home · Signal: Strong'),
                const SizedBox(height: 12),
                _buildDeviceInfoCard(icon: Icons.signal_cellular_alt_rounded, iconColor: Colors.orange, title: 'Mobile Data', value: '4G LTE', subtitle: 'Carrier: Jio · Signal: Good'),
                const SizedBox(height: 12),
                _buildDeviceInfoCard(icon: Icons.bluetooth_connected_rounded, iconColor: Colors.indigo, title: 'Bluetooth', value: 'Connected', subtitle: 'SmartEye Earpiece · Bone Conductor'),
                const SizedBox(height: 12),
                _buildDeviceInfoCard(icon: Icons.accessibility_new_rounded, iconColor: Colors.teal, title: 'Screen Reader', value: 'TalkBack ON', subtitle: 'Voice speed: Normal · Language: English'),
                const SizedBox(height: 12),
                _buildDeviceInfoCard(icon: Icons.volume_up_rounded, iconColor: Colors.purple, title: 'Volume', value: '85%', subtitle: 'Media volume · Haptic feedback: ON'),
                const SizedBox(height: 12),
                _buildDeviceInfoCard(icon: Icons.storage_rounded, iconColor: Colors.amber, title: 'Storage', value: '24.3 GB free', subtitle: '64 GB total · App data: 8.2 GB'),
                const SizedBox(height: 12),
                _buildDeviceInfoCard(icon: Icons.gps_fixed_rounded, iconColor: Colors.red, title: 'GPS', value: _blindLocation != null ? 'Active' : 'Waiting', subtitle: _blindLocation != null ? 'High accuracy mode · Live' : 'Waiting for blind user GPS...'),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard({required IconData icon, required Color iconColor, required String title, required String value, required String subtitle, Widget? trailing}) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white)),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(8)), child: Text(value, style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildBatteryIndicator(double level) {
    return Container(
      width: 40, height: 20,
      decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 1.5), borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: level,
          child: Container(decoration: BoxDecoration(color: level > 0.3 ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(2))),
        ),
      ),
    );
  }

  // ── ALERTS TAB (unchanged) ───────────────────────────────────────────────────
  Widget _buildAlertsView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Safety Alerts', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildAlertItem('Unusual Route', 'Deviation detected near 5th cross', 'Just now', Colors.orange),
                _buildAlertItem('Battery Low', 'Visually Impaired device at 15%', '10 mins ago', Colors.red),
                _buildAlertItem('Home Safe', 'Arrived at registered home location', '1 hour ago', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String subtitle, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
            ])),
            Text(time, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ── SETTINGS TAB (unchanged except dynamic name already was there) ───────────
  Widget _buildSettingsView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 50, color: Colors.white)),
          const SizedBox(height: 16),
          Text(_caretakerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 32),
          _buildSettingsItem(Icons.person_outline, 'Profile Settings', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile editing coming soon!')))),
          _buildSettingsItem(Icons.notifications_none, 'Notification Prefs', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings coming soon!')))),
          _buildSettingsItem(Icons.security, 'Emergency Contacts', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contacts management coming soon!')))),
          _buildSettingsItem(Icons.logout, 'Logout', isDestructive: true,
              onTap: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const import_home.HomeScreen()), (r) => false)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {bool isDestructive = false, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: isDestructive ? Colors.redAccent[100] : Colors.white),
              const SizedBox(width: 16),
              Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent[100] : Colors.white, fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_rounded, 'Home', 0),
          _buildNavItem(Icons.phonelink_setup_rounded, 'System', 1),
          _buildNavItem(Icons.settings_rounded, 'Settings', 2),
          _buildNavItem(Icons.notifications_rounded, 'Alerts', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppColors.backgroundTop : Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.backgroundTop : Colors.grey)),
        ],
      ),
    );
  }
}

// ── FULL SCREEN MAP PAGE ──────────────────────────────────────────────────────
// Now accepts live location instead of dummy

class _FullScreenMapPage extends StatefulWidget {
  final LatLng location;
  const _FullScreenMapPage({Key? key, required this.location}) : super(key: key);

  @override
  State<_FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<_FullScreenMapPage> {
  late final MapController _mapController;
  late final TextEditingController _searchController;
  bool _isSearching = false;

  // Live location updates while full map is open
  LatLng _currentLocation = const LatLng(0, 0);
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
    _currentLocation = widget.location;
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client
        .channel('fullmap_location_ch')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'live_locations',
          callback: (payload) {
            final row = payload.newRecord;
            if (row.isNotEmpty && mounted) {
              final lat = (row['latitude'] as num).toDouble();
              final lng = (row['longitude'] as num).toDouble();
              final newLoc = LatLng(lat, lng);
              setState(() => _currentLocation = newLoc);
              try { _mapController.move(newLoc, _mapController.camera.zoom); } catch (_) {}
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _recenterMap() {
    _mapController.move(_currentLocation, 14.0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Re-centered to live location'), duration: Duration(seconds: 1)),
    );
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1'),
        headers: {'User-Agent': 'SmartEye_BTech_Project', 'Accept-Language': 'en'},
      );
      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        if (results.isNotEmpty) {
          _mapController.move(LatLng(double.parse(results[0]['lat']), double.parse(results[0]['lon'])), 14.0);
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Found: ${results[0]['display_name'].split(',')[0]}'), duration: const Duration(seconds: 2)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not found.')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: No internet connection.')));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _currentLocation, initialZoom: 14.0),
            children: [
              TileLayer(urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.newapp'),
              MarkerLayer(markers: [
                Marker(point: _currentLocation, width: 60, height: 60, child: const _PulsingMarker()),
              ]),
            ],
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.of(context).pop()),
            ),
          ),
          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 72, right: 20,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      enabled: !_isSearching,
                      onSubmitted: _searchLocation,
                      style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: _isSearching ? 'Searching...' : 'Search location...',
                        hintStyle: TextStyle(color: AppColors.textDark.withOpacity(0.5)),
                        border: InputBorder.none, isDense: true,
                      ),
                    ),
                  ),
                  if (_isSearching)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.backgroundTop))
                  else
                    IconButton(icon: const Icon(Icons.gps_fixed, color: AppColors.backgroundTop), onPressed: _recenterMap),
                ],
              ),
            ),
          ),
          // Zoom controls
          Positioned(
            bottom: 40, right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(heroTag: 'map_zoom_in', onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1), backgroundColor: Colors.white, child: const Icon(Icons.add, color: AppColors.backgroundTop)),
                const SizedBox(height: 8),
                FloatingActionButton.small(heroTag: 'map_zoom_out', onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1), backgroundColor: Colors.white, child: const Icon(Icons.remove, color: AppColors.backgroundTop)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── UNCHANGED SUB-WIDGETS ─────────────────────────────────────────────────────

class _WaitingMapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(height: 8),
          Text('Waiting for GPS...', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      ),
    );
  }
}

class _StaticMapView extends StatelessWidget {
  final LatLng location;
  const _StaticMapView({required this.location});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(initialCenter: location, initialZoom: 13.0, interactionOptions: const InteractionOptions(flags: 0)),
      children: [
        TileLayer(urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.newapp'),
        MarkerLayer(markers: [Marker(point: location, width: 40, height: 40, child: const _PulsingMarker())]),
      ],
    );
  }
}

class _ActionButtonContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  const _ActionButtonContent({required this.icon, required this.label, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool hasLocation;
  const _StatusCard({required this.hasLocation});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(hasLocation ? Icons.gps_fixed : Icons.gps_off, color: hasLocation ? Colors.greenAccent : Colors.orangeAccent, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CURRENT STATUS', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                hasLocation ? 'Live Location Active' : 'Awaiting GPS...',
                style: TextStyle(color: hasLocation ? Colors.greenAccent : Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveTrackingBadge extends StatelessWidget {
  final bool active;
  const _LiveTrackingBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: active ? Colors.green : Colors.orange, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(active ? 'LIVE TRACKING' : 'CONNECTING...', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(children: [Icon(Icons.history, color: AppColors.textDark, size: 20), SizedBox(width: 8), Text('Recent Activity', style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        _buildActivityItem(Icons.home, 'Arrived at Home', '10:45 AM'),
        const SizedBox(height: 12),
        _buildActivityItem(Icons.directions_walk, 'Walking on 5th Ave', '10:20 AM'),
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String label, String time) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.textDark)),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 15))),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _PulsingMarker extends StatefulWidget {
  const _PulsingMarker({Key? key}) : super(key: key);

  @override
  State<_PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<_PulsingMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.red.withOpacity(1 - _animation.value), width: 2))),
          Container(width: 14, height: 14, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))])),
        ],
      ),
    );
  }
}