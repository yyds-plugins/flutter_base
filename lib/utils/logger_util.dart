import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'dart:developer' as developer;

class JsonLog {
  static const int LEFT_BIG_BRACKET = 123; // "{"
  static const int LEFT_MIDDLE_BRACKET = 91; // "["
  static const int RIGHT_BIG_BRACKET = 125; // "}"
  static const int RIGHT_MIDDLE_BRACKET = 93; // "]"
  static const int COMMA = 44; // ","
  static const String SPACE = "  ";
  static const String WRAP = "\n";

  static void writeSpace(StringBuffer stringBuffer, int writeCount) {
    for (int i = 1; i <= writeCount; i++) {
      stringBuffer.write(SPACE);
    }
  }

  static String formatJson(String jsonStr) {
    var stringBuffer = StringBuffer();
    var codeUnits = jsonStr.codeUnits;
    var deep = 0;
    for (var i = 0; i < codeUnits.length; i++) {
      var unit = codeUnits[i];
      var string = String.fromCharCode(unit);
      switch (unit) {
        case const (LEFT_BIG_BRACKET | LEFT_MIDDLE_BRACKET):
          {
            deep++;
            stringBuffer.write(string);
            stringBuffer.write(WRAP);
            writeSpace(stringBuffer, deep);
          }
          break;
        case const (RIGHT_BIG_BRACKET | RIGHT_BIG_BRACKET):
          {
            deep--;
            stringBuffer.write(WRAP);
            writeSpace(stringBuffer, deep);
            stringBuffer.write(string);
          }
          break;
        case COMMA:
          {
            stringBuffer.write(string);
            stringBuffer.write(WRAP);
            writeSpace(stringBuffer, deep);
          }
          break;
        default:
          {
            stringBuffer.write(string);
          }
          break;
      }
    }
    return stringBuffer.toString();
  }
}

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

  static void log(dynamic message) {
    if (kDebugMode) {
      developer.log(message.toString());
    }
  }


  static void p(Object? object) {
    if (kDebugMode) {
      print(object);
    }
  }

  static void dp(dynamic object) {
    if (kDebugMode) {
      debugPrint(object?.toString());
    }
  }

  //====================================================
  static const String TOP_LINE = "┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────";
  static const String START_LINE = "│ ";
  static const String SPLIT_LINE =
      "|┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄";
  static const String END_LINE = "└────────────────────────────────────────────────────────────────────────────────────────────────────────────────";

  static void jsonLog(dynamic object) {
    print(TOP_LINE);
    print(SPLIT_LINE);
    var formatJson = JsonLog.formatJson(object.toString());
    var splitJson = formatJson.split("\n");
    splitJson.forEach((element) {
      print(START_LINE + element);
    });
    print(END_LINE);
  }
}
