import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatProfileViewer extends StatelessWidget {
  final String imageUrl;
  final String name;

  const ChatProfileViewer({
    super.key,
    required this.imageUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.black.withAlpha(90),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 260,
            height: 300,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                    errorWidget:
                        (context, url, error) => Container(
                          width: 160,
                          height: 160,
                          color: Colors.grey,
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "?",
                              style: const TextStyle(
                                fontSize: 60,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
