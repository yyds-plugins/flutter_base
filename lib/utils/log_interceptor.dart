import 'package:dio/dio.dart';

import 'logger_util.dart';

class WanLogInterceptor extends Interceptor {
  static const String TOP_LINE = "┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────";
  static const String START_LINE = "│ ";
  static const String SPLIT_LINE =
      "|┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄";
  static const String END_LINE = "└────────────────────────────────────────────────────────────────────────────────────────────────────────────────";

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print(TOP_LINE);
    print(START_LINE + "--> " + options.method + " " + options.uri.toString());
    print(START_LINE + 'responseType: ' + options.responseType.toString());
    print(START_LINE + 'followRedirects: ' + options.followRedirects.toString());
    print(START_LINE + 'connectTimeout: ' + options.connectTimeout.toString());
    print(START_LINE + 'sendTimeout: ' + options.sendTimeout.toString());
    print(START_LINE + 'receiveTimeout: ' + options.receiveTimeout.toString());
    print(START_LINE + 'receiveDataWhenStatusError: ' + options.receiveDataWhenStatusError.toString());
    print(START_LINE + 'extra: ' + options.extra.toString());
    print(START_LINE + "Headers: ");
    options.headers.forEach((name, values) {
      print(START_LINE + "    $name: $values");
    });
    print(END_LINE);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(TOP_LINE);
    print(START_LINE + "<-- " + response.statusCode.toString() + " " + response.requestOptions.uri.toString());
    print(SPLIT_LINE);
    response.headers.forEach((name, values) {
      print(START_LINE + "$name: $values");
    });
    print(START_LINE + "Response Body:");
    var formatJson = JsonLog.formatJson(response.toString());
    var splitJson = formatJson.split("\n");
    splitJson.forEach((element) {
      print(START_LINE + element);
    });
    print(END_LINE);
    handler.next(response);
  }
}
