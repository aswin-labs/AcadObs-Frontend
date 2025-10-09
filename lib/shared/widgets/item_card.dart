import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final String date;
  final double bottomRadius;
  final double topRadius;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final void Function() onTap;

  const ItemCard({
    super.key,
    required this.title,
    required this.description,
    this.status = "",
    required this.onTap,
    this.backgroundColor = const Color(0xFFCEFFD3),
    this.iconColor = const Color(0xFF5DD168),
    this.icon = LucideIcons.filePlus2,
    this.bottomRadius = 10,
    this.topRadius = 10,
    this.date = "",
  });

  @override
  Widget build(BuildContext context) {
    //Screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    //Responsive sizes
    final double avatarRadius = isTablet ? 32 : 26;
    final double titleFontSize = isTablet ? 17 : 15;
    final double descFontSize = isTablet ? 15 : 13;
    final double dateFontSize = isTablet ? 13 : 11;
    final double horizontalPadding = isTablet ? 20 : 14;
    final double verticalPadding = isTablet ? 10 : 8;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(bottomRadius),
              bottomRight: Radius.circular(bottomRadius),
              topLeft: Radius.circular(topRadius),
              topRight: Radius.circular(topRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: backgroundColor,
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: isTablet ? 26 : 22,
                      ),
                    ),
                    SizedBox(width: isTablet ? 20 : 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitalizeEachWord(title),
                            style: context.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: titleFontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              color: const Color(0xFF6B6B6B),
                              fontSize: descFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      capitalizeEachWord(status),
                      style: TextStyle(
                        fontSize: dateFontSize,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: dateFontSize,
                        color: const Color(0xFF6B6B6B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
