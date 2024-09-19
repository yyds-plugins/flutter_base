import 'package:dio/dio.dart';

import 'dio_errors.dart';

/// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) {
    // debugPrint('DioError===: ${err.toString()}');
    // error统一处理
    DioErrors error = DioErrors.create(err);
    // 错误提示
    // debugPrint('DioError===: ${appException.toString()}');
    // handler.next(err);
    throw error;
  }
}
