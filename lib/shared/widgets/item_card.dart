import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

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
    final double avatarRadius = isTablet ? 32 : 28;
    final double titleFontSize = isTablet ? 17 : 16;
    final double descFontSize = isTablet ? 15 : 14;
    final double statusFontSize = isTablet ? 13 : 12;
    final double dateFontSize = isTablet ? 12 : 11;
    final double horizontalPadding = isTablet ? 20 : 16;
    final double verticalPadding = isTablet ? 14 : 12;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(bottomRadius),
            bottomRight: Radius.circular(bottomRadius),
            topLeft: Radius.circular(topRadius),
            topRight: Radius.circular(topRadius),
          ),
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
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Enhanced Avatar with subtle shadow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: backgroundColor.withAlpha(100),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: backgroundColor,
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: isTablet ? 28 : 24,
                          ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 18 : 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              capitalizeEachWord(title),
                              style: context.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: titleFontSize,
                                color: const Color(0xFF1A1A1A),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              description,
                              style: TextStyle(
                                color: const Color(0xFF6B6B6B),
                                fontSize: descFontSize,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12),

                // Right side info with enhanced styling
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (status.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: iconColor.withAlpha(50),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          capitalizeEachWord(status),
                          style: TextStyle(
                            fontSize: statusFontSize,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (date.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: dateFontSize + 2,
                            color: const Color(0xFF9B9B9B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: dateFontSize,
                              color: const Color(0xFF9B9B9B),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:acadobs/core/extensions/context_extensions.dart';
// import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
// import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart';

// class ItemCard extends StatelessWidget {
//   final String title;
//   final String description;
//   final String status;
//   final String date;
//   final double bottomRadius;
//   final double topRadius;
//   final Color backgroundColor;
//   final Color iconColor;
//   final IconData icon;
//   final void Function() onTap;

//   const ItemCard({
//     super.key,
//     required this.title,
//     required this.description,
//     this.status = "",
//     required this.onTap,
//     this.backgroundColor = const Color(0xFFCEFFD3),
//     this.iconColor = const Color(0xFF5DD168),
//     this.icon = LucideIcons.filePlus2,
//     this.bottomRadius = 10,
//     this.topRadius = 10,
//     this.date = "",
//   });

//   @override
//   Widget build(BuildContext context) {
//     //Screen dimensions
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isTablet = screenWidth > 600;

//     //Responsive sizes
//     final double avatarRadius = isTablet ? 32 : 26;
//     final double titleFontSize = isTablet ? 17 : 15;
//     final double descFontSize = isTablet ? 15 : 13;
//     final double dateFontSize = isTablet ? 13 : 11;
//     final double horizontalPadding = isTablet ? 20 : 14;
//     final double verticalPadding = isTablet ? 10 : 8;

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(
//             horizontal: horizontalPadding,
//             vertical: verticalPadding,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(bottomRadius),
//               bottomRight: Radius.circular(bottomRadius),
//               topLeft: Radius.circular(topRadius),
//               topRight: Radius.circular(topRadius),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 flex: 3,
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: avatarRadius,
//                       backgroundColor: backgroundColor,
//                       child: Icon(
//                         icon,
//                         color: iconColor,
//                         size: isTablet ? 26 : 22,
//                       ),
//                     ),
//                     SizedBox(width: isTablet ? 20 : 14),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             capitalizeEachWord(title),
//                             style: context.textTheme.bodyMedium!.copyWith(
//                               fontWeight: FontWeight.w600,
//                               fontSize: titleFontSize,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             description,
//                             style: TextStyle(
//                               color: const Color(0xFF6B6B6B),
//                               fontSize: descFontSize,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Expanded(
//                 flex: 1,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       capitalizeEachWord(status),
//                       style: TextStyle(
//                         fontSize: dateFontSize,
//                         fontWeight: FontWeight.bold,
//                         color: iconColor,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       date,
//                       style: TextStyle(
//                         fontSize: dateFontSize,
//                         color: const Color(0xFF6B6B6B),
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
