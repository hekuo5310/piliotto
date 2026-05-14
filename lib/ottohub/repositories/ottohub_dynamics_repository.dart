import '../api/services/api_service.dart';
import '../models/dynamics/result.dart';
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_dynamics_repository.dart';

class OttohubDynamicsRepository extends BaseRepository implements IDynamicsRepository {
  DynamicItemModel _fromZerexaDynamic(Map<String, dynamic> json) {
    final List? images = json['images'] as List?;
    final item = DynamicItemModel(
      idStr: json['id']?.toString(),
      type: (images != null && images.isNotEmpty) ? 'DYNAMIC_TYPE_DRAW' : 'DYNAMIC_TYPE_WORD',
    );
    item.modules = ItemModulesModel(
      moduleAuthor: ModuleAuthorModel(
        face: json['author']?['gravatar_url']?.toString(),
        mid: json['author']?['uid'] is int ? json['author']['uid'] : null,
        name: json['author']?['username']?.toString(),
        pubTime: json['created_at']?.toString(),
      ),
      moduleDynamic: ModuleDynamicModel(
        desc: DynamicDescModel(text: json['content']?.toString() ?? ''),
        major: (images != null && images.isNotEmpty)
            ? DynamicMajorModel(
                type: 'MAJOR_TYPE_DRAW',
                draw: DynamicDrawModel(
                  id: 0,
                  items: images.map((url) => DynamicDrawItemModel(src: url.toString(), width: 0, height: 0, size: 0)).toList(),
                ),
              )
            : null,
      ),
      moduleStat: ModuleStatModel(
        like: Like(count: (json['like_count'] ?? 0).toString(), status: json['liked'] == true),
        comment: Comment(count: '0'),
        forward: ForWard(count: '0'),
      ),
    );
    return item;
  }

  @override
  Future<List<DynamicItemModel>> getUserDynamics({required String userId}) async {
    final data = await ApiService.request('/users/$userId/dynamics');
    return (data as List).map((e) => _fromZerexaDynamic(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DynamicItemModel>> getMyDynamics() async {
    final data = await ApiService.request('/users/me/dynamics', requireToken: true);
    return (data as List).map((e) => _fromZerexaDynamic(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, dynamic>> likeDynamic({required String dynamicId}) async {
    final data = await ApiService.request('/dynamics/$dynamicId/like',
        method: 'POST', requireToken: true);
    return data as Map<String, dynamic>;
  }

  @override
  Future<void> deleteDynamic({required String dynamicId}) async {
    await ApiService.request('/dynamics/$dynamicId', method: 'DELETE', requireToken: true);
  }
}
