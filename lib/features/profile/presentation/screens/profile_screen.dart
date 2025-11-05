import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/authentication/presentation/provider/auth_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

const Color tPrimaryColor = Color(0xFF1E88E5);

class ProfileScreen extends StatefulWidget {
  final bool forStaff;
  const ProfileScreen({super.key, required this.forStaff});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authStorage = AuthStorageService();
    final data = await authStorage.getUserData();
    setState(() {
      userData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(title: 'Profile', isBackButton: true),
      body:
          userData == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileHeader(context, userData!),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(decoration: BoxDecoration()),
                    ),

                    SizedBox(height: 30),
                    Container(
                      // height: 150,
                      width: 450,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                    
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Text(
                              "Account settings",
                              style: TextStyle(color: Color(0xFF7C7C7C)),
                            ),
                          ),
                          SizedBox(height: 10),
                          _settingsTile(
                            onTap: () {
                              context.pushNamed(
                                widget.forStaff
                                    ? RouteConstants.editProfileStaff
                                    : RouteConstants.profileDetails,
                              );
                            },
                            text: 'My Profile',
                            icon: Icons.person,
                          ),

                          _settingsTile(
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.updateProfilePhoto,
                                extra: widget.forStaff,
                              );
                            },
                            text: 'Edit Profile Photo',
                            icon: Icons.edit,
                          ),

                          _settingsTile(
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.changePassword,
                                extra: widget.forStaff,
                              );
                            },
                            text: 'Change Password',
                            icon: Icons.lock_outline,
                          ),

                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: GestureDetector(
                              onTap: () async {
                                final storage = AuthStorageService();
                                await storage.clear();
                                if (!context.mounted) return;
                                context.read<AuthProvider>().logout(context);
                                context.go('/login');
                              },
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xFFE13E3E),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

Widget _settingsTile({
  required VoidCallback onTap,
  required String text,
  required IconData icon,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: const BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon),
              SizedBox(width: 10),
              Text(text, style: TextStyle(color: Colors.black)),
              Spacer(),
              Icon(Icons.arrow_forward_ios, size: 13),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> data) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
  final isDesktop = screenWidth > 1000;

  final double avatarRadius =
      isDesktop
          ? 60
          : isTablet
          ? 50
          : 40;

  final double nameFontSize =
      isDesktop
          ? 26
          : isTablet
          ? 22
          : 18;

  final double emailFontSize =
      isDesktop
          ? 16
          : isTablet
          ? 14
          : 12;

  final EdgeInsets containerPadding = EdgeInsets.all(
    isDesktop
        ? 30
        : isTablet
        ? 24
        : 16,
  );

  return LayoutBuilder(
    builder: (context, constraints) {
      return Container(
        padding: containerPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.blue.withAlpha(25),

              backgroundImage:
                  (data['dp'] != null && data['dp'].toString().isNotEmpty)
                      ? NetworkImage(
                        "${BaseUrls.media}${MediaEndpoints.dp}${data['dp']}",
                      )
                      : null,

              child:
                  (data['dp'] == null || data['dp'].toString().isEmpty)
                      ? Icon(Icons.person, size: 40, color: Colors.blue)
                      : null,
            ),
            SizedBox(
              width:
                  isDesktop
                      ? 30
                      : isTablet
                      ? 20
                      : 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'Unknown User',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: nameFontSize,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue, 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (data['role'] as String? ?? 'User').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['email'] ?? 'No Email',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: emailFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
