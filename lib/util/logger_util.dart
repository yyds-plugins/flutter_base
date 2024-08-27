import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Log {
  const Log._();

  static init({
    bool apiLogOpen = true,
    String defaultTag = 'LOG',
    bool expandLog = false,
  }) {
    Log.apiLogOpen = apiLogOpen;
    Log.defaultTag = defaultTag;
    Log.expandLog = expandLog;
  }

  static bool apiLogOpen = true;

  static String defaultTag = 'log';

  static bool expandLog = false;

  static int lineSeparatorLength = 160;

  static final Logger _logger = Logger();
  static void v(dynamic message) {
    _logger.v(message);
  }

  static void t(dynamic message) {
    _logger.t(message);
  }

  static void d(dynamic message) {
    _logger.d(message);
  }

  static void i(dynamic message) {
    _logger.i(message);
  }

  static void w(dynamic message) {
    _logger.w(message);
  }

  static void e(dynamic message) {
    _logger.e(message);
  }

  static void f(dynamic message) {
    _logger.f(message);
  }

  static void l(dynamic message) {
    if (kDebugMode) {
      log(message.toString());
    }
  }

  /// 调试模式打印
  static void p(Object? object) {
    if (kDebugMode) {
      print(object);
    }
  }

  /// 调试模式打印
  static void dp(dynamic object) {
    if (kDebugMode) {
      debugPrint(object?.toString());
    }
  }
  //====================================================

  static void line({
    String separator = '=',
    int? length,
    String tag = '',
    int spaceLine = 0,
  }) {
    String text = separator * (length ?? lineSeparatorLength) + '\n' * spaceLine;
    dev.log(text, name: tag);
  }

  static void i1(
    dynamic message, {
    String? tag,
    StackTrace? stackTrace,
    bool? expand,
  }) {
    _printLog(
      message,
      '${tag ?? defaultTag} ❕',
      stackTrace,
      expand: expand,
    );
  }

  static void d1(
    dynamic message, {
    String? tag,
    StackTrace? stackTrace,
    bool? expand,
  }) {
    _printLog(
      message,
      '${tag ?? defaultTag} 🐛',
      stackTrace,
      expand: expand,
    );
  }

  static void n1(
    dynamic message, {
    String? tag,
    StackTrace? stackTrace,
    int? level,
    bool? expand,
  }) {
    if (apiLogOpen) {
      _printLog(
        message,
        '🌐 ${tag ?? 'network'}',
        stackTrace,
        level: level,
        expand: expand,
      );
    }
  }

  static void w1(
    dynamic message, {
    String? tag,
    StackTrace? stackTrace,
    bool? expand,
  }) {
    _printLog(
      message,
      '${tag ?? defaultTag} ⚠️',
      stackTrace,
      expand: expand,
    );
  }

  static void e1(
    dynamic message, {
    String? tag,
    StackTrace? stackTrace,
    bool withStackTrace = true,
    bool isError = true,
    int? level,
  }) {
    _printLog(
      message,
      '${tag ?? defaultTag} ❌',
      stackTrace,
      level: level ?? 800,
      isError: isError,
      withStackTrace: withStackTrace,
    );
  }

  static void _printLog(
    dynamic message,
    String? tag,
    StackTrace? stackTrace, {
    bool isError = false,
    int? level,
    bool withStackTrace = true,
    bool? expand,
  }) {
    dev.log(
      '${_timeDateFormat(DateTime.now())} ${_messageFormat(message, expand ?? expandLog)}',
      time: DateTime.now(),
      name: tag ?? defaultTag,
      level: level ?? 800,
      stackTrace: stackTrace ?? (isError && withStackTrace ? StackTrace.current : null),
    );
  }

  static dynamic _messageFormat(dynamic message, bool expand) {
    String result = expand ? '\n' : '';
    try {
      if (expand) {
        result += const JsonEncoder.withIndent(' ').convert(message);
      } else {
        result += jsonEncode(message);
      }
    } catch (e) {
      result = message;
    }
    return result;
  }

  static String _timeDateFormat(DateTime dateTime) {
    String intToTwoString(int number) {
      return number.toString().padLeft(2, '0');
    }

    return '[${intToTwoString(dateTime.hour)}:${intToTwoString(dateTime.minute)}:${intToTwoString(dateTime.second)}:${intToTwoString(dateTime.millisecond)}]';
  }
}
