import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'John Doe');
  final _ageController = TextEditingController(text: '25');
  final _bioController = TextEditingController(
    text: 'Looking for someone special to share life\'s beautiful moments with 💕',
  );
  final _locationController = TextEditingController(text: 'New York');
  final _phoneController = TextEditingController(text: '+1 234 567 8900');

  String _selectedGender = 'Male';
  String _selectedRelationshipStatus = 'Single';
  bool _notificationsEnabled = true;
  bool _locationSharing = true;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Settings content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Picture Section
                          _buildProfilePictureSection(),
                          const SizedBox(height: 30),
                          
                          // Basic Information
                          _buildSectionTitle('Basic Information'),
                          const SizedBox(height: 15),
                          _buildTextField('Full Name', _nameController, Icons.person),
                          const SizedBox(height: 15),
                          _buildTextField('Age', _ageController, Icons.cake, keyboardType: TextInputType.number),
                          const SizedBox(height: 15),
                          _buildDropdownField('Gender', _selectedGender, ['Male', 'Female', 'Other'], (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          }, Icons.wc),
                          const SizedBox(height: 15),
                          _buildDropdownField('Relationship Status', _selectedRelationshipStatus, 
                            ['Single', 'In a Relationship', 'Married', 'Divorced'], (value) {
                            setState(() {
                              _selectedRelationshipStatus = value!;
                            });
                          }, Icons.favorite),
                          const SizedBox(height: 30),
                          
                          // Contact Information
                          _buildSectionTitle('Contact Information'),
                          const SizedBox(height: 15),
                          _buildTextField('Phone Number', _phoneController, Icons.phone, keyboardType: TextInputType.phone),
                          const SizedBox(height: 15),
                          _buildTextField('Location', _locationController, Icons.location_on),
                          const SizedBox(height: 30),
                          
                          // About Me
                          _buildSectionTitle('About Me'),
                          const SizedBox(height: 15),
                          _buildTextField('Bio', _bioController, Icons.edit, maxLines: 3),
                          const SizedBox(height: 30),
                          
                          // Preferences
                          _buildSectionTitle('Preferences'),
                          const SizedBox(height: 15),
                          _buildSwitchTile('Enable Notifications', 'Receive notifications for new messages and calls', 
                            _notificationsEnabled, (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          }, Icons.notifications),
                          const SizedBox(height: 10),
                          _buildSwitchTile('Location Sharing', 'Allow others to see your location', 
                            _locationSharing, (value) {
                            setState(() {
                              _locationSharing = value;
                            });
                          }, Icons.location_on),
                          const SizedBox(height: 30),
                          
                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Save Profile 💕',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.pink.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.pink,
              size: 50,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _changeProfilePicture,
            icon: const Icon(Icons.camera_alt, size: 18),
            label: Text(
              'Change Photo',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.withValues(alpha: 0.1),
              foregroundColor: Colors.pink,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.pink),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.pink, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, 
      Function(String?) onChanged, IconData icon) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.pink),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.pink, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.pink,
          ),
        ],
      ),
    );
  }

  void _changeProfilePicture() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Change Profile Picture',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera feature coming soon! 📸')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gallery feature coming soon! 🖼️')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Profile updated successfully! 💕',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }
}
