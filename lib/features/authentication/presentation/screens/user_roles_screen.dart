import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserRolesScreen extends StatelessWidget {
  const UserRolesScreen({super.key});

  void _navigateToHome(BuildContext context, UserType userType) {
    context.pushNamed(
      RouteConstants.bottomNavScreen,
      extra: userType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<UserType> userTypes = UserType.values;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListView.separated(
              itemCount: userTypes.length,
              shrinkWrap: true,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final userType = userTypes[index];

                return GestureDetector(
                  onTap: () => _navigateToHome(context, userType),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Center(
                      child: Text(
                        userType.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
