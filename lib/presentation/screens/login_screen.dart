import 'package:flutter/material.dart';
import 'package:ha_mobile/presentation/widgets/wave_panel.dart';
import '../../core/theme/brand_colors.dart';
import '../../core/session.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/auth_storage.dart';
import '../widgets/button_long.dart';
import '../screens/root_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authResponse = await AuthService.instance.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Save auth data to storage
      await AuthStorage.saveAuth(
        token: authResponse.token,
        user: authResponse.user,
      );

      // Set authenticated user in session
      setAuthenticatedUser(authResponse.user);

      if (mounted) {
        // Navigate to home screen (RootShell)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RootShell()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Stack(
              children: [
                // Layer 1: Gradient background (furthest back)
                Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        kHAPrimary, // #1F2555 at top
                        Color(0xFF4451BB), // #4451BB at bottom
                        Color(0xFF4451BB), // #4451BB at bottom
                      ],
                      stops: [
                        0.0, // Start with dark blue
                        0.25, // Keep dark blue until 2/3 of the way down
                        1.0, // Transition to lighter blue at bottom
                      ],
                    ),
                  ),
                ),

                // Layer 2: Dark wave panel (horizontally offset)
                Positioned(
                  top: 0,
                  left: MediaQuery.of(context).size.width * -0.15,
                  right: 20,
                  child: WavePanel(
                    height: MediaQuery.of(context).size.height,
                    borderRadius: 0,
                    heightFactor: 0.25,
                    amplitude: 40,
                    color: const Color(0xFF1B316F),
                    paintBottom: true,
                  ),
                ),

                // Layer 3: White panel (extends to bottom of screen)
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        child: WavePanel(
                          height: MediaQuery.of(context).size.height,
                          borderRadius: 0,
                          heightFactor:
                              0.25, // Wave at 25% of full height = ~320px
                          amplitude: 40,
                          color: Colors.white,
                          paintBottom: true,
                        ),
                      ),
                    ],
                  ),
                ),

                // Layer 4a: Logo - Fixed position at top
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      'assets/logos/HA_Logo_White_Transparent_Vertical.png',
                      height: 120,
                    ),
                  ),
                ),

                // Layer 4b: Form content - Centered
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Welcome Back heading
                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Login to access your account',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'example@email.com',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: '••••••••••••••',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Error Message
                              if (_errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Login Button
                              ButtonLong(
                                label: _isLoading ? 'Logging in...' : 'Login',
                                onPressed: _isLoading ? null : _handleLogin,
                                style: FilledButton.styleFrom(
                                  backgroundColor: kHAPrimary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: kHAPrimary
                                      .withOpacity(0.6),
                                  disabledForegroundColor: Colors.white
                                      .withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Footer text
                              Text(
                                'Need an account? Contact High Aspirations to get set up today',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
