import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  final String name;
  final String description;
  final String suffixText;
  final VoidCallback? onPressed;
  final String? imageUrl;
  final IconData icon;
  const ProfileTile({
    super.key,
    required this.name,
    required this.description,
    this.onPressed,
    this.icon = Icons.person_outline,
    this.suffixText = "View",
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 10 : 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE3E6ED)),
            ),
            child: Row(
              children: [
                Container(
                  width: isSmallScreen ? 46 : 52,
                  height: isSmallScreen ? 46 : 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE8EEFF),
                    border: Border.all(
                      color: const Color(0xFFD4DDFB),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl ?? "",
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Center(
                            child: Icon(
                              icon,
                              size: isSmallScreen ? 22 : 25,
                              color: const Color(0xFF4665C5),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Center(
                            child: Icon(
                              icon,
                              size: isSmallScreen ? 22 : 25,
                              color: const Color(0xFF4665C5),
                            ),
                          ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        capitalizeEachWord(name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF242731),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        capitalizeEachWord(description),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: isSmallScreen ? 12 : 13,
                          height: 1.3,
                          color: const Color(0xFF747985),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!isSmallScreen)
                  Text(
                    suffixText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF4665C5),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(width: 6),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: onPressed,
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: Color(0xFF4665C5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
