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
    final imageUrl =
        news.images.isNotEmpty && news.images.first.imageUrl != null
            ? BaseUrls.media +
                MediaEndpoints.newsImages +
                news.images.first.imageUrl!
            : null;

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
            padding: const EdgeInsets.all(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(25),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl ?? '',
                        placeholder:
                            (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Icon(
                              Icons.image_outlined,
                              color: Colors.grey.withAlpha(38),
                              size: 36,
                            ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              content,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                height: 1.3,
                              ),

                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        // Date pill
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFFE6F3FF),
                              border: Border.all(
                                color: const Color(0xFF1E88E5).withAlpha(77),
                              ),
                            ),
                            child: Text(
                              date,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E88E5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Time Section
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 4),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:acadobs/core/utils/urls/base_urls.dart';
// import 'package:acadobs/core/utils/urls/media_end_points.dart';
// import 'package:acadobs/features/news/data/models/news_model.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';

// class NewsCard extends StatelessWidget {
//   final News news;
//   final String title;
//   final VoidCallback button;
//   final String time;
//   final String date;
//   final String content;
//   final double bottomRadius;
//   final double topRadius;

//   const NewsCard({
//     required this.news,
//     super.key,
//     required this.button,
//     required this.date,
//     required this.time,
//     required this.title,
//     required this.content,
//     this.bottomRadius = 8,
//     this.topRadius = 8,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 1),
//       child: GestureDetector(
//         onTap: button,
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(bottomRadius),
//               bottomRight: Radius.circular(bottomRadius),
//               topLeft: Radius.circular(topRadius),
//               topRight: Radius.circular(topRadius),
//             ),
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 offset: const Offset(0, 2),
//                 blurRadius: 4,
//                 color: Colors.black12,
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             child: IntrinsicHeight(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Image Section
//                   Container(
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.purple[300],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: CachedNetworkImage(
//                         imageUrl:
//                             BaseUrls.media +
//                             MediaEndpoints.newsImages +
//                             (news.file ?? ""),
//                         placeholder:
//                             (context, url) => const Center(
//                               child: CircularProgressIndicator(),
//                             ),
//                         errorWidget:
//                             (context, url, error) => const Icon(Icons.error),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),

//                   // Content Section
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(top: 4, right: 8),
//                               child: Text(
//                                 title,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 2), // Reduced spacing
//                             Text(
//                               content,
//                               style: const TextStyle(color: Colors.grey),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                         // Date pill
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8, bottom: 4),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(15),
//                               color: const Color.fromARGB(255, 217, 182, 236),
//                             ),
//                             child: Text(
//                               date,
//                               style: const TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color.fromARGB(255, 54, 18, 65),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Time Section
//                   Padding(
//                     padding: const EdgeInsets.only(right: 8, top: 4),
//                     child: Text(
//                       time,
//                       style: const TextStyle(color: Colors.black, fontSize: 11),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
