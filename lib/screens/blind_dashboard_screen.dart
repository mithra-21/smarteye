// lib/screens/blind_dashboard_screen.dart
// CHANGE: StatelessWidget → StatefulWidget, added GPS tracking

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colors.dart';
import '../services/location_service.dart';
import 'blind_voice_message_screen.dart';
import 'home_screen.dart';

class BlindDashboardScreen extends StatefulWidget {          // ← was StatelessWidget
  const BlindDashboardScreen({Key? key}) : super(key: key);

  @override
  State<BlindDashboardScreen> createState() => _BlindDashboardScreenState();
}

class _BlindDashboardScreenState extends State<BlindDashboardScreen> {
  final _locationService = LocationService();
  bool _tracking = false;

  @override
  void initState() {
    super.initState();
    _startGps();
  }

  @override
  void dispose() {
    _locationService.stopTracking();
    super.dispose();
  }

  Future<void> _startGps() async {
    try {
      await _locationService.startTracking();
      if (mounted) setState(() => _tracking = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130C14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "BLIND USER HUB",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        actions: [
          // GPS status dot
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: _tracking ? Colors.greenAccent : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _tracking ? 'GPS ON' : 'GPS...',
                  style: TextStyle(
                    color: _tracking ? Colors.greenAccent : Colors.orange,
                    fontSize: 11, fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildMainButton(
              title: "PRIMARY SUPPORT",
              label: "CALL CARETAKER",
              icon: Icons.headset_mic,
              color: const Color(0xFF3B1F2B),
              onTap: () => _makePhoneCall('9876543210'), // replace with real number
            ),
            const SizedBox(height: 20),
            _buildMainButton(
              title: "NON-URGENT",
              label: "SEND MESSAGE",
              icon: Icons.chat_bubble,
              color: const Color(0xFFD386A8),
              textColor: Colors.black,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlindVoiceMessageScreen()),
              ),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "EMERGENCY SERVICES",
                style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 16),
            _buildEmergencyButton("CALL AMBULANCE", Icons.medical_services, "108"),
            const SizedBox(height: 12),
            _buildEmergencyButton("CALL POLICE", Icons.shield, "100"),
            const SizedBox(height: 12),
            _buildEmergencyButton("CALL FIREFORCE", Icons.fire_truck, "101"),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                _locationService.stopTracking();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, color: Colors.white54, size: 24),
                    SizedBox(width: 12),
                    Text("SIGN OUT", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required String title, required String label,
    required IconData icon, required Color color,
    Color textColor = Colors.white, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, color: textColor, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  Text(label, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(String label, IconData icon, String number) {
    return Container(
      width: double.infinity, height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _makePhoneCall(number),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}