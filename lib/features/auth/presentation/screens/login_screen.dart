// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  String _countryCode = '+91';

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _errorMessage = 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fullPhone = '$_countryCode$phone';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (credential) async {
          // Auto-verification (Android only)
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) context.go('/home');
        },
        verificationFailed: (e) {
          setState(() {
            _errorMessage = _getPhoneErrorMessage(e.code);
            _isLoading = false;
          });
        },
        codeSent: (verificationId, resendToken) {
          setState(() => _isLoading = false);
          context.push('/otp', extra: {
            'phoneNumber': fullPhone,
            'verificationId': verificationId,
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _getPhoneErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'too-many-requests':
        return 'Too many attempts. Please try later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Try again later.';
      default:
        return 'Failed to send OTP. Please try again.';
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService.signInWithGoogle();
      
      if (user != null && mounted) {
        context.go('/home');
      } else {
        setState(() {
          _errorMessage = 'Google sign-in was cancelled';
          _isGoogleLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google sign-in failed. Please try again.';
        _isGoogleLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        startAngle: 2.4,
                        colors: [Color(0xFFFF4FD8), Color(0xFFFFB84D), Color(0xFF5CF1FF), Color(0xFFFF4FD8)],
                      ),
                      boxShadow: [BoxShadow(color: const Color(0xFFFF4FD8).withOpacity(0.5), blurRadius: 30)],
                    ),
                    child: const Center(
                      child: Text('SG', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Title
                const Center(
                  child: Text(
                    'Welcome to ShowGrid',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Sign in to continue',
                    style: TextStyle(fontSize: 14, color: SGColors.htmlMuted),
                  ),
                ),
                const SizedBox(height: 40),

                // Phone input
                const Text('Phone Number', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Country code
                    Container(
                      width: 80,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: SGColors.htmlGlass,
                        border: Border.all(color: SGColors.borderSubtle),
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                          value: _countryCode,
                          underline: const SizedBox(),
                          dropdownColor: SGColors.carbonBlack,
                          items: const [
                            DropdownMenuItem(value: '+91', child: Text('+91', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: '+1', child: Text('+1', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: '+44', child: Text('+44', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: '+971', child: Text('+971', style: TextStyle(color: Colors.white))),
                          ],
                          onChanged: (val) => setState(() => _countryCode = val!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Phone number
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          hintStyle: const TextStyle(color: SGColors.htmlMuted),
                          filled: true,
                          fillColor: SGColors.htmlGlass,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: SGColors.borderSubtle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: SGColors.htmlViolet, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: SGColors.borderSubtle),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.redAccent.withOpacity(0.1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Send OTP button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SGColors.htmlViolet,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: SGColors.htmlViolet.withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider(color: SGColors.borderSubtle)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or', style: TextStyle(color: SGColors.htmlMuted)),
                    ),
                    Expanded(child: Divider(color: SGColors.borderSubtle)),
                  ],
                ),
                const SizedBox(height: 30),

                // Google Sign In
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                    icon: _isGoogleLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Image.network(
                            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                            height: 20,
                            width: 20,
                            errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.white),
                          ),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: SGColors.borderSubtle),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Terms
                Center(
                  child: Text(
                    'By continuing, you agree to our\nTerms of Service and Privacy Policy',
                    style: TextStyle(fontSize: 12, color: SGColors.htmlMuted.withOpacity(0.7)),
                    textAlign: TextAlign.center,
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
