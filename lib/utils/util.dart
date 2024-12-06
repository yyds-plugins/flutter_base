import 'dart:convert';

import 'package:cached_network/cached_network.dart';
import 'package:url_launcher/url_launcher.dart';

import 'logger_util.dart';

export 'package:flutter_base/utils/chore.dart';
export 'package:flutter_base/utils/date_util.dart';
export 'package:flutter_base/utils/dio_util.dart';
export 'package:flutter_base/utils/list_util.dart';
// export 'package:flutter_base/utils/log_toast.dart';
export 'package:flutter_base/utils/logger_util.dart';
export 'package:flutter_base/utils/network/dio_net.dart';
export 'package:flutter_base/utils/permission_engine.dart';
export 'package:flutter_base/utils/text_util.dart';
export 'package:flutter_base/utils/util.dart';
export 'package:flutter_base/utils/value_util.dart';

class Util {
  const Util._();
  static Future<void> LaunchUrl(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }

  /// 获取视频 Url
  static Future<dynamic?> fetchUrl(String url, List urls, CachedNetwork network, {bool reacquire = false}) async {
    for (var i = 0; i < urls.length; i++) {
      final _url = urls[i] + url;
      try {
        final data = await network.request(_url, reacquire: reacquire);
        final json = jsonDecode(data);
        Log.d("index=$i url=$_url");
        return json;
      } catch (error) {
        Log.d(error.toString());
      }
    }
  }

  static Future<String?> fetchM3uUrl(String url, List urls, CachedNetwork network, {bool reacquire = false}) async {
    for (var i = 0; i < urls.length; i++) {
      var _url =  url;
      if(url.contains("raw.githubusercontent.com")){
         _url = urls[i] + url;
      }
      try {
        final data = await network.request(_url, reacquire: reacquire);
        Log.d("index=$i url=$_url");
        return data;
      } catch (error) {
        Log.d(error.toString());
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
