// lib/features/auth/presentation/screens/otp_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  
  bool _isLoading = false;
  String? _errorMessage;
  int _resendTimer = 30;
  Timer? _timer;
  
  String? _verificationId;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    _verificationId = extra?['verificationId'];
    _phoneNumber = extra?['phoneNumber'];
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOTP() async {
    if (_otp.length != 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit OTP');
      return;
    }

    if (_verificationId == null) {
      setState(() => _errorMessage = 'Session expired. Please request a new OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.verifyOTP(
        verificationId: _verificationId!,
        otp: _otp,
      );

      if (result != null && result.user != null) {
        // Create user profile in Firestore
        await _firestoreService.createUserOnFirstLogin(
          uid: result.user!.uid,
          phone: result.user!.phoneNumber,
          email: result.user!.email,
          displayName: result.user!.displayName,
          photoUrl: result.user!.photoURL,
        );

        if (mounted) context.go('/home');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _resendOTP() async {
    if (_resendTimer > 0 || _phoneNumber == null) return;

    setState(() => _errorMessage = null);

    await _authService.sendOTP(
      phoneNumber: _phoneNumber!,
      onCodeSent: (verificationId) {
        setState(() => _verificationId = verificationId);
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully!')),
        );
      },
      onError: (error) {
        setState(() => _errorMessage = error);
      },
      onAutoVerify: (_) {},
    );
  }

  void _onOTPChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-submit when all digits entered
    if (_otp.length == 6) {
      _verifyOTP();
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
                // Back button
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  'Enter OTP',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a code to ${_phoneNumber ?? 'your phone'}',
                  style: const TextStyle(fontSize: 15, color: SGColors.htmlMuted),
                ),
                const SizedBox(height: 40),
                // OTP Input Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      height: 60,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: SGColors.htmlGlass,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: SGColors.borderSubtle),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: SGColors.borderSubtle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: SGColors.htmlViolet, width: 2),
                          ),
                        ),
                        onChanged: (value) => _onOTPChanged(index, value),
                      ),
                    );
                  }),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
                const SizedBox(height: 32),
                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SGColors.htmlViolet,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Verify OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
                // Resend OTP
                Center(
                  child: TextButton(
                    onPressed: _resendTimer == 0 ? _resendOTP : null,
                    child: Text(
                      _resendTimer > 0 ? 'Resend OTP in ${_resendTimer}s' : 'Resend OTP',
                      style: TextStyle(
                        color: _resendTimer > 0 ? SGColors.htmlMuted : SGColors.htmlViolet,
                        fontSize: 14,
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
