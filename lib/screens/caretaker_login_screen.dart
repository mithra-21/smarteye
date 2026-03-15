import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/sliding_tab.dart';
import '../widgets/animated_avatar.dart';
import 'caretaker_dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CaretakerLoginScreen extends StatefulWidget {
  const CaretakerLoginScreen({Key? key}) : super(key: key);

  @override
  _CaretakerLoginScreenState createState() => _CaretakerLoginScreenState();
}

class _CaretakerLoginScreenState extends State<CaretakerLoginScreen> {
  int _currentTabIndex = 0; // 0 for Sign Up, 1 for Sign In

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _blindIdController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _blindIdController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      if (_currentTabIndex == 0) {
        // Sign Up
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response.user != null) {
          await Supabase.instance.client.from('profiles').insert({
            'id': response.user!.id,
            'role': 'caretaker',
            'email': _emailController.text.trim(),
            // 'blind_id': _blindIdController.text.trim(), // Optional: if you have a blind_id column
          });

          if (!mounted) return;
          _navigateToDashboard();
        }
      } else {
        // Sign In
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response.session != null) {
          if (!mounted) return;
          _navigateToDashboard();
        }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache the avatar image to avoid jank during first load
    precacheImage(const AssetImage('assets/images/caretaker_avatar.png'), context);
  }

  void _navigateToDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CaretakerDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.caretakerBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Animated Floating Avatar - Isolated Repaint
                  const RepaintBoundary(
                    child: AnimatedAvatar(),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Main Form Card - Isolated Repaint
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
                            'Pofessional healthcare management',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Sliding Tab
                          SlidingTabController(
                            onTabChanged: (index) {
                              setState(() {
                                _currentTabIndex = index;
                              });
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Dynamic Form Fields
                          if (_currentTabIndex == 0) ...[
                             // Sign Up Fields
                             CustomTextField(
                              labelText: 'Email Address',
                              hintText: 'Enter your email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                            ),
                            CustomTextField(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              controller: _passwordController,
                            ),
                            CustomTextField(
                              labelText: 'BlindID',
                              hintText: 'Enter BlindID',
                              prefixIcon: Icons.person_search,
                              controller: _blindIdController,
                            ),
                            const SizedBox(height: 32),
                            GradientButton(
                              text: _isLoading ? 'Signing Up...' : 'Sign Up',
                              suffixIcon: Icons.check,
                              onPressed: _isLoading ? () {} : _handleAuth,
                            ),
                          ] else ...[
                            // Sign In Fields
                            CustomTextField(
                              labelText: 'Email Address',
                              hintText: 'Enter your email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                            ),
                            CustomTextField(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              controller: _passwordController,
                            ),
                            const SizedBox(height: 32),
                            GradientButton(
                              text: _isLoading ? 'Signing In...' : 'Sign In',
                              suffixIcon: Icons.arrow_forward,
                              onPressed: _isLoading ? () {} : _handleAuth,
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
