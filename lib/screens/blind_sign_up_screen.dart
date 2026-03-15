import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/colors.dart';
import 'blind_dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BlindSignUpScreen extends StatefulWidget {
  const BlindSignUpScreen({Key? key}) : super(key: key);

  @override
  State<BlindSignUpScreen> createState() => _BlindSignUpScreenState();
}

class _BlindSignUpScreenState extends State<BlindSignUpScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _blindNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _bloodGroupController.dispose();
    _blindNameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': response.user!.id,
          'full_name': _fullNameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'blood_group': _bloodGroupController.text.trim(),
          'role': 'blind',
        });

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BlindDashboardScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Upload Photo Section
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
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
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Upload Photo",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Smart Eye Profile Setup",
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Form Sections
            _buildSection(
              icon: Icons.person,
              title: "Blind User Details",
              children: [
                _buildLabel("Blind name (Username)"),
                _buildTextField("Enter blind-name", controller: _blindNameController),
                const SizedBox(height: 16),
                _buildLabel("Full Name"),
                _buildTextField("Enter full name", controller: _fullNameController),
                const SizedBox(height: 16),
                _buildLabel("Email"),
                _buildTextField("Enter email", controller: _emailController),
                const SizedBox(height: 16),
                _buildLabel("Password"),
                _buildTextField("Enter password", controller: _passwordController, obscureText: true),
              ],
            ),
            const SizedBox(height: 20),

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
                _buildTextField("mm/dd/yyyy", suffixIcon: Icons.calendar_today),
                const SizedBox(height: 16),
                _buildLabel("Disease/Condition"),
                _buildTextField("Glaucoma, Cataract, etc."),
              ],
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.location_on,
              title: "Address Information",
              children: [
                _buildLabel("Address Line 1"),
                _buildTextField("Street, apartment, floor"),
                const SizedBox(height: 16),
                _buildLabel("Address Line 2 (Optional)"),
                _buildTextField("Area, city, landmark"),
              ],
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.supervised_user_circle,
              title: "Caretaker Details",
              children: [
                _buildLabel("Caretaker Name"),
                _buildTextField("Enter caretaker's full name"),
                const SizedBox(height: 16),
                _buildLabel("Caretaker Email (Gmail)"),
                _buildTextField("example@gmail.com"),
                const SizedBox(height: 16),
                _buildLabel("Caretaker Phone Number"),
                _buildTextField("+1 (555) 000-0000"),
              ],
            ),
            const SizedBox(height: 40),

            // Action Buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4081),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoading ? "Creating..." : "Create Account",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward),
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
    );
  }

  Widget _buildSection({required IconData icon, required String title, required List<Widget> children}) {
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

  Widget _buildTextField(String hint, {IconData? suffixIcon, TextEditingController? controller, bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.white24) : null,
        ),
      ),
    );
  }
}
