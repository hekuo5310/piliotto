import 'package:get/get.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/ottohub/api/models/video.dart';

class RelatedController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  String vid = Get.parameters['vid'] ?? '';
  RxList<ZerexaVideo> relatedVideoList = <ZerexaVideo>[].obs;

  Future<dynamic> queryRelatedVideo() async {
    try {
      final videos = await _videoRepo.getRecommend(exclude: vid);
      relatedVideoList.value = videos;
      return {'status': true, 'data': videos};
    } catch (e) {
      return {'status': false, 'message': e.toString()};
    }
  }
}
