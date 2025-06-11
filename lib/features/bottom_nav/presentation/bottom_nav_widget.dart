import 'package:acadobs/features/bottom_nav/controller/bottom_navbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Provider.of<BottomNavbarController>(context);

    return BottomNavigationBar(
      currentIndex: navController.currentIndex,
      onTap: (index) => navController.setIndex(index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: [
        _navItem('Schools', Icon(LucideIcons.home)),
        _navItem('Classes', Icon(LucideIcons.bookOpen)),
        _navItem('Subjects', Icon(LucideIcons.fileText)),
      ],
    );
  }

  BottomNavigationBarItem _navItem(String label, Icon icon) {
    return BottomNavigationBarItem(icon: icon, label: label);
  }
}
