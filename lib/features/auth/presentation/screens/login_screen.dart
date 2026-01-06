// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    // Remove any non-digit characters
    String digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Add India country code if not present
    if (!digits.startsWith('91')) {
      digits = '91$digits';
    }
    return '+$digits';
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _errorMessage = 'Please enter a valid 10-digit phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final formattedPhone = _formatPhoneNumber(phone);

    await _authService.sendOTP(
      phoneNumber: formattedPhone,
      onCodeSent: (verificationId) {
        setState(() => _isLoading = false);
        // Navigate to OTP screen with verification ID
        context.push('/otp', extra: {
          'verificationId': verificationId,
          'phoneNumber': formattedPhone,
        });
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      },
      onAutoVerify: (credential) async {
        // Auto-verification successful (Android only)
        try {
          await _authService.verifyOTP(
            verificationId: '',
            otp: credential.smsCode ?? '',
          );
          if (mounted) context.go('/home');
        } catch (e) {
          setState(() => _errorMessage = e.toString());
        }
      },
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Logo
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          startAngle: 2.4,
                          colors: [Color(0xFFFF4FD8), Color(0xFFFFB84D), Color(0xFF5CF1FF), Color(0xFFFF4FD8)],
                        ),
                        boxShadow: [BoxShadow(color: const Color(0xFFFF4FD8).withOpacity(0.7), blurRadius: 14)],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'SHOWGRID',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 2, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // Title
                const Text(
                  'Welcome back!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue your journey',
                  style: TextStyle(fontSize: 15, color: SGColors.htmlMuted),
                ),
                const SizedBox(height: 40),
                // Phone Input
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SGColors.borderSubtle),
                    color: SGColors.htmlGlass,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: SGColors.borderSubtle)),
                        ),
                        child: const Text('+91', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Enter phone number',
                            hintStyle: TextStyle(color: SGColors.htmlMuted),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SGColors.htmlViolet,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: SGColors.borderSubtle)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or', style: TextStyle(color: SGColors.htmlMuted)),
                    ),
                    Expanded(child: Divider(color: SGColors.borderSubtle)),
                  ],
                ),
                const SizedBox(height: 24),
                // Google Sign In
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                    icon: _isGoogleLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : Image.network('https://www.google.com/favicon.ico', width: 24, height: 24,
                            errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.white)),
                    label: Text(_isGoogleLoading ? 'Signing in...' : 'Continue with Google',
                        style: const TextStyle(fontSize: 16, color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: SGColors.borderSubtle),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const Spacer(),
                // Skip for now (dev only)
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Skip for now →', style: TextStyle(color: SGColors.htmlMuted)),
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
