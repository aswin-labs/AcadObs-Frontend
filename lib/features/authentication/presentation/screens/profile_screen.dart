import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/authentication/presentation/provider/auth_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

const Color tPrimaryColor = Color(0xFF1E88E5);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
                        // mainAxisAlignment: MainAxisAlignment.center,
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

                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.edit),
                                    SizedBox(width: 10),
                                    Text(
                                      'Edit profile',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios, size: 13),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.lock_outline),
                                    SizedBox(width: 10),
                                    Text(
                                      'Change password',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios, size: 13),
                                  ],
                                ),
                              ),
                            ),
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

Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> data) {
  return Container(
    padding: const EdgeInsets.all(20),
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
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: tPrimaryColor.withAlpha(25),

          child: const Icon(Icons.person, size: 40, color: tPrimaryColor),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['name'] ?? 'Unknown User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tPrimaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (data['role'] as String? ?? 'User').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              data['email'] as String? ?? 'No Email',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
