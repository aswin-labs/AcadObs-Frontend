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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl ?? "",
                    placeholder:
                        (context, url) => Container(
                          color: const Color.fromARGB(255, 228, 225, 225),
                        ),
                    errorWidget:
                        (context, url, error) => const Icon(
                          Icons.person_2_rounded,
                          color: Colors.grey,
                        ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        capitalizeEachWord(name),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      capitalizeEachWord(description),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF7C7C7C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onPressed,
                child: Text(
                  suffixText,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
