import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/pricing_service.dart';
import '../../../core/widgets/loading_dialog.dart';
import '../../../core/utils/logger.dart';

class PricingManagementScreen extends StatefulWidget {
  const PricingManagementScreen({super.key});

  @override
  State<PricingManagementScreen> createState() => _PricingManagementScreenState();
}

class _PricingManagementScreenState extends State<PricingManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _smsController = TextEditingController();
  final _audioCallController = TextEditingController();
  final _videoCallController = TextEditingController();
  
  Map<String, double>? _currentPricing;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPricing();
  }

  @override
  void dispose() {
    _smsController.dispose();
    _audioCallController.dispose();
    _videoCallController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentPricing() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user's pricing (you'll need to pass current user ID)
      // For now, using default values
      setState(() {
        _currentPricing = {
          'sms_cost': 15.0,
          'audio_call_cost': 30.0,
          'video_call_cost': 60.0,
        };
        _smsController.text = '15.0';
        _audioCallController.text = '30.0';
        _videoCallController.text = '60.0';
        _isInitialized = true;
      });
    } catch (e) {
      Logger.error('Failed to load pricing', e);
      // Set default values on error
      setState(() {
        _currentPricing = {
          'sms_cost': 15.0,
          'audio_call_cost': 30.0,
          'video_call_cost': 60.0,
        };
        _smsController.text = '15.0';
        _audioCallController.text = '30.0';
        _videoCallController.text = '60.0';
        _isInitialized = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePricing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    LoadingDialog.show(context, message: 'Updating pricing...');

    try {
      final smsCost = double.parse(_smsController.text);
      final audioCallCost = double.parse(_audioCallController.text);
      final videoCallCost = double.parse(_videoCallController.text);

      // Update pricing (you'll need to pass current user ID)
      // For now, just update local state
      setState(() {
        _currentPricing = {
          'sms_cost': smsCost,
          'audio_call_cost': audioCallCost,
          'video_call_cost': videoCallCost,
        };
      });

      LoadingDialog.hide(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pricing updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      LoadingDialog.hide(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update pricing: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pricing Management',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading && !_isInitialized
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.pink,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.pink.withValues(alpha: 0.1),
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildPricingForm(),
                        const SizedBox(height: 30),
                        _buildSaveButton(),
                        const SizedBox(height: 20),
                        _buildPricingInfo(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.monetization_on,
              color: Colors.pink,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Your Pricing',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'Control your earnings by setting competitive prices',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Pricing',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          
          _buildPricingField(
            controller: _smsController,
            label: 'SMS/Chat Cost',
            icon: Icons.chat_bubble,
            color: Colors.blue,
            hint: 'Enter cost per message',
          ),
          const SizedBox(height: 16),
          
          _buildPricingField(
            controller: _audioCallController,
            label: 'Audio Call Cost',
            icon: Icons.call,
            color: Colors.green,
            hint: 'Enter cost per minute',
          ),
          const SizedBox(height: 16),
          
          _buildPricingField(
            controller: _videoCallController,
            label: 'Video Call Cost',
            icon: Icons.videocam,
            color: Colors.purple,
            hint: 'Enter cost per minute',
          ),
        ],
      ),
    );
  }

  Widget _buildPricingField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a price';
            }
            final price = double.tryParse(value);
            if (price == null || price < 0) {
              return 'Please enter a valid price';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _savePricing,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Save Pricing',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildPricingInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Pricing Tips',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip('Set competitive prices to attract more users'),
          _buildTip('Higher prices may reduce demand but increase earnings'),
          _buildTip('Consider your experience and popularity when pricing'),
          _buildTip('You can update pricing anytime'),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
