// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../dio_net.dart';

/// 参数拦截器
class ParamsTokenInterceptor extends Interceptor {
  final String token;
  ParamsTokenInterceptor(this.token);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[DioNet.paramsHeaderKey] = token;
    options.headers['Accept'] = 'application/json';
    super.onRequest(options, handler);
  }
}
