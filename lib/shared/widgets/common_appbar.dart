import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool isBackButton;
  final Color? backgroundColor;
  final Color? titleColor;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.isBackButton = false,
    this.backgroundColor = AppColors.background,
    this.titleColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading:
          isBackButton
              ? GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 10,
                    bottom: 10,
                    right: 10,
                  ),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFFD9D9D9),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
              : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: titleColor,
        ),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: actions, // Optional actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
