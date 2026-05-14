import '../services/api_service.dart';
import '../models/auth.dart';

class AuthService {
  // 登录
  static Future<LoginResponse> login({
    required String username,
    required String password,
    String? turnstileToken,
  }) async {
    final body = {
      'username': username,
      'password': password,
      if (turnstileToken != null) 'turnstileToken': turnstileToken,
    };
    final data = await ApiService.request('/auth/login', method: 'POST', body: body, skipToken: true);
    final res = LoginResponse.fromJson(data as Map<String, dynamic>);
    if (res.token != null) ApiService.setToken(res.token!);
    return res;
  }

  // 注册
  static Future<LoginResponse> register({
    required String username,
    required String email,
    required String password,
    required String code,
    String? turnstileToken,
  }) async {
    final body = {
      'username': username,
      'email': email,
      'password': password,
      'code': code,
      if (turnstileToken != null) 'turnstileToken': turnstileToken,
    };
    final data = await ApiService.request('/auth/register', method: 'POST', body: body, skipToken: true);
    final res = LoginResponse.fromJson(data as Map<String, dynamic>);
    if (res.token != null) ApiService.setToken(res.token!);
    return res;
  }

  // 发送注册验证码
  static Future<void> sendRegisterCode({required String email}) async {
    await ApiService.request('/auth/send-code', method: 'POST', body: {'email': email}, skipToken: true);
  }

  // 退出登录
  static Future<void> logout() async {
    await ApiService.request('/auth/logout', method: 'POST');
    ApiService.clearToken();
  }

  // 每日签到（硬币）
  static Future<SignInResponse> checkIn() async {
    final data = await ApiService.request('/coins/checkin', method: 'POST', requireToken: true);
    return SignInResponse.fromJson(data as Map<String, dynamic>);
  }

  // 修改用户名
  static Future<String> updateUsername(String username) async {
    final data = await ApiService.request('/users/me/username', method: 'PUT', requireToken: true, body: {'username': username});
    return (data as Map<String, dynamic>)['username'] as String;
  }

  // 检查用户名可用
  static Future<bool> checkUsernameAvailable(String username, {String? excludeId}) async {
    final data = await ApiService.request('/auth/username-available', queryParams: {
      'username': username,
      if (excludeId != null) 'exclude_id': excludeId,
    }, skipToken: true);
    return (data as Map<String, dynamic>)['available'] == true;
  }
}
