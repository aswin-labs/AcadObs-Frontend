import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class StaffDetailsCard extends StatelessWidget {
  final String name;
  final String qualifications;
  final String email;
  final String phone;
  final String subjects;
  final Color backgroundColor;
  final Color borderColor;
  final String profileImageUrl;

  const StaffDetailsCard({
    super.key,
    required this.name,
    required this.qualifications,
    required this.email,
    required this.phone,
    required this.subjects,
    required this.backgroundColor,
    required this.borderColor,
    this.profileImageUrl = "",
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width * 0.04;
    final iconSize = width * 0.05;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: width * 0.2,
            height: width * 0.2,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueGrey,
            ),
            child: ClipOval(
              child: profileImageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: profileImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        LucideIcons.user,
                        size: 40,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      LucideIcons.user,
                      size: 40,
                      color: Colors.white,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 8),

          _buildRow(
            context,
            LucideIcons.mail,
            "Email",
            email,
            iconSize,
            fontSize,
          ),
          _buildRow(
            context,
            LucideIcons.phone,
            "Phone",
            phone,
            iconSize,
            fontSize,
          ),
          _buildRow(
            context,
            LucideIcons.layers,
            "Subjects",
            subjects,
            iconSize,
            fontSize,
          ),
          _buildRow(
            context,
            LucideIcons.award,
            "Qualifications",
            qualifications,
            iconSize,
            fontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    double iconSize,
    double fontSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: iconSize, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$label: ",
                style: context.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
