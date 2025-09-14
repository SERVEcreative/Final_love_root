import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/token_service.dart';
import '../widgets/registration_dialog.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../main.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isResendLoading = false;
  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startResendCountdown();
    // OTP is already sent from login screen, no need to send again
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }



  void _startResendCountdown() {
    if (!mounted) return;
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        if (_resendCountdown > 0) {
          _startResendCountdown();
        } else {
          if (mounted) {
            setState(() {
              _canResend = true;
            });
          }
        }
      }
    });
  }

  Future<void> _sendOTP() async {
    try {
      final result = await AuthService.sendOtp(widget.phoneNumber);
      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;
    
    setState(() {
      _isResendLoading = true;
      _canResend = false;
      _resendCountdown = 30;
    });
    
    await _sendOTP();
    
    if (mounted) {
      setState(() {
        _isResendLoading = false;
      });
      _startResendCountdown();
    }
  }

  Future<void> _verifyOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Verify OTP via API
        final result = await AuthService.verifyOtp(widget.phoneNumber, _otpController.text);
        
        // Debug logging
        print('OTP Verification Response: ${result.toJson()}');
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          if (result.success) {
            final token = result.token;
            final user = result.user;
            final profileCompletion = user?.profileCompletion ?? 0;
            
            if (token != null) {
              // Save token for future use
              await TokenService.saveAuthData(
                token: token,
                userId: user?.id,
              );
              
              if (profileCompletion < 60) { // 80% is the minimum profile completion for login
                // Profile incomplete - show registration dialog
                _showRegistrationDialog(token);
              } else {
                // Profile complete - navigate to dashboard
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Login successful! Welcome back!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Initialize CallService and navigate to dashboard
                Future.delayed(Duration(seconds: 2), () async {
                  if (mounted) {
                    // Initialize CallService with authentication
                    if (token != null && user?.id != null) {
                      try {
                        // Set current user ID for call service
                        RomanticLoginApp.setCurrentUserIdForCalls(user!.id);
                        print('✅ CallService initialized successfully');
                      } catch (e) {
                        print('❌ Failed to initialize CallService: $e');
                      }
                    }
                    _navigateToDashboard();
                  }
                });
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: No token received'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showRegistrationDialog(String token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RegistrationDialog(
        phoneNumber: widget.phoneNumber,
        token: token,
      ),
    );
  }

  void _navigateToDashboard() async {
    // Initialize socket connection after successful login
    await _initializeSocketConnection();
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // Initialize socket connection for messaging
  Future<void> _initializeSocketConnection() async {
    try {
      print('🚀 [OTP] Initializing socket connection...');
      
      // Get authentication data
      final token = await TokenService.getToken();
      final userId = await TokenService.getUserId();
      
      if (token != null && userId != null) {
        print('✅ [OTP] User authenticated successfully');
        
        // Initialize call system
        RomanticLoginApp.setCurrentUserIdForCalls(userId);
      } else {
        print('❌ [OTP] No authentication data found');
      }
    } catch (e) {
      print('❌ [OTP] Error initializing socket connection: $e');
      // Don't block navigation if socket initialization fails
    }
  }

  @override
  void dispose() {
    // Cancel any pending timers
    _resendCountdown = 0;
    _animationController.dispose();
    _otpController.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B9D),
              Color(0xFFFF8E8E),
              Color(0xFFFFB3BA),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 
                                  MediaQuery.of(context).padding.top - 
                                  MediaQuery.of(context).padding.bottom,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildHeader(),
                            SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 15 : 25),
                            _buildOTPForm(),
                            SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 15 : 20),
                            _buildVerifyButton(),
                            const SizedBox(height: 15),
                            _buildResendSection(),
                            const SizedBox(height: 10),
                            // Footer (hide when keyboard is open)
                            if (MediaQuery.of(context).viewInsets.bottom == 0)
                              _buildFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
                  decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
          child: const Icon(
            Icons.phone_android,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Verify Your Number',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a verification code to',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        Text(
          widget.phoneNumber,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildOTPForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _otpController,
            onChanged: (value) {
              // Remove automatic hiding - only hide on gesture
            },
            onCompleted: (value) {
              _verifyOTP();
            },
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(12),
              fieldHeight: 60,
              fieldWidth: 45,
              activeFillColor: Colors.white.withValues(alpha: 0.2),
              inactiveFillColor: Colors.white.withValues(alpha: 0.1),
              selectedFillColor: Colors.white.withValues(alpha: 0.3),
              activeColor: Colors.white,
              inactiveColor: Colors.white.withValues(alpha: 0.5),
              selectedColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            enableActiveFill: true,
            textStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the verification code';
              }
              if (value.length != 6) {
                return 'Please enter a 6-digit code';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Enter the 6-digit code sent to your phone',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                ),
              )
            : Text(
                'Verify & Continue',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          'Didn\'t receive the code?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        if (_canResend)
          TextButton(
            onPressed: _isResendLoading ? null : _resendOTP,
            child: _isResendLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Resend Code',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
          )
        else
          Text(
            'Resend code in $_resendCountdown seconds',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }



  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'By continuing, you agree to our',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Terms of Service',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' and ',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Privacy Policy',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
