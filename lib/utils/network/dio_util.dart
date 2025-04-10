import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_base/utils/value_util.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../logger_util.dart';
import 'interceptor/error_interceptor.dart';
import 'interceptor/token_interceptor.dart';

/// 定义服务器错误处理函数host
typedef ServerError = void Function(int? code, String? message, String api);

/// 默认错误处理
/// 这里只打印了一下服务器返回的报错信息
void serverErrorDefaultHandle(int? code, String? message, String api) {}

class DioUtil {
  static final DioUtil _instance = DioUtil._internal();

  /// 不能改
  /// 固定值
  /// 服务器如果查不到这个header值
  /// 将返回非法操作提示
  /// 返回示例
  /// (同上) 非法操作,缺少参数
  static const String paramsHeaderKey = 'params_token';
  String identifier = 'libCachedNetworkData';
  String? prefix;
  Directory? temporaryDirectory;
  Duration? timeout;
  Duration? cacheDuration;
  // 工厂构造函数
  factory DioUtil({
    String? prefix,
    Directory? temporaryDirectory,
    Duration? timeout,
    Duration? cacheDuration,
  }) {
    _instance.prefix = prefix;
    _instance.temporaryDirectory = temporaryDirectory;
    _instance.timeout = timeout;
    _instance.cacheDuration = cacheDuration;
    return _instance; // 返回唯一实例
  }

  ///超时时间
  static const int CONNECT_TIMEOUT = 5000; //10秒
  static const int RECEIVE_TIMEOUT = 10000;

  static final Dio _dio = Dio(BaseOptions(
      // responseType: ResponseType.plain,
      connectTimeout: const Duration(milliseconds: CONNECT_TIMEOUT),
      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: const Duration(milliseconds: RECEIVE_TIMEOUT),
      receiveDataWhenStatusError: true));
  static final CancelToken _cancelToken = CancelToken();

  DioUtil._internal() {
    // 使用 createHttpClient 来设置 SSL 证书验证

    _dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
      // Don't trust any certificate just because their root cert is trusted.
      final HttpClient client = HttpClient(context: SecurityContext(withTrustedRoots: false));
      // You can test the intermediate / root cert here. We just ignore it.
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    });

    //添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      // Log.d("请求之前 header = ${options.headers.toString()}");
      // 如果你想完成请求并返回一些自定义数据，你可以使用 `handler.resolve(response)`。
      // 如果你想终止请求并触发一个错误，你可以使用 `handler.reject(error)`。

      if (options.data != null) {
        var data = ValueUtil.toStr(json.encode(options.data));
        Log.d("data=$data");
      }

      // options.headers.addAll({"token": token, "request_id": requestId});

      return handler.next(options); //continue
    }, onResponse: (Response response, ResponseInterceptorHandler handler) {
      // Log.d("响应之前");
      // 如果你想终止请求并触发一个错误，你可以使用 `handler.reject(error)`。
      return handler.next(response); // continue
    }, onError: (DioException e, ErrorInterceptorHandler handler) {
      // Log.d("错误之前");
      // 如果你想完成请求并返回一些自定义数据，你可以使用 `handler.resolve(response)`。
      return handler.next(e);
    }));

    // 添加拦截器
    if (kDebugMode == true) {
      //只在测试的时候添加
      _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    }
    _dio.interceptors.add(ErrorInterceptor());
    _dio.interceptors.add(TokenInterceptor());
  }

  ///初始化公共属性
  ///
  /// [baseUrl] 地址前缀
  /// [connectTimeout] 连接超时赶时间
  /// [receiveTimeout] 接收超时赶时间
  /// [interceptors] 基础拦截器
  Future<void> init({
    required String baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    List<Interceptor>? interceptors,
  }) async {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: connectTimeout ?? CONNECT_TIMEOUT);
    _dio.options.receiveTimeout = Duration(milliseconds: receiveTimeout ?? RECEIVE_TIMEOUT);
    if (interceptors != null && interceptors.isNotEmpty) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  /// 设置headers
  void setHeaders(Map<String, dynamic> map) {
    _dio.options.headers.addAll(map);
  }

  ///校验证书
  void verifyCert(bool verify) {
    // if (!verify) {
    //   (_dio.httpClientAdapter as IOHttpClientAdapter?)?.onHttpClientCreate = (client) {
    //     client.badCertificateCallback = (X509Certificate cert, String host, int port) {
    //       return true;
    //     };
    //   };
    // }
  }

/*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests({CancelToken? token}) {
    token ?? _cancelToken.cancel("cancelled");
  }

  /// Use to acquire data from network or the cached file.
  ///
  /// Allowed method is one of [GET, POST].
  /// If method is null, the default method is [GET].
  ///
  /// If duration is null, the file will last forever, or will be reacquired while
  /// duration from file created to now is greater than duration specified in the
  /// param.

  Future<dynamic> request(
    String url, {
    Map<String, dynamic>? body,
    String? charset,
    Duration? duration,
    String? method,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    bool reacquire = false,
  }) async {
    timeout ??= const Duration(seconds: 10);
    duration ??= cacheDuration ?? const Duration(hours: 8);

    String cacheUrl = url;

    if (body != null) {
      cacheUrl = '$url?${body.entries.map((entry) {
        return '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}';
      }).join('&')}';
    }

    final valid = await _valid(cacheUrl, duration: duration);

    if (!valid || reacquire) {
      try {
        final response = await _request(
          url,
          params: body,
          method: method,
          headers: headers,
        );

        if (response.data is String) {
          await _cache(cacheUrl, response.data);
          return response.data;
        }
        await _cache(cacheUrl, jsonEncode(response.data));
        return jsonEncode(response.data);
      } catch (error) {
        Log.e('info error=${error}');
        final file = await _generate(cacheUrl);
        return file.readAsString();
      }
    } else {
      final file = await _generate(cacheUrl);
      return file.readAsString();
    }
  }

  ///  get
  Future<Response> _request(String path,
      {String? method,
      Map<String, dynamic>? params,
      Map<String, dynamic>? headers,
      ResponseType? responseType,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress}) async {
    if (method?.toLowerCase() == 'post') {
      final response = post(
        path,
        headers: headers,
        data: params,
        responseType: responseType,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } else {
      return get(
        path,
        headers: headers,
        params: params,
        responseType: responseType,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    }
  }

  /// Check the given url is cached or not.
  Future<bool> cached(String url) async {
    temporaryDirectory ??= await getTemporaryDirectory();
    final hash = md5.convert(utf8.encode(url)).toString();
    String filePath;
    if (prefix != null) {
      filePath = path.join(temporaryDirectory!.path, identifier, prefix, hash);
    } else {
      filePath = path.join(temporaryDirectory!.path, identifier, hash);
    }
    final file = File(filePath);
    return file.exists();
  }

  /// Validate the cached file.
  ///
  /// If the file exists and size is greater than 0, and the file is not expired,
  ///  return true.
  Future<bool> _valid(String url, {Duration? duration}) async {
    final file = await _generate(url);
    final exist = await file.exists();
    final stat = await file.stat();
    final size = stat.size;
    final createdAt = stat.changed;
    final now = DateTime.now();
    final permanent = duration == null;
    var expired = false;
    if (!permanent) {
      expired = now.difference(createdAt).compareTo(duration) > 0;
    }
    return exist && size > 0 && !expired;
  }

  /// Use to generate cache file.
  ///
  /// The file will be saved in [temporaryDirectory].
  Future<File> _generate(String url) async {
    temporaryDirectory ??= await getTemporaryDirectory();
    final hash = md5.convert(utf8.encode(url)).toString();
    String filePath;
    if (prefix != null) {
      filePath = path.join(temporaryDirectory!.path, identifier, prefix, hash);
    } else {
      filePath = path.join(temporaryDirectory!.path, identifier, hash);
    }
    return File(filePath);
  }

  /// Use to cache data.
  ///
  /// Write content to file
  Future<void> _cache(String url, String content) async {
    final file = await _generate(url);
    await file.create(recursive: true);
    await file.writeAsString(content);
  }

  //============
  ///  get
  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? params,
      Map<String, dynamic>? headers,
      ResponseType? responseType,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress,
      bool followRedirects = true}) async {
    _dio.options.headers.addAll(headers ?? {});
    _dio.options.followRedirects = followRedirects;
    _dio.options.responseType = responseType ?? ResponseType.json;
    return await _dio.get<T>(
      path,
      queryParameters: params,
      cancelToken: cancelToken ?? _cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> img<T>(String path,
      {Map<String, dynamic>? params,
      Map<String, dynamic>? headers,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress,
      bool followRedirects = true}) async {
    _dio.options.headers.addAll(headers ?? {});
    _dio.options.followRedirects = followRedirects;
    _dio.options.responseType = ResponseType.bytes;
    return await _dio.get<T>(
      path,
      queryParameters: params,
      cancelToken: cancelToken ?? _cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  ///  post
  Future<Response> post(String path,
      {Map<String, dynamic>? params,
      data,
      Map<String, dynamic>? headers,
      ResponseType? responseType,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    _dio.options.headers.addAll(headers ?? {});
    _dio.options.responseType = responseType ?? ResponseType.json;

    return await _dio.post(
      path,
      data: data,
      queryParameters: params,
      cancelToken: cancelToken ?? _cancelToken,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
    );
  }

  ///  put 操作
  Future<Response> put(String path,
      {data,
      Map<String, dynamic>? params,
      Map<String, dynamic>? headers,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    _dio.options.headers.addAll(headers ?? {});
    _dio.options.responseType = ResponseType.json;

    return await _dio.put(
      path,
      data: data,
      queryParameters: params,
      cancelToken: cancelToken ?? _cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  ///  patch
  Future<Response> patch(String path,
      {data,
      Map<String, dynamic>? params,
      Map<String, dynamic>? headers,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    _dio.options.headers.addAll(headers ?? {});
    _dio.options.responseType = ResponseType.json;

    return await _dio.patch(
      path,
      data: data,
      queryParameters: params,
      cancelToken: cancelToken ?? _cancelToken,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
    );
  }

  ///  delete
  Future<Response> delete(String path,
      {data, Map<String, dynamic>? params, Map<String, dynamic>? headers, CancelToken? cancelToken}) async {
    _dio.options.headers.addAll(headers ?? {});
    _dio.options.responseType = ResponseType.json;

    return await _dio.delete(
      path,
      data: data,
      queryParameters: params,
      cancelToken: cancelToken ?? _cancelToken,
    );
  }

  ///  post form 表单提交
  Future<Response> postForm(String path,
      {Map<String, dynamic>? params,
      Map<String, dynamic>? headers,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    _dio.options.headers.addAll(headers ?? {});
    _dio.options.responseType = ResponseType.json;

    return await _dio.post(
      path,
      data: FormData.fromMap(params ?? {}),
      cancelToken: cancelToken ?? _cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  ///  download 下载
  Future<Response> download(String path, savePath,
      {Map<String, dynamic>? params,
      data,
      bool deleteOnError = true,
      ProgressCallback? onReceiveProgress,
      Map<String, dynamic>? headers,
      CancelToken? cancelToken}) async {
    _dio.options.headers.addAll(headers ?? {});

    return await _dio.download(
      path,
      savePath,
      data: data,
      queryParameters: params,
      deleteOnError: deleteOnError,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken ?? _cancelToken,
    );
  }
}
