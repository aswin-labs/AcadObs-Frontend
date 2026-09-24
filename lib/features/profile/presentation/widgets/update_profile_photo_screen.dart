import 'dart:io';

import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/profile/presentation/provider/profile_provider.dart';
import 'package:acadobs/features/profile/presentation/screens/full_screen_image.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UpdateProfilePhotoScreen extends StatefulWidget {
  final bool forStaff;
  const UpdateProfilePhotoScreen({super.key, required this.forStaff});

  @override
  State<UpdateProfilePhotoScreen> createState() =>
      _UpdateProfilePhotoScreenState();
}

class _UpdateProfilePhotoScreenState extends State<UpdateProfilePhotoScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not access ${source == ImageSource.camera ? "camera" : "gallery"}.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Choose Profile Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select a clear picture for your school profile',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Take a Photo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Use your device camera',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.indigo.shade100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00AEF0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.photo_library_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Choose from Gallery',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Browse photos on your device',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      if (widget.forStaff) {
        provider.fetchProfileStaff();
      } else {
        provider.fetchProfileGuardian();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CommonAppBar(title: "Edit Profile Photo", isBackButton: true),
      body: _buildProfileContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final profilePhoto =
            widget.forStaff
                ? provider.staffProfile?.user?.dp
                : provider.guardianProfile?.user?.dp;

        if (provider.isLoading &&
            provider.guardianProfile == null &&
            provider.staffProfile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final isUploading = provider.isPhotoLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Status Badge
              if (_selectedImage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined, size: 16, color: Colors.amber.shade900),
                      const SizedBox(width: 8),
                      Text(
                        'New image selected • Pending save',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),

              // Avatar with camera button
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (profilePhoto != null &&
                              profilePhoto.isNotEmpty &&
                              _selectedImage == null) {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder:
                                  (_) => FullScreenImage(
                                    imageUrl:
                                        "${BaseUrls.media}${MediaEndpoints.dp}$profilePhoto",
                                    heroTag:
                                        'profile-pic-${widget.forStaff ? "staff" : "guardian"}',
                                  ),
                            );
                          }
                        },
                        child: Hero(
                          tag:
                              'profile-pic-${widget.forStaff ? "staff" : "guardian"}',
                          child: CircleAvatar(
                            radius: 85,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 81,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage:
                                  _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                      : (profilePhoto != null &&
                                              profilePhoto.isNotEmpty)
                                      ? NetworkImage(
                                        "${BaseUrls.media}${MediaEndpoints.dp}$profilePhoto",
                                      )
                                      : null,
                              child:
                                  _selectedImage == null &&
                                          (profilePhoto == null ||
                                              profilePhoto.isEmpty)
                                      ? Icon(
                                        Icons.person_rounded,
                                        size: 70,
                                        color: Colors.grey.shade400,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Loading overlay on avatar
                    if (isUploading)
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ),

                    // Floating camera icon button
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: isUploading ? null : _showPickOptions,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00AEF0), Color(0xFF0077B6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00AEF0).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                _selectedImage == null
                    ? (profilePhoto != null && profilePhoto.isNotEmpty
                        ? 'Profile Photo'
                        : 'Add a Profile Photo')
                    : 'Photo Selected',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedImage == null
                    ? 'Upload a clear headshot to help others recognize you'
                    : 'Review the preview above, then tap Save Changes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 36),

              // Choose / Change Photo Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isUploading ? null : _showPickOptions,
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
                  label: Text(
                    _selectedImage == null ? "Select New Photo" : "Pick Different Photo",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AEF0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              // Save & Discard Buttons if an image is selected
              if (_selectedImage != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isUploading
                        ? null
                        : () async {
                            final success = await provider.updateProfilePhoto(
                              context: context,
                              imageFile: _selectedImage!,
                              forStaff: widget.forStaff,
                            );
                            if (success && mounted) {
                              setState(() {
                                _selectedImage = null;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isUploading
                        ? const ButtonLoading()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: isUploading
                      ? null
                      : () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text(
                    "Discard Selection",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

