import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  final LatLng _dummyLocation = const LatLng(12.9716, 77.5946); // Bangalore
  late final MapController _mapController;
  late final TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _recenterMap() {
    _mapController.move(_dummyLocation, 14.0);
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
        headers: {
          'User-Agent': 'SmartEye_BTech_Project',
          'Accept-Language': 'en',
        },
      );

      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        if (results.isNotEmpty) {
          final lat = double.parse(results[0]['lat']);
          final lon = double.parse(results[0]['lon']);
          final LatLng target = LatLng(lat, lon);

          _mapController.move(target, 14.0);
          
          // Professional touch: dismiss keyboard
          FocusScope.of(context).unfocus();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found: ${results[0]['display_name'].split(',')[0]}'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found. Try a more specific name.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search service unavailable. Please try later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No internet connection.')),
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Emergency', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('This will send an immediate SOS alert to all emergency contacts and local authorities.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency SOS Sent!'), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('SEND SOS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeView(),
              _buildExplorerView(),
              _buildAlertsView(),
              _buildSettingsView(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeView() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
          title: const Text('Smart Eye Care', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () => _onTabTapped(3),
            ),
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
                  onTap: () => _onTabTapped(1),
                  child: GlassCard(
                    padding: const EdgeInsets.all(0),
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          _StaticMapView(location: _dummyLocation),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: _LiveTrackingBadge(),
                          ),
                          const Positioned(
                            bottom: 16,
                            right: 16,
                            child: Icon(Icons.open_in_full, color: Colors.black54, size: 20),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _StatusCard(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabTapped(1),
                        child: GlassCard(
                          height: 120,
                          padding: const EdgeInsets.all(16),
                          child: _ActionButtonContent(icon: Icons.location_on, label: 'Track Location'),
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
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: _ActionButtonContent(icon: Icons.notifications_active, label: 'Emergency', isPrimary: true),
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

  Widget _buildExplorerView() {
  return Stack(
    children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _dummyLocation,
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.newapp',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _dummyLocation,
                width: 60,
                height: 60,
                child: const _PulsingMarker(),
              ),
            ],
          ),
        ],
      ),

      // ✅ Search bar (add this back)
      Positioned(
        top: 20,
        left: 20,
        right: 20,
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
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_isSearching)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.backgroundTop),
                )
              else
                IconButton(
                  icon: const Icon(Icons.gps_fixed, color: AppColors.backgroundTop),
                  onPressed: _recenterMap,
                ),
            ],
          ),
        ),
      ),


      // Zoom Controls
      Positioned(
        bottom: 150, // Space for bottom nav
        right: 16,
        child: Column(
          children: [
            FloatingActionButton.small(
              heroTag: 'zoom_in',
              onPressed: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom + 1,
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: AppColors.backgroundTop),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'zoom_out',
              onPressed: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom - 1,
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.remove, color: AppColors.backgroundTop),
            ),
          ],
        ),
      ),
    ],
  );
}

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textDark, fontSize: 13)),
                ],
              ),
            ),
            Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 50, color: Colors.white)),
          const SizedBox(height: 16),
          const Text('Caretaker Name', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 32),
          _buildSettingsItem(Icons.person_outline, 'Profile Settings', onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile editing coming soon!')));
          }),
          _buildSettingsItem(Icons.notifications_none, 'Notification Prefs', onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings coming soon!')));
          }),
          _buildSettingsItem(Icons.security, 'Emergency Contacts', onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contacts management coming soon!')));
          }),
          _buildSettingsItem(
            Icons.logout, 
            'Logout', 
            isDestructive: true,
            onTap: () {
              // Proper logout: clear navigation stack and return home
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const import_home.HomeScreen()), // Use alias to avoid confusion if needed
                (route) => false,
              );
            },
          ),
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
              Icon(icon, color: isDestructive ? Colors.red : AppColors.textDark),
              const SizedBox(width: 16),
              Text(title, style: TextStyle(color: isDestructive ? Colors.red : AppColors.textDark, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_rounded, 'Home', 0),
          _buildNavItem(Icons.map_rounded, 'Explorer', 1),
          _buildNavItem(Icons.notifications_rounded, 'Alerts', 2),
          _buildNavItem(Icons.settings_rounded, 'Settings', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.security, color: Colors.white, size: 30)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CURRENT STATUS', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Safe & Stationary', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveTrackingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('LIVE TRACKING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.red.withOpacity(1 - _animation.value), width: 2))),
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]),
            ),
          ],
        );
      },
    );
  }
}
