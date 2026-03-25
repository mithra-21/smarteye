import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/colors.dart';
import 'blind_dashboard_screen.dart';

class BlindSignUpScreen extends StatefulWidget {
  const BlindSignUpScreen({Key? key}) : super(key: key);

  @override
  State<BlindSignUpScreen> createState() => _BlindSignUpScreenState();
}

class _BlindSignUpScreenState extends State<BlindSignUpScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _autoRotate = true;
  bool _isLoading = false;

  // Text controllers for all form fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _diseaseController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _caretakerNameController = TextEditingController();
  final _caretakerEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _caretakerPhoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _bloodGroupController.dispose();
    _ageController.dispose();
    _birthdateController.dispose();
    _diseaseController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _caretakerNameController.dispose();
    _caretakerEmailController.dispose();
    _caretakerPhoneController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    try {
      // 1. Create auth account
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userId = authResponse.user?.id;
      if (userId == null) throw Exception('Signup failed');

      // 2. Upload photo
      String? photoUrl;
      if (_imageFile != null) {
        final fileName = 'blind_$userId.jpg';
        await Supabase.instance.client.storage
            .from('user-photos')
            .upload(fileName, File(_imageFile!.path));
        photoUrl = Supabase.instance.client.storage
            .from('user-photos')
            .getPublicUrl(fileName);
      }

      // 3. Save blind user
      final response = await Supabase.instance.client
          .from('blind_users')
          .insert({
            'id': userId,
            'username': _usernameController.text.trim(),
            'full_name': _fullNameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(), // ← FIXED
            'photo_url': photoUrl,
            'blood_group': _bloodGroupController.text.trim(),
            'age': int.tryParse(_ageController.text.trim()),
            'birthdate': _birthdateController.text.trim(),
            'disease_condition': _diseaseController.text.trim(),
            'address_line1': _address1Controller.text.trim(),
            'address_line2': _address2Controller.text.trim(),
          })
          .select()
          .single();

      final uniqueId = response['unique_id'];
      print('Blind user created! Unique ID: $uniqueId');

      // 4. Save caretaker ← NEW
      await Supabase.instance.client
          .from('caretakers')
          .insert({
            'full_name': _caretakerNameController.text.trim(),
            'email': _caretakerEmailController.text.trim(),
            'phone': _caretakerPhoneController.text.trim(),
            'blind_user_id': uniqueId,
          });

      print('Caretaker saved!');

      // 5. Navigate to dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BlindDashboardScreen()),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── Galaxy 3D Model ──
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  // Galaxy viewer fills the top
                  ModelViewer(
                    src: 'assets/images/need_some_space.glb',
                    autoRotate: _autoRotate,
                    rotationPerSecond: '20deg',
                    cameraControls: true,
                    backgroundColor: const Color(0xFF1A111A),
                    shadowIntensity: 0,
                  ),

                  // Title overlay at bottom of galaxy
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF1A111A),
                          ],
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            "Smart Eye",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            "Profile Setup",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Rest of the form ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  // Photo upload circle
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: _imageFile == null
                                  ? RadialGradient(
                                      colors: [
                                        const Color(0xFFE91E63).withOpacity(0.8),
                                        const Color(0xFF880E4F),
                                      ],
                                    )
                                  : null,
                              image: _imageFile != null
                                  ? DecorationImage(
                                      image: FileImage(File(_imageFile!.path)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE91E63).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: _imageFile == null
                                ? const Icon(Icons.camera_alt,
                                    size: 36, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Upload Your Photo",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ── Blind User Details ──
                  _buildSection(
                    icon: Icons.person,
                    title: "Blind User Details",
                    children: [
                      _buildLabel("Email"),
                      _buildTextField("example@gmail.com", controller: _emailController),
                      const SizedBox(height: 16),
                      _buildLabel("Password"),
                      _buildTextField("Create a password", controller: _passwordController, isPassword: true),
                      const SizedBox(height: 16),
                      _buildLabel("Blind name (Username)"),
                      _buildTextField("Enter blind-name", controller: _usernameController),
                      const SizedBox(height: 16),
                      _buildLabel("Full Name"),
                      _buildTextField("Enter full name", controller: _fullNameController),
                      const SizedBox(height: 16),
                      _buildLabel("Phone Number"),
                      _buildTextField("+91 9999999999", controller: _phoneController),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Medical Details ──
                  _buildSection(
                    icon: Icons.medical_services,
                    title: "Medical Details",
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Blood Group"),
                                _buildTextField("O+, AB-", controller: _bloodGroupController),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Age"),
                                _buildTextField("25", controller: _ageController),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLabel("Birthdate"),
                      _buildTextField("mm/dd/yyyy",
                          suffixIcon: Icons.calendar_today, controller: _birthdateController),
                      const SizedBox(height: 16),
                      _buildLabel("Disease/Condition"),
                      _buildTextField("Glaucoma, Cataract, etc.", controller: _diseaseController),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Address Information ──
                  _buildSection(
                    icon: Icons.location_on,
                    title: "Address Information",
                    children: [
                      _buildLabel("Address Line 1"),
                      _buildTextField("Street, apartment, floor", controller: _address1Controller),
                      const SizedBox(height: 16),
                      _buildLabel("Address Line 2 (Optional)"),
                      _buildTextField("Area, city, landmark", controller: _address2Controller),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Caretaker Details ──
                  _buildSection(
                    icon: Icons.supervised_user_circle,
                    title: "Caretaker Details",
                    children: [
                      _buildLabel("Caretaker Name"),
                      _buildTextField("Enter caretaker's full name", controller: _caretakerNameController),
                      const SizedBox(height: 16),
                      _buildLabel("Caretaker Email (Gmail)"),
                      _buildTextField("example@gmail.com", controller: _caretakerEmailController),
                      const SizedBox(height: 16),
                      _buildLabel("Caretaker Phone Number"),
                      _buildTextField("+1 (555) 000-0000", controller: _caretakerPhoneController),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // ── Create Account Button ──
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4081),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Create Account",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Cancel & Go Back",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1B28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF4081), size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {
    IconData? suffixIcon,
    TextEditingController? controller,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.white24)
              : null,
        ),
      ),
    );
  }
}
