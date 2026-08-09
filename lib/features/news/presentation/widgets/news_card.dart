import 'dart:convert';
import 'dart:developer';

import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/news/data/models/news_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final String title;
  final VoidCallback button;
  final String time;
  final String date;
  final String content;
  final double bottomRadius;
  final double topRadius;

  const NewsCard({
    required this.news,
    super.key,
    required this.button,
    required this.date,
    required this.time,
    required this.title,
    required this.content,
    this.bottomRadius = 12,
    this.topRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final String? imageUrl =
        news.images.isNotEmpty && news.images.first.imageUrl != null
            ? BaseUrls.media +
                MediaEndpoints.newsImages +
                news.images.first.imageUrl!
            : null;
    log(jsonEncode(news.toJson())); // Log the image URL for debugging

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: button,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(bottomRadius),
              bottomRight: Radius.circular(bottomRadius),
              topLeft: Radius.circular(topRadius),
              topRight: Radius.circular(topRadius),
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(38),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // News thumbnail
                Stack(
                  children: [
                    Container(
                      width: 105,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Icon(
                                Icons.newspaper_outlined,
                                color: Colors.grey.shade400,
                                size: 32,
                              ),
                        ),
                      ),
                    ),

                    // NEWS badge
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'NEWS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.25,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              date,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Icon(
                            Icons.access_time,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),

                          Flexible(
                            child: Text(
                              time,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
