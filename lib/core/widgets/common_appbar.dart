import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  bool isBackButton;

  CommonAppBar({
    super.key,
    required this.title, // Title is required
    this.actions,
    this.isBackButton = false,
    // Actions are optional
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: isBackButton
          ? GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16,
                    top: 10,
                    bottom: 10,
                    right: 10), // Adjust padding to reduce size
                child: CircleAvatar(
                  radius: 14, // Adjust size
                  backgroundColor: const Color(0xFFD9D9D9),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16, // Reduce icon size
                    color: Colors.black,
                  ),
                ),
              ),
            )
          : null,
      title: Text(title,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
      centerTitle: true,
      backgroundColor: Colors.grey[200],
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: actions, // Optional actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
