import '../api/services/danmaku_service.dart';
import '../api/models/danmaku.dart';
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_danmaku_repository.dart';

class OttohubDanmakuRepository extends BaseRepository implements IDanmakuRepository {
  @override
  Future<List<ZerexaDanmaku>> getDanmakus(String videoId, {CacheConfig? cacheConfig}) {
    return withCache(
      'getDanmakus_$videoId',
      () => DanmakuService.getDanmakus(videoId),
      cacheConfig: cacheConfig ?? const CacheConfig(duration: Duration(minutes: 5)),
    );
  }

  @override
  Future<void> sendDanmaku({
    required String videoId,
    required String content,
    required double timeSec,
    String color = '#FFFFFF',
    String mode = 'scroll',
  }) {
    invalidateCache('getDanmakus_$videoId');
    return DanmakuService.sendDanmaku(
      videoId: videoId,
      content: content,
      timeSec: timeSec,
      color: color,
      mode: mode,
    );
  }
}
