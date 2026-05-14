import 'dart:collection';
import 'package:piliotto/ottohub/api/models/danmaku.dart';
import 'package:piliotto/ottohub/api/services/danmaku_service.dart';
import 'package:piliotto/services/loggeer.dart';

class PlDanmakuController {
  final String vid;
  final Function(List<ZerexaDanmaku>)? onLoaded;

  PlDanmakuController({required this.vid, this.onLoaded});

  static final Set<String> _loadingVids = {};
  static final Map<String, List<ZerexaDanmaku>> _cachedDanmaku = {};

  SplayTreeMap<int, List<ZerexaDanmaku>> _danmakuMap = SplayTreeMap();
  bool _loaded = false;
  bool _loading = false;

  SplayTreeMap<int, List<ZerexaDanmaku>> get danmakuMap => _danmakuMap;
  bool get loaded => _loaded;
  bool get initiated => _loaded;

  void initiate(int videoDuration, int progress) async {
    if (_loaded || _loading) return;
    if (_loadingVids.contains(vid)) return;
    _loading = true;
    _loadingVids.add(vid);
    await queryDanmaku();
  }

  Future<void> queryDanmaku() async {
    if (_cachedDanmaku.containsKey(vid)) {
      _danmakuMap = _mapDanmaku(_cachedDanmaku[vid]!);
      _loaded = true;
      _loading = false;
      _loadingVids.remove(vid);
      onLoaded?.call(_cachedDanmaku[vid]!);
      return;
    }
    try {
      final response = await DanmakuService.getDanmakus(vid);
      _cachedDanmaku[vid] = response;
      _danmakuMap = _mapDanmaku(response);
      _loaded = true;
      onLoaded?.call(response);
    } catch (e) {
      getLogger().e('获取弹幕失败: $e');
    } finally {
      _loading = false;
      _loadingVids.remove(vid);
    }
  }

  SplayTreeMap<int, List<ZerexaDanmaku>> _mapDanmaku(List<ZerexaDanmaku> list) {
    final map = SplayTreeMap<int, List<ZerexaDanmaku>>();
    for (final d in list) {
      map.putIfAbsent(d.timeSec.toInt(), () => []).add(d);
    }
    return map;
  }

  List<ZerexaDanmaku>? getCurrentDanmaku(int progress) {
    if (!_loaded) {
      if (!_loading && !_loadingVids.contains(vid)) queryDanmaku();
      return null;
    }
    return _danmakuMap[progress];
  }

  void clear() {
    _danmakuMap.clear();
    _loaded = false;
    _loading = false;
    _loadingVids.remove(vid);
  }

  static void clearCache(String vid) {
    _cachedDanmaku.remove(vid);
    _loadingVids.remove(vid);
  }

  static void clearAllCache() {
    _cachedDanmaku.clear();
    _loadingVids.clear();
  }
}

