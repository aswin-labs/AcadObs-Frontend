import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomTileWidget extends StatelessWidget {
  final String name;
  final String? subtitle;
  final bool isImageIcon;
  final String? imageUrl;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomTileWidget({
    super.key,
    required this.name,
    this.subtitle,
    this.isImageIcon = false,
    this.imageUrl,
    this.icon = Icons.school,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            isImageIcon && imageUrl != null && imageUrl!.isNotEmpty
                ? SizedBox(
                  height: 50,
                  width: 50,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    cacheKey: imageUrl, // 👈 Important
                    fit: BoxFit.fill,
                    errorWidget:
                        (context, url, error) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
                : Icon(icon, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalizeEachWord(name),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              onSelected: (value) {
                if (value == 'edit' && onEdit != null) {
                  onEdit!();
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit, size: 18, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(Icons.delete, size: 18, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
              icon: const Icon(Icons.more_vert, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
