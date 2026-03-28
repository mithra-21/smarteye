import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/sliding_tab.dart';
import '../widgets/animated_avatar.dart';
import 'caretaker_dashboard_screen.dart';

class CaretakerLoginScreen extends StatefulWidget {
  const CaretakerLoginScreen({Key? key}) : super(key: key);

  @override
  _CaretakerLoginScreenState createState() => _CaretakerLoginScreenState();
}

class _CaretakerLoginScreenState extends State<CaretakerLoginScreen> {
  int _currentTabIndex = 0;
  bool _isLoading = false;

  // Sign Up controllers
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _blindIdController = TextEditingController();

  // Sign In controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/caretaker_avatar.png'), context);
  }

  @override
  void dispose() {
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _blindIdController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    super.dispose();
  }

  // ── Sign Up ──
  Future<void> _signUp() async {
    // Basic validation
    if (_signUpEmailController.text.trim().isEmpty ||
        _signUpPasswordController.text.trim().isEmpty ||
        _blindIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Validate BlindID exists in blind_users
      final blindUser = await Supabase.instance.client
          .from('blind_users')
          .select()
          .eq('unique_id', _blindIdController.text.trim())
          .maybeSingle();

      if (blindUser == null) {
        throw Exception('Invalid BlindID — no blind user found');
      }

      // 2. Create auth account
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text.trim(),
      );

      final userId = authResponse.user?.id;
      if (userId == null) throw Exception('Signup failed');

      // 3. Update caretaker row with auth id
      final updateResult = await Supabase.instance.client
          .from('caretakers')
          .update({'id': userId})
          .eq('blind_user_id', _blindIdController.text.trim())
          .select();

      print('BlindID entered: ${_blindIdController.text.trim()}');
      print('userId: $userId');
      print('Update result: $updateResult');

      // 4. Navigate to dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CaretakerDashboardScreen()),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Sign In ──
  Future<void> _signIn() async {
    // Basic validation
    if (_signInEmailController.text.trim().isEmpty ||
        _signInPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Sign in with email + password
      await Supabase.instance.client.auth.signInWithPassword(
        email: _signInEmailController.text.trim(),
        password: _signInPasswordController.text.trim(),
      );

      // 2. Check caretaker exists
      final user = Supabase.instance.client.auth.currentUser;
      final caretaker = await Supabase.instance.client
          .from('caretakers')
          .select()
          .eq('id', user!.id)
          .maybeSingle();

      if (caretaker == null) throw Exception('No caretaker account found');

      // 3. Navigate to dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CaretakerDashboardScreen()),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.caretakerBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const RepaintBoundary(child: AnimatedAvatar()),
                  const SizedBox(height: 30),

                  RepaintBoundary(
                    child: GlassCard(
                      padding: const EdgeInsets.all(24.0),
                      opacity: 0.1,
                      blur: 10.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Caretaker',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Professional healthcare management',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tab switcher
                          SlidingTabController(
                            onTabChanged: (index) {
                              setState(() => _currentTabIndex = index);
                            },
                          ),
                          const SizedBox(height: 32),

                          // ── Sign Up Tab ──
                          if (_currentTabIndex == 0) ...[
                            CustomTextField(
                              labelText: 'Email Address',
                              hintText: 'Enter your email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              controller: _signUpEmailController,
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              controller: _signUpPasswordController,
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              labelText: 'BlindID',
                              hintText: 'Enter BlindID from email',
                              prefixIcon: Icons.person_search,
                              controller: _blindIdController,
                            ),
                            const SizedBox(height: 32),
                            GradientButton(
                              text: 'Sign Up',
                              suffixIcon: Icons.check,
                              onPressed: _isLoading ? null : () => _signUp(),
                            ),

                          // ── Sign In Tab ──
                          ] else ...[
                            CustomTextField(
                              labelText: 'Email Address',
                              hintText: 'Enter your email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              controller: _signInEmailController,
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              controller: _signInPasswordController,
                            ),
                            const SizedBox(height: 32),
                            GradientButton(
                              text: 'Sign In',
                              suffixIcon: Icons.arrow_forward,
                              onPressed: _isLoading ? null : () => _signIn(),
                            ),
                          ],

                          // Loading indicator
                          if (_isLoading) ...[
                            const SizedBox(height: 16),
                            const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
