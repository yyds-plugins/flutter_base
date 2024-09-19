import 'package:dio/dio.dart';

import '../../logger_util.dart';

class LoadingInterceptor extends InterceptorsWrapper {
  // 在请求开始时根据参数显示加载提示框
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['showLoading'] == true) {
      // 显示加载提示框的代码
      Log.d('显示加载提示框');
    }

    // 继续处理请求
    handler.next(options);
  }

  // 在请求结束时隐藏加载提示框
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.extra['showLoading'] == true) {
      // 隐藏加载提示框的代码
      Log.d('隐藏加载提示框');
    }

    // 继续处理响应
    handler.next(response);
  }

  // 在请求错误时隐藏加载提示框
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.extra['showLoading'] == true) {
      // 隐藏加载提示框的代码
      Log.d('隐藏加载提示框');
    }

    // 继续处理错误
    handler.next(err);
  }
}
