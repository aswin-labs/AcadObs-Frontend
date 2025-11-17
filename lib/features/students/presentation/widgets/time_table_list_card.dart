// import 'package:acadobs/core/extensions/context_extensions.dart';
// import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
// import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart';

// class TimeTableListCard extends StatelessWidget {
//   final String subject;
//   final String teacher;
//   final String status;
//   final String classname;
//   final double bottomRadius;
//   final double topRadius;
//   final Color backgroundColor;
//   final Color iconColor;
//   final IconData icon;
//   final int periodNumber;

//   final void Function() onTap;

//   const TimeTableListCard({
//     super.key,
//     required this.subject,
//     required this.teacher,
//     this.status = "",
//     required this.classname,
//     required this.onTap,
//     this.backgroundColor = const Color(0xFFFFECCE),
//     this.iconColor = const Color(0xFFA86637),
//     this.icon = LucideIcons.clipboardList,
//     this.bottomRadius = 8,
//     this.topRadius = 8,
//     required this.periodNumber,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 2),
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(bottomRadius),
//               bottomRight: Radius.circular(bottomRadius),
//               topLeft: Radius.circular(topRadius),
//               topRight: Radius.circular(topRadius),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 22,
//                         backgroundColor: backgroundColor,
//                         child: Icon(icon, color: iconColor),
//                       ),
//                       SizedBox(height: 5),
//                       //time container
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 6,
//                           vertical: 3,
//                         ),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           color: Color(0xFFFFECCE),
//                         ),
//                         child: Text(
//                           '$periodNumber',
//                           style: TextStyle(color: Color(0xFFA86637)),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(width: 15),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         capitalizeEachWord(subject),
//                         style: context.textTheme.bodyMedium!.copyWith(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),

//                       SizedBox(height: 2),
//                       Row(
//                         children: [
//                           Icon(Icons.person, color: Colors.black, size: 18),
//                           SizedBox(width: 4),
//                           Text(
//                             teacher,
//                             style: TextStyle(
//                               color: Colors.black54,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: 2),

//                       //classname
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.location_on_outlined,
//                             color: Colors.black,
//                             size: 18,
//                           ),
//                           SizedBox(width: 4),
//                           Text(
//                             classname,
//                             style: TextStyle(
//                               color: Colors.black54,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               Text(
//                 capitalizeEachWord(status),
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                   color: iconColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TimeTableListCard extends StatelessWidget {
  final String subject;
  final String? teacher;
  final String status;
  final String classname;
  final double bottomRadius;
  final double topRadius;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final int periodNumber;
  final void Function() onTap;
  final bool? forStaff;

  const TimeTableListCard({
    super.key,
    required this.subject,
    this.teacher,
    this.status = "",
    required this.classname,
    required this.onTap,
    this.backgroundColor = const Color(0xFFFFECCE),
    this.iconColor = const Color(0xFFA86637),
    this.icon = LucideIcons.clipboardList,
    this.bottomRadius = 8,
    this.topRadius = 8,
    required this.periodNumber,
    this.forStaff = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(9),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: backgroundColor.withAlpha(68),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Period Number Badge
                  Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              backgroundColor,
                              backgroundColor.withAlpha(180),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: backgroundColor.withAlpha(68),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: iconColor, size: 22),
                            const SizedBox(height: 2),
                            Text(
                              'P$periodNumber',
                              style: TextStyle(
                                color: iconColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Subject Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject Name
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                capitalizeEachWord(subject),
                                style: context.textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        (forStaff ?? false)
                            ? const SizedBox(height: 8)
                            : SizedBox.shrink(),

                        // Teacher Info
                        Row(
                          children: [
                            (forStaff ?? false)
                                ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Colors.grey[700],
                                    size: 14,
                                  ),
                                )
                                : SizedBox.shrink(),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                teacher ?? "",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        (forStaff ?? false)
                            ? const SizedBox(height: 6)
                            : SizedBox.shrink(),

                        // Classroom Info
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.location_on_outlined,
                                color: Colors.grey[700],
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              classname,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
