// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../dio_util.dart';

/// 参数拦截器
class ParamsTokenInterceptor extends Interceptor {
  final String token;
  ParamsTokenInterceptor(this.token);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[DioUtil.paramsHeaderKey] = token;
    options.headers['Accept'] = 'application/json';
    super.onRequest(options, handler);
  }
}
