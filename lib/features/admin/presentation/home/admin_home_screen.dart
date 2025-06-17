import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/presentation/widgets/custom_name_container.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: context.paddingHorizontal,
          child: Column(
            children: [
              SizedBox(height: Responsive.height * 20),
              Row(
                children: [
                  CustomNameContainer(
                    text: "Students",
                    onPressed:
                        () => context.pushNamed(RouteConstants.studentsHome),
                  ),
                  SizedBox(width: 5),
                  CustomNameContainer(text: "Teachers", onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
