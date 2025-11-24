import 'package:acadobs/features/chats/presentation/widgets/chat_profile_viewer.dart';
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
        leading: GestureDetector(
          onTap:
              imageUrl.isNotEmpty
                  ? () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black54,
                      builder:
                          (_) =>
                              ChatProfileViewer(imageUrl: imageUrl, name: name),
                    );
                  }
                  : null,
          child: CircleAvatar(
            radius: 25,
            // backgroundColor: Colors.blueGrey.shade400,
            backgroundColor: Color.fromARGB(255, 80, 159, 238),

            backgroundImage:
                imageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(imageUrl)
                    : null,
            child: Icon(Icons.person),
            // child: CachedNetworkImage(
            //   imageUrl: imageUrl,

            //   errorWidget: (context, url, error) => const Icon(Icons.person),
            //   fit: BoxFit.cover,
            // ),
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
