import '../services/api_service.dart';

class AnnouncementService {
  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final data = await ApiService.request('/announcements');
    return (data as List).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getAllAnnouncements() async {
    final data = await ApiService.request('/announcements/all');
    return (data as List).cast<Map<String, dynamic>>();
  }

  static Future<void> markRead(String id) async {
    await ApiService.request('/announcements/$id/read', method: 'POST');
  }
}
