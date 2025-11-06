import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CommonChatTile extends StatelessWidget {
  final String subject;
  final String name;
  final String imageUrl;
  final VoidCallback onTap;
  const CommonChatTile({
    super.key,
    required this.name,
    required this.subject,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade500,
          child: CachedNetworkImage(
            imageUrl: imageUrl,

            errorWidget: (context, url, error) => const Icon(Icons.person),
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                subject,
                style: TextStyle(color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
