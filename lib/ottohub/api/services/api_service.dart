import 'package:dio/dio.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/services/loggeer.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;
  final bool isTimeout;

  ApiException(
    this.message, [
    this.statusCode,
    this.isNetworkError = false,
    this.isTimeout = false,
  ]);

  @override
  String toString() => 'ApiException: $message';
}

class ApiService {
  static const String baseUrl = 'https://video.zerexa.cn';
  static const String apiPath = '/api';
  static const String _tokenKey = 'zerexa_token';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: '$baseUrl$apiPath',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = getToken();
        if (token != null && !(options.extra['skipToken'] == true)) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final newToken = response.headers.value('X-New-Token');
        if (newToken != null && newToken.isNotEmpty) {
          setToken(newToken);
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        getLogger().e('API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  static void setToken(String token) {
    GStrorage.setting.put(_tokenKey, token);
  }

  static String? getToken() {
    return GStrorage.setting.get(_tokenKey);
  }

  static void clearToken() {
    GStrorage.setting.delete(_tokenKey);
  }

  static String _getFriendlyErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络后重试';
      case DioExceptionType.sendTimeout:
        return '发送超时，请检查网络后重试';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请稍后重试';
      case DioExceptionType.badCertificate:
        return '证书错误，请检查网络环境';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return '未授权，请重新登录';
        if (statusCode == 403) return '访问被拒绝';
        if (statusCode == 404) return '资源不存在';
        if (statusCode == 429) return '操作过于频繁，请稍后重试';
        if (statusCode == 451) return '地区限制';
        if (statusCode == 500) return '服务器错误，请稍后重试';
        return '请求失败 (${statusCode ?? '未知'})';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') == true) {
          return '网络连接失败，请检查网络设置';
        }
        return '网络错误，请稍后重试';
    }
  }

  static Future<dynamic> safeRequest(
    String endpoint, {
    String method = 'GET',
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    bool requireToken = false,
    bool skipToken = false,
  }) async {
    try {
      return await request(
        endpoint,
        method: method,
        body: body,
        headers: headers,
        queryParams: queryParams,
        requireToken: requireToken,
        skipToken: skipToken,
      );
    } on ApiException {
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<dynamic> request(
    String endpoint, {
    String method = 'GET',
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    bool requireToken = false,
    bool skipToken = false,
  }) async {
    init();

    final token = getToken();
    if (requireToken && token == null) {
      throw ApiException('请先登录');
    }

    final options = Options(
      method: method,
      headers: headers,
      extra: {'skipToken': skipToken},
    );

    try {
      Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(endpoint,
              queryParameters: queryParams, options: options);
          break;
        case 'POST':
          response = await _dio.post(endpoint,
              data: body, queryParameters: queryParams, options: options);
          break;
        case 'PUT':
          response = await _dio.put(endpoint,
              data: body, queryParameters: queryParams, options: options);
          break;
        case 'DELETE':
          response = await _dio.delete(endpoint,
              data: body, queryParameters: queryParams, options: options);
          break;
        default:
          throw ApiException('不支持的请求方法');
      }

      getLogger().d(
          'API Request: ${response.requestOptions.uri}, Status: ${response.statusCode}');

      final data = response.data;
      if (data is Map && data['error'] != null) {
        throw ApiException(data['error'].toString(), response.statusCode);
      }

      return data;
    } on DioException catch (e) {
      getLogger().e('API Request Error: ${e.message}');
      final friendlyMessage = _getFriendlyErrorMessage(e);
      final isTimeout = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      final isNetworkError = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown;

      // 尝试从响应体提取错误信息
      final errBody = e.response?.data;
      final errMsg = (errBody is Map && errBody['error'] != null)
          ? errBody['error'].toString()
          : friendlyMessage;

      throw ApiException(errMsg, e.response?.statusCode, isNetworkError, isTimeout);
    } on ApiException {
      rethrow;
    } catch (e) {
      getLogger().e('API Request Error: ${e.toString()}');
      throw ApiException('请求失败，请稍后重试');
    }
  }

  static Future<dynamic> multipartRequest(
    String endpoint, {
    required FormData formData,
    String method = 'POST',
    bool requireToken = false,
  }) async {
    init();

    final token = getToken();
    if (requireToken && token == null) {
      throw ApiException('请先登录');
    }

    final options = Options(
      method: method,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    try {
      final response = await _dio.request(
        endpoint,
        data: formData,
        options: options,
      );

      final data = response.data;
      if (data is Map && data['error'] != null) {
        throw ApiException(data['error'].toString(), response.statusCode);
      }
      return data;
    } on DioException catch (e) {
      final errBody = e.response?.data;
      final errMsg = (errBody is Map && errBody['error'] != null)
          ? errBody['error'].toString()
          : _getFriendlyErrorMessage(e);
      throw ApiException(errMsg, e.response?.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('请求失败，请稍后重试');
    }
  }
}
