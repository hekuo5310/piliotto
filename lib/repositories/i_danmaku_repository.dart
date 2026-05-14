import 'package:piliotto/ottohub/api/models/danmaku.dart';
import 'base_repository.dart';

abstract class IDanmakuRepository {
  Future<List<ZerexaDanmaku>> getDanmakus(String videoId, {CacheConfig? cacheConfig});
  Future<void> sendDanmaku({
    required String videoId,
    required String content,
    required double timeSec,
    String color = '#FFFFFF',
    String mode = 'scroll',
  });
}
