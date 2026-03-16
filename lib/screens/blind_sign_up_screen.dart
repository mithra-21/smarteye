import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'blind_dashboard_screen.dart';
import '../services/auth_service.dart';

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
  final _dobController = TextEditingController();
  final _diseaseController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _caretakerNameController = TextEditingController();
  final _caretakerEmailController = TextEditingController();
  final _caretakerPhoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _bloodGroupController.dispose();
    _blindNameController.dispose();
    _dobController.dispose();
    _diseaseController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _caretakerNameController.dispose();
    _caretakerEmailController.dispose();
    _caretakerPhoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    // Basic validation
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _caretakerEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields including Caretaker Email.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final blindId = await authService.signUpBlindUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        bloodGroup: _bloodGroupController.text.trim(),
        caretakerEmail: _caretakerEmailController.text.trim(),
        blindName: _blindNameController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        diseaseCondition: _diseaseController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        caretakerName: _caretakerNameController.text.trim(),
        caretakerPhone: _caretakerPhoneController.text.trim(),
      );

      if (!mounted) return;

      // Show success dialog before navigating
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF2C1B28),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFFFF4081), size: 28),
              SizedBox(width: 10),
              Text('Account Created!', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Unique Blind ID has been emailed to your caretaker:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                _caretakerEmailController.text.trim(),
                style: const TextStyle(color: Color(0xFFFF4081), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Your Blind ID (for reference):', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  blindId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4081),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BlindDashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
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
                _buildTextField("mm/dd/yyyy", suffixIcon: Icons.calendar_today, controller: _dobController),
                const SizedBox(height: 16),
                _buildLabel("Disease/Condition"),
                _buildTextField("Glaucoma, Cataract, etc.", controller: _diseaseController),
              ],
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.location_on,
              title: "Address Information",
              children: [
                _buildLabel("Address Line 1"),
                _buildTextField("Street, apartment, floor", controller: _addressLine1Controller),
                const SizedBox(height: 16),
                _buildLabel("Address Line 2 (Optional)"),
                _buildTextField("Area, city, landmark", controller: _addressLine2Controller),
              ],
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.supervised_user_circle,
              title: "Caretaker Details",
              children: [
                _buildLabel("Caretaker Name"),
                _buildTextField("Enter caretaker's full name", controller: _caretakerNameController),
                const SizedBox(height: 16),
                _buildLabel("Caretaker Email (Gmail) ★"),
                _buildTextField(
                  "example@gmail.com",
                  controller: _caretakerEmailController,
                ),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Text(
                    '★ The Unique Blind ID will be emailed here.',
                    style: TextStyle(color: Color(0xFFFF4081), fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabel("Caretaker Phone Number"),
                _buildTextField("+1 (555) 000-0000", controller: _caretakerPhoneController),
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
