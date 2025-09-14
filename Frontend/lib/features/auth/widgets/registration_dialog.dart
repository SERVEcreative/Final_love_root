import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/token_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class RegistrationDialog extends StatefulWidget {
  final String phoneNumber;
  final String? token; // Token from OTP verification
  
  const RegistrationDialog({
    super.key,
    required this.phoneNumber,
    this.token, // Token from OTP verification
  });

  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<RegistrationDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedGender = 'male';
  bool _isLoading = false;
  bool _hasValidToken = true; // Track if user has valid token
  
  // Single animation controller for better performance
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkTokenAvailability();
  }

  /// Check if user has a valid token for profile creation
  Future<void> _checkTokenAvailability() async {
    try {
      String? token = await TokenService.getToken();
      if (token == null || token.isEmpty) {
        token = widget.token; // Fallback to passed token
      }
      
      if (mounted) {
        setState(() {
          _hasValidToken = token != null && token.isNotEmpty;
        });
      }
      
      if (!_hasValidToken) {
        print('Warning: No valid token found for profile creation');
      }
    } catch (e) {
      print('Error checking token availability: $e');
      if (mounted) {
        setState(() {
          _hasValidToken = false;
        });
      }
    }
  }

  /// Navigate back to login screen when token is missing
  void _goBackToLogin() {
    // Clear any stored tokens
    TokenService.clearAllTokens();
    
    // Close dialog and navigate back to login
    Navigator.of(context).pop();
    
    // Show message to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please login again to continue'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300), // Faster animation
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut, // Simpler curve for better performance
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // Smaller slide for smoother feel
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get token from SharedPreferences (primary method)
        String? token = await TokenService.getToken();
        
        // Fallback to passed token if SharedPreferences is empty
        if (token == null || token.isEmpty) {
          token = widget.token;
        }
        
        // Debug logging
        print('Creating profile with token: $token');
        print('Token source: ${token == widget.token ? 'Passed parameter' : 'SharedPreferences'}');
        print('Profile data: name=${_nameController.text.trim()}, gender=$_selectedGender');
        
        // Validate token
        if (token == null || token.isEmpty) {
          throw Exception('No authentication token found. Please login again.');
        }
        
        // Use the new AuthService.createProfile method with authentication headers
        // Get age from the age field
        final age = int.tryParse(_ageController.text);
        if (age == null || age < 18 || age > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid age (18-100)'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final result = await AuthService.createProfile(
          token: token, // Use the retrieved token
          name: _nameController.text.trim(),
          age: age, // Pass age directly
          gender: _selectedGender,
        );
        
        // Debug logging
        print('Profile creation result: ${result.success} - ${result.message}');

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result.success) {
            // Ensure token is saved to SharedPreferences
            await TokenService.saveToken(token);
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            
            // Initialize CallService and navigate to dashboard
            try {
              // Initialize socket connection after successful registration
              await _initializeSocketConnection();
            } catch (e) {
              print('❌ Failed to initialize socket connection after registration: $e');
            }
            
            // Close dialog and navigate to dashboard
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const DashboardScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          } else {
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

  // Initialize socket connection for messaging
  Future<void> _initializeSocketConnection() async {
    try {
      print('🚀 [REGISTRATION] Initializing socket connection...');
      
      // Get authentication data
      final token = await TokenService.getToken();
      final userId = await TokenService.getUserId();
      
      if (token != null && userId != null) {
        print('✅ [REGISTRATION] User authenticated successfully');
      } else {
        print('❌ [REGISTRATION] No authentication data found');
      }
    } catch (e) {
      print('❌ [REGISTRATION] Error initializing socket connection: $e');
      // Don't block navigation if socket initialization fails
    }
  }

  // Optimized dynamic sizing
  double _getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) return screenWidth * 0.92;
    if (screenWidth < 600) return 340;
    return 380;
  }

  double _getDialogPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 400 ? 20 : 24;
  }

  double _getFontSize(BuildContext context, {bool isTitle = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return isTitle ? 22 : 15;
    }
    return isTitle ? 26 : 16;
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = _getDialogWidth(context);
    final dialogPadding = _getDialogPadding(context);
    final titleFontSize = _getFontSize(context, isTitle: true);
    final bodyFontSize = _getFontSize(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF6B9D),
                  Color(0xFFFF8E8E),
                  Color(0xFFFFB3BA),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(dialogPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(), // Smoother scrolling
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Simplified header icon
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Header Text
                      Text(
                        'Complete Your Profile',
                        style: GoogleFonts.poppins(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tell us a bit about yourself 💕',
                        style: GoogleFonts.poppins(
                          fontSize: bodyFontSize - 1,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // Token validation indicator
                      if (!_hasValidToken) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Authentication required. Please login again.',
                                      style: GoogleFonts.poppins(
                                        fontSize: bodyFontSize - 2,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _goBackToLogin,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  'Go to Login',
                                  style: GoogleFonts.poppins(
                                    fontSize: bodyFontSize - 2,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Name Field
                      _buildOptimizedTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        fontSize: bodyFontSize,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Age Field
                      _buildOptimizedTextField(
                        controller: _ageController,
                        label: 'Age',
                        icon: Icons.cake_outlined,
                        fontSize: bodyFontSize,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 18 || age > 100) {
                            return 'Please enter a valid age (18-100)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Gender Selection
                      _buildOptimizedGenderSelector(fontSize: bodyFontSize),
                      const SizedBox(height: 12),

                      // Bio Field
                      _buildOptimizedTextField(
                        controller: _bioController,
                        label: 'Bio (Optional)',
                        icon: Icons.description_outlined,
                        fontSize: bodyFontSize,
                        validator: (value) => null, // Optional field
                      ),
                      const SizedBox(height: 12),

                      // Location Field
                      _buildOptimizedTextField(
                        controller: _locationController,
                        label: 'Location (Optional)',
                        icon: Icons.location_on_outlined,
                        fontSize: bodyFontSize,
                        validator: (value) => null, // Optional field
                      ),
                      const SizedBox(height: 20),

                      // Register Button
                      _buildOptimizedButton(fontSize: bodyFontSize),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double fontSize,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: fontSize,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 22),
        labelStyle: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: fontSize - 1,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }

  Widget _buildOptimizedGenderSelector({required double fontSize}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedGender,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: fontSize,
        ),
        dropdownColor: const Color(0xFFFF6B9D),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white70,
          size: 22,
        ),
        decoration: InputDecoration(
          labelText: 'Gender',
          prefixIcon: const Icon(
            Icons.favorite_outline,
            color: Colors.white70,
            size: 22,
          ),
          labelStyle: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: fontSize - 1,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: [
          _buildDropdownItem('male', 'Male', Icons.male, fontSize),
          _buildDropdownItem('female', 'Female', Icons.female, fontSize),
          _buildDropdownItem('other', 'Other', Icons.person, fontSize),
        ],
        onChanged: (value) {
          setState(() {
            _selectedGender = value!;
          });
        },
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, String text, IconData icon, double fontSize) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedButton({required double fontSize}) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8F9FA)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
              child: ElevatedButton(
          onPressed: (_isLoading || !_hasValidToken) ? null : _registerUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Creating Profile...',
                    style: GoogleFonts.poppins(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF6B9D),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _hasValidToken ? Icons.rocket_launch : Icons.lock_outline,
                    color: _hasValidToken ? const Color(0xFFFF6B9D) : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _hasValidToken ? 'Complete Registration' : 'Authentication Required',
                    style: GoogleFonts.poppins(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: _hasValidToken ? const Color(0xFFFF6B9D) : Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
