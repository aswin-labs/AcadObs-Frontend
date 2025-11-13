import 'dart:ui';

import 'package:acadobs/features/teacher/presentation/home/widgets/option_tile.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FabOptionsDialog extends StatelessWidget {
  const FabOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withAlpha(68)),
          ),
        ),
        Positioned(
          bottom: 100,
          right: 24,
          left: 24,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(34),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OptionTile(
                    icon: Icons.note_alt_outlined,
                    label: 'Leave Requests',
                    iconColor: Color(0xFF26A69A),
                    onTap: () {
                      context.pushNamed(RouteConstants.staffLeaveRequestHome);
                      Navigator.pop(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  OptionTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Students',
                    iconColor: Color(0xFF1E88E5),
                    onTap: () {
                      context.pushNamed(RouteConstants.studentListing);
                      Navigator.pop(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  OptionTile(
                    icon: LucideIcons.badgeCheck,
                    label: 'Achievements',
                    iconColor: Color(0xFFFF6B6B),
                    onTap: () {
                      context.pushNamed(RouteConstants.achievementList);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
