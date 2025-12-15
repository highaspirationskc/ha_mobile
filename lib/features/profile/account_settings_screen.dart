import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/session.dart';
import '../../core/theme/brand_colors.dart';
import '../../core/utils/phone_formatter.dart';
import '../../business/user/entities/user.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../../presentation/widgets/avatar.dart';
import '../../presentation/screens/login_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  // Form controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Avatar state
  String? _imageUrlOverride;
  Uint8List? _imageBytesOverride;
  int? _colorIndexOverride;

  // Track if form has changes
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUserData = await ApiService.instance.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = currentUserData.user;
          _firstNameController.text = currentUserData.user.firstName ?? '';
          _lastNameController.text = currentUserData.user.lastName ?? '';
          _emailController.text = currentUserData.user.email ?? '';
          // Format phone number for display
          _phoneController.text = PhoneFormatter.format(
            currentUserData.user.phone,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load user data: $e')));
      }
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _handleSave() async {
    if (!_hasChanges) return;

    // Validate phone number - must be empty or exactly 10 digits
    final phoneDigits = PhoneFormatter.extractDigits(_phoneController.text);
    if (phoneDigits.isNotEmpty && phoneDigits.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number must be 10 digits'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ApiService.instance.updateUserProfile(
        userId: currentUserId,
        firstName: _firstNameController.text.trim().isNotEmpty
            ? _firstNameController.text.trim()
            : null,
        lastName: _lastNameController.text.trim().isNotEmpty
            ? _lastNameController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        phoneNumber: phoneDigits.isNotEmpty ? phoneDigits : null,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleAvatarChange(XFile? xFile) async {
    if (xFile == null) {
      setState(() {
        _imageUrlOverride = null;
        _imageBytesOverride = null;
      });
      return;
    }

    try {
      final bytes = await xFile.readAsBytes();
      final fileName = xFile.name;

      setState(() {
        _imageBytesOverride = bytes;
        _isUploadingAvatar = true;
      });

      final newAvatarUrl = await ApiService.instance.updateUserAvatar(
        userId: currentUserId,
        imageBytes: bytes,
        fileName: fileName.isNotEmpty ? fileName : 'avatar.jpg',
      );

      if (mounted) {
        setState(() {
          _imageUrlOverride = newAvatarUrl;
          _imageBytesOverride = null;
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _imageBytesOverride = null;
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update picture: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleResetPassword() async {
    // Show a dialog indicating this feature is coming soon
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text(
          'Password reset functionality will be available soon. For now, please contact support if you need to reset your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogOut() async {
    final shouldLogOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogOut == true && mounted) {
      await AuthService.instance.logout();
      clearAuthenticatedUser();

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleContactSupport() async {
    // TODO: Replace with actual support email
    const supportEmail = 'support@example.com';
    final uri = Uri.parse('mailto:$supportEmail');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final u = _currentUser ?? currentUser;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  Avatar(
                    firstName: u.firstName,
                    lastName: u.lastName,
                    image: _imageUrlOverride ?? u.image,
                    imageBytes: _imageBytesOverride,
                    colorIndex: _colorIndexOverride ?? u.colorIndex,
                    editable: true,
                    isLoading: _isUploadingAvatar,
                    onImagePicked: _handleAvatarChange,
                    onColorChanged: (i) =>
                        setState(() => _colorIndexOverride = i),
                    size: 64,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to change photo',
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Personal Information Section
            Text(
              'Personal Information',
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // First Name
            _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),

            // Last Name
            _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),

            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'example@email.com',
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),

            // Phone Number
            _buildPhoneField(),
            const SizedBox(height: 24),

            // Save Button
            if (_hasChanges)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: kHAPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            const SizedBox(height: 32),

            // Security Section
            Text(
              'Security',
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Reset Password Button
            OutlinedButton.icon(
              onPressed: _handleResetPassword,
              icon: const Icon(Icons.lock_outline),
              label: const Text('Reset Password'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Logout Button at bottom
            OutlinedButton.icon(
              onPressed: _handleLogOut,
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                side: BorderSide(color: cs.error),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Contact Support
            Center(
              child: GestureDetector(
                onTap: _handleContactSupport,
                child: Text(
                  'Contact Support',
                  style: t.bodyMedium?.copyWith(
                    color: kHAPrimary,
                    decoration: TextDecoration.underline,
                    decorationColor: kHAPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100), // Space for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [PhoneInputFormatter()],
      onChanged: (_) => _onFieldChanged(),
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: '(555) 555-5555',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
