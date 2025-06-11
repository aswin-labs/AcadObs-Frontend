import 'package:acadobs/features/bottom_nav/controller/bottom_navbar_controller.dart';
import 'package:acadobs/features/superadmin/school_classes/screens/school_classes_screen.dart';
import 'package:acadobs/features/superadmin/school_subjects/screens/school_subjects_screen.dart';
import 'package:acadobs/features/superadmin/schools/screens/schools_list_screen.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'bottom_nav_widget.dart';

class BottomNavScaffold extends StatelessWidget {
  const BottomNavScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<BottomNavbarController>().currentIndex;

    final pages = [
      const SchoolsListScreen(),
      const SchoolClassesScreen(),
      const SchoolSubjectsScreen(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: const BottomNavWidget(),
    );
  }
}
