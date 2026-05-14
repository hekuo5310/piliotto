import '../services/api_service.dart';
import '../models/danmaku.dart';

class DanmakuService {
  static Future<List<ZerexaDanmaku>> getDanmakus(String videoId) async {
    final data = await ApiService.request('/videos/$videoId/danmaku');
    return (data as List).map((e) => ZerexaDanmaku.fromJson(e)).toList();
  }

  static Future<void> sendDanmaku({
    required String videoId,
    required String content,
    required double timeSec,
    String color = '#FFFFFF',
    String mode = 'scroll',
  }) async {
    await ApiService.request('/videos/$videoId/danmaku',
        method: 'POST',
        requireToken: true,
        body: {
          'content': content,
          'time_sec': timeSec,
          'color': color,
          'mode': mode,
        });
  }
}
