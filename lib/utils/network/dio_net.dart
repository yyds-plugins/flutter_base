import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../logger_util.dart';
import '../value_util.dart';
import 'interceptor/error_interceptor.dart';
import 'interceptor/token_interceptor.dart';

/// 定义服务器错误处理函数host
typedef ServerError = void Function(int? code, String? message, String api);

/// 默认错误处理
/// 这里只打印了一下服务器返回的报错信息
void serverErrorDefaultHandle(int? code, String? message, String api) {}

class DioNet {
  static final DioNet _instance = DioNet._internal();
  factory DioNet() => _instance;

  ///超时时间
  static const int CONNECT_TIMEOUT = 5000; //10秒
  static const int RECEIVE_TIMEOUT = 10000;

  /// 不能改
  /// 固定值
  /// 服务器如果查不到这个header值
  /// 将返回非法操作提示
  /// 返回示例
  /// (同上) 非法操作,缺少参数
  static const String paramsHeaderKey = 'params_token';

  static final Dio _dio = Dio(BaseOptions(
      // responseType: ResponseType.plain,
      connectTimeout: const Duration(milliseconds: CONNECT_TIMEOUT),
      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: const Duration(milliseconds: RECEIVE_TIMEOUT),
      receiveDataWhenStatusError: true));
  static final CancelToken _cancelToken = CancelToken();

  DioNet._internal() {
    //添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      // Log.d("请求之前 header = ${options.headers.toString()}");
      // 如果你想完成请求并返回一些自定义数据，你可以使用 `handler.resolve(response)`。
      // 如果你想终止请求并触发一个错误，你可以使用 `handler.reject(error)`。

      var data = ValueUtil.toStr(json.encode(options.data));
      Log.d("data=$data");

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
  Future<void> init({required String baseUrl, int? connectTimeout, int? receiveTimeout, List<Interceptor>? interceptors}) async {
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

  ///  get
  Future<Response> request(String path,
      {String? method,
      Map<String, dynamic>? params,
      Map<String, dynamic>? headers,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress}) async {
    if (method == "POST") {
      return post(
        path,
        headers: headers,
        data: params,
      );
    } else {
      return get(
        path,
        headers: headers,
        params: params,
      );
    }
  }

  ///  get
  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? params,
      Map<String, dynamic>? headers,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress,
      bool followRedirects = true}) async {
    _dio.options.headers.addAll(headers ?? {});
    _dio.options.followRedirects = followRedirects;
    _dio.options.responseType = ResponseType.json;
    return await _dio!.get<T>(
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
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    _dio.options.headers.addAll(headers ?? {});
    _dio.options.responseType = ResponseType.json;

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

    return await _dio!.patch(
      path,
      data: data,
      queryParameters: params,
      cancelToken: cancelToken ?? _cancelToken,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
    );
  }

  ///  delete
  Future<Response> delete(String path, {data, Map<String, dynamic>? params, Map<String, dynamic>? headers, CancelToken? cancelToken}) async {
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
