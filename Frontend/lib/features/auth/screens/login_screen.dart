import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/token_service.dart';
import '../../dashboard/services/navigation_service.dart';
import 'otp_verification_screen.dart';
import '../../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _completePhoneNumber = ''; // Store complete phone number with country code

  @override
  void initState() {
    super.initState();
    
    // Clear the phone controller to ensure no previous data remains
    _phoneController.clear();
    _completePhoneNumber = '';
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
    
    // Check if user is already logged in
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn && mounted) {
        // Initialize socket connection for already logged in users
        await _initializeSocketConnection();
        
        // Navigate to dashboard if already logged in
        await NavigationService.navigateToDashboard();
      }
    } catch (e) {
      // If there's an error checking auth status, stay on login screen
      print('Error checking auth status: $e');
    }
  }

  // Initialize socket connection for messaging
  Future<void> _initializeSocketConnection() async {
    try {
      print('🚀 [LOGIN] Initializing socket connection...');
      
      // Get authentication data
      final token = await TokenService.getToken();
      final userId = await TokenService.getUserId();
      
      if (token != null && userId != null) {
        print('✅ [LOGIN] User authenticated successfully');
        // Initialize call service for already logged-in user
        RomanticLoginApp.setCurrentUserIdForCalls(userId);
      } else {
        print('❌ [LOGIN] No authentication data found');
      }
    } catch (e) {
      print('❌ [LOGIN] Error initializing socket connection: $e');
      // Don't block navigation if socket initialization fails
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Send OTP via API
        final result = await AuthService.sendOtp(_completePhoneNumber);
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          if (result.success) {
            // Navigate to OTP verification screen
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    OTPVerificationScreen(phoneNumber: _completePhoneNumber),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
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
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
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
        child: SafeArea(
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
                        // Romantic Header
                        _buildHeader(),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 30),
                        
                        // Login Form
                        _buildLoginForm(),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 15 : 25),
                        

                        
                        // Login Button
                        _buildLoginButton(),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 15),
                        
                        // Romantic Footer (hide when keyboard is open)
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
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Heart Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        
        // Title
        Text(
          'Welcome Back',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Let\'s continue our romantic journey',
          style: GoogleFonts.poppins(
            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Enter your phone number',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            IntlPhoneField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
              ),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
              ),
              dropdownTextStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
              ),
              initialCountryCode: 'IN', // Set to India for 10-digit numbers
              onChanged: (phone) {
                _completePhoneNumber = phone.completeNumber;
              },
              validator: (phone) {
                if (phone == null || phone.number.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (phone.number.length != 10) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.pink,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                'Continue with Love ❤️',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }



  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'By continuing, you agree to our',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
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
                  fontSize: 14,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' and ',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Privacy Policy',
                style: GoogleFonts.poppins(
                  fontSize: 14,
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
