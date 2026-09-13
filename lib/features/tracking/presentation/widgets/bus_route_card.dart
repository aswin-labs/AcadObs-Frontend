import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BusRouteCard extends StatelessWidget {
  /// Names of all students sharing this route (1 or more).
  final List<String> studentNames;
  final String routeName;
  final String vehicleType;
  final String vehicleNumber;
  final String driverName;

  /// Remote URL for the vehicle photo. Falls back to a vehicle icon if null/empty.
  final String? vehiclePhoto;
  final VoidCallback onTap;

  const BusRouteCard({
    super.key,
    required this.studentNames,
    required this.routeName,
    required this.onTap,
    this.vehicleType = '',
    this.vehicleNumber = '',
    this.driverName = '',
    this.vehiclePhoto,
  });

  String _cleanDriverName(String name) {
    if (name.trim().isEmpty) return '';
    final stripped = name.trim().replaceFirst(
      RegExp(r'^(driver|driver\s*name)\s*[:\-]?\s*', caseSensitive: false),
      '',
    );
    return capitalizeEachWord(stripped);
  }

  String _formattedStudentNames(List<String> names) {
    if (names.isEmpty) return '';
    return names.map((n) => capitalizeEachWord(n.trim())).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00AEF0);
    const borderSlate = Color(0xFFE2E8F0);
    final cleanDriver = _cleanDriverName(driverName);
    final formattedStudents = _formattedStudentNames(studentNames);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderSlate, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withAlpha(12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Header: Vehicle photo/icon, route name, vehicle badges, and track CTA --
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Vehicle photo / avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE0F7FF), Color(0xFFBAE6FD)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFB9E6FE),
                          width: 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          (vehiclePhoto != null &&
                                  vehiclePhoto!.trim().isNotEmpty)
                              ? Image.network(
                                vehiclePhoto!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const _VehicleAvatarIcon(),
                              )
                              : const _VehicleAvatarIcon(),
                    ),

                    const SizedBox(width: 12),

                    // Route Name & Vehicle tags
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routeName.trim().isNotEmpty
                                ? routeName.trim()
                                : "School Route",
                            style: GoogleFonts.poppins(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          // Badges: Vehicle Type + Vehicle Registration Number
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (vehicleType.trim().isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.directions_bus_rounded,
                                        size: 11,
                                        color: Color(0xFF0284C7),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        vehicleType.trim().toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0284C7),
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (vehicleNumber.trim().isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    vehicleNumber.trim().toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF334155),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // "Track" pill CTA
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Track",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: accent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // -- Subtle Divider -----------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(height: 1, color: const Color(0xFFF1F5F9)),
                ),

                // -- Recognizable Info: Driver & Student ---------------------
                if (cleanDriver.isNotEmpty) ...[
                  _EntityRow(
                    badgeColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    icon: Icons.person_rounded,
                    label: "Driver Name",
                    value: cleanDriver,
                  ),
                ],

                if (cleanDriver.isNotEmpty && formattedStudents.isNotEmpty)
                  const SizedBox(height: 7),

                if (formattedStudents.isNotEmpty) ...[
                  _EntityRow(
                    badgeColor: const Color(0xFFEEF2FF),
                    iconColor: const Color(0xFF4F46E5),
                    icon: Icons.school_rounded,
                    label: studentNames.length > 1 ? "Students" : "Student",
                    value: formattedStudents,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Private helper widgets --------------------------------------------------

class _VehicleAvatarIcon extends StatelessWidget {
  const _VehicleAvatarIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.directions_bus_rounded,
      color: Color(0xFF00AEF0),
      size: 26,
    );
  }
}

class _EntityRow extends StatelessWidget {
  final Color badgeColor;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String value;

  const _EntityRow({
    required this.badgeColor,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Colored icon avatar badge
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 13, color: iconColor),
        ),
        const SizedBox(width: 8),
        // Distinct label & bold value using Text.rich with GoogleFonts.poppins
        Expanded(
          child: Text.rich(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            TextSpan(
              children: [
                TextSpan(
                  text: "$label: ",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                TextSpan(
                  text: value,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
