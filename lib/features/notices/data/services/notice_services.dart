import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class NoticeServices {
  Future<Response> fetchLatestNotices({
    required int pageNo,
    required int limit,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.fetchLatestNotices}?page=$pageNo&limit=$limit',
    );
    return response;
  }

  /// Download notice PDF
  Future<void> downloadNoticePdf({
    required String fileUrl,
    required String savePath,
    ProgressCallback? onReceiveProgress,
  }) async {
    await ApiServices.downloadFile(
      fileUrl,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
