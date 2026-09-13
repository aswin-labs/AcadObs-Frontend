// import 'package:acadobs/features/tracking/data/models/today_transportation_model.dart';
// import 'package:flutter/material.dart';

// class RouteStudentBadge extends StatelessWidget {
//   final StudentTransportationInfo? student;
//   final TodayTransportationModel transportation;

//   static const _navyPrimary = Color(0xFF1E3A8A);
//   static const _navyLight = Color(0xFF2563EB);
//   static const _emeraldSuccess = Color(0xFF10B981);
//   static const _emeraldDark = Color(0xFF065F46);
//   static const _emeraldBg = Color(0xFFECFDF5);
//   static const _slateText = Color(0xFF0F172A);
//   static const _slateMuted = Color(0xFF64748B);

//   const RouteStudentBadge({
//     super.key,
//     required this.student,
//     required this.transportation,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (student == null) return const SizedBox.shrink();

//     final isStudentStopArrived = transportation.isStopArrived(student!.stopId);
//     final targetStop = transportation.stops.where(
//       (s) => s.id == student!.stopId,
//     );
//     final stopName =
//         targetStop.isNotEmpty ? targetStop.first.stopName : "Assigned Stop";

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color:
//               isStudentStopArrived
//                   ? _emeraldSuccess.withAlpha(120)
//                   : const Color(0xFFE2E8F0),
//           width: 1.5,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(8),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               color:
//                   isStudentStopArrived ? _emeraldBg : _navyLight.withAlpha(25),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.school_rounded,
//               color: isStudentStopArrived ? _emeraldDark : _navyPrimary,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Fix for the 8px overflow: Flexible + ellipsis
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Flexible(
//                       child: Text(
//                         student!.fullName ?? "Student",
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: _slateText,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     // if (student!.regNo != null &&
//                     //     student!.regNo!.isNotEmpty) ...[
//                     //   const SizedBox(width: 6),
//                     //   Container(
//                     //     padding: const EdgeInsets.symmetric(
//                     //       horizontal: 6,
//                     //       vertical: 2,
//                     //     ),
//                     //     decoration: BoxDecoration(
//                     //       color: const Color(0xFFF1F5F9),
//                     //       borderRadius: BorderRadius.circular(6),
//                     //     ),
//                     //     child: Text(
//                     //       "Reg: ${student!.regNo}",
//                     //       style: const TextStyle(
//                     //         fontSize: 10,
//                     //         color: _slateMuted,
//                     //         fontWeight: FontWeight.w600,
//                     //       ),
//                     //     ),
//                     //   ),
//                     // ],
//                   ],
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   "Assigned Stop: $stopName",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: isStudentStopArrived ? _emeraldDark : _slateMuted,
//                     fontWeight:
//                         isStudentStopArrived
//                             ? FontWeight.w600
//                             : FontWeight.normal,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
//             decoration: BoxDecoration(
//               color:
//                   isStudentStopArrived ? _emeraldBg : const Color(0xFFF8FAFC),
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(
//                 color:
//                     isStudentStopArrived
//                         ? _emeraldSuccess
//                         : const Color(0xFFCBD5E1),
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   isStudentStopArrived
//                       ? Icons.check_circle_rounded
//                       : Icons.schedule_rounded,
//                   size: 13,
//                   color: isStudentStopArrived ? _emeraldDark : _slateMuted,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   isStudentStopArrived ? "Completed" : "Awaiting",
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                     color: isStudentStopArrived ? _emeraldDark : _slateMuted,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
