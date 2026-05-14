import '../services/api_service.dart';

class CollectionService {
  static Future<List<Map<String, dynamic>>> getMyCollections() async {
    final data = await ApiService.request('/users/me/collections', requireToken: true);
    return (data as List).cast<Map<String, dynamic>>();
  }

  static Future<String> createCollection({required String title, String? description}) async {
    final data = await ApiService.request('/collections', method: 'POST', requireToken: true,
        body: {'title': title, if (description != null) 'description': description});
    return (data as Map<String, dynamic>)['id'] as String;
  }

  static Future<Map<String, dynamic>> getCollection(String id) async {
    final data = await ApiService.request('/collections/$id');
    return data as Map<String, dynamic>;
  }

  static Future<void> addItem(String id, {required String videoId, String? partTitle, int? sortOrder}) async {
    await ApiService.request('/collections/$id/items', method: 'POST', requireToken: true,
        body: {'video_id': videoId, if (partTitle != null) 'part_title': partTitle, if (sortOrder != null) 'sort_order': sortOrder});
  }

  static Future<void> removeItem(String id, String videoId) async {
    await ApiService.request('/collections/$id/items/$videoId', method: 'DELETE', requireToken: true);
  }
}
