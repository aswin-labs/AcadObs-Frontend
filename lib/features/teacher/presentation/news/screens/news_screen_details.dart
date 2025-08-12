import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/teacher/data/models/news_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NewsScreenDetails extends StatelessWidget {
  final News newModel;
  const NewsScreenDetails({super.key, required this.newModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: newModel.title, isBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 226,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 203, 116, 211),
                borderRadius: BorderRadius.circular(16),
              ),

              //need to place the image
              child: Container(
                width: double.infinity,
                height: 226,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 203, 116, 211),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl:
                        BaseUrls.media +
                        MediaEndpoints.newsImages +
                        newModel.file.toString(),
                    placeholder:
                        (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                    errorWidget:
                        (context, url, error) => const Center(
                          child: Icon(
                            Icons.event,
                            size: 85,
                            color: Colors.white,
                          ),
                        ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                capitalizeEachWord(newModel.title.toString()),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                capitalizeEachWord(newModel.content),
                style: TextStyle(color: const Color(0xFF949494)),
              ),
            ),
            SizedBox(height: 10),

            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFDFCE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        DateFormatter.formatDateTime(newModel.date),
                        style: TextStyle(
                          color: Color(0xFFC56F41),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
