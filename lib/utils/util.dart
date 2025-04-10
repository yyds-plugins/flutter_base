import 'dart:convert';

import 'package:flutter_base/flutter_base.dart';
import 'package:url_launcher/url_launcher.dart';

export 'package:flutter_base/utils/chore.dart';
export 'package:flutter_base/utils/date_util.dart';
export 'package:flutter_base/utils/network/dio_util.dart';
export 'package:flutter_base/utils/list_util.dart';
export 'package:flutter_base/utils/logger_util.dart';
export 'package:flutter_base/utils/text_util.dart';
export 'package:flutter_base/utils/util.dart';
export 'package:flutter_base/utils/value_util.dart';
export 'package:flutter_base/utils/network/cache_manager.dart';

class Util {
  const Util._();
  static Future<void> LaunchUrl(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }

  /// giturl 加速
  // static Future<dynamic> fetchUrl(String url, List urls, DioUtil network,
  //     {bool reacquire = false, bool vipjx = false}) async {
  //   for (var i = 0; i < urls.length; i++) {
  //     var _url = url;
  //     if (url.contains("raw.githubusercontent.com") || vipjx) {
  //       _url = urls[i] + url;
  //     }
  //     try {
  //       Log.e(_url);
  //       final data = await network.request(_url, reacquire: reacquire);
  //       Log.d("index=$i url=$_url \n data=$data");
  //       return data;
  //     } catch (error) {
  //       Log.e(error.toString());
  //     }
  //   }
  // }

  static Future<dynamic> fetchGithubUrl(String url, List urls, DioUtil network) async {
    for (var i = 0; i < urls.length; i++) {
      var _url = urls[i] + url;
      try {
        final data = await network.request(_url, reacquire: true);
        Log.d("index=$i url=$_url \n data=$data");
        return data;
      } catch (error) {
        Log.e(error.toString());
      }
    }
  }

  /// giturl 加速
  static Future<dynamic> fetchVipJx(String url, List urls, DioUtil network) async {
    for (var i = 0; i < urls.length; i++) {
      var _url = urls[i] + url;
      try {
        Log.e(_url);
        final data = await network.request(_url, reacquire: true);
        Log.d("index=$i url=$_url \n data=$data");
        return jsonDecode(data);
      } catch (error) {
        Log.e(error.toString());
      }
    }
  }

  /// 针对 Dart 字符串优化的 64 位哈希算法 FNV-1a
  static int fastHash(String string) {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }
    return hash;
  }
}

/// 内容基础加密/解密转换
///
/// [value] 内容
class ValueConvert {
  ValueConvert(this.value);
  String value;
  String encode() => base64Encode(utf8.encode(value));
  String decode() => utf8.decode(base64Decode(value));
}
