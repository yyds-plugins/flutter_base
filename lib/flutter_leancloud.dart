library flutter_leancloud;

import 'dart:convert';

import 'package:cached_network/cached_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'models/app.dart';
import 'models/version.dart';

class FlutterLeanCloud {
  static Future<Version> getVersion(String objectId) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      LCQuery<LCObject> query = LCQuery('version');
      final value = await query.get(objectId);
      debugPrint('LC value=$value');
      final version = Version.fromJson(json.decode(value.toString())).copyWith(b2v: packageInfo.version, b2: packageInfo.buildNumber);
      return version;
    } catch (error) {
      debugPrint(error.toString());
      return Version();
    }

    // final setting = ref.read(settingNotifierProvider);
    // final duration = Duration(hours: setting.cacheDuration.floor());
    // final timeout = Duration(milliseconds: setting.timeout);
    // final temporaryDirectory = await getTemporaryDirectory();
    // final network = CachedNetwork(temporaryDirectory: temporaryDirectory, timeout: timeout);
    // final packageInfo = await ref.read(packageInfoNotifierProvider.future);
    //
    // DateTime now = DateTime.now();
    // int timestamp = now.microsecondsSinceEpoch;
    // final url = 'https://raw.githubusercontent.com/yyds-m/movie/main/jsons/flutter_v_updater.json?t=$timestamp';
    // debugPrint('request url=${url}');
    // final data = await network.request(url, duration: duration);
    // Map<String, dynamic> json = jsonDecode(data);
    // var version = Version.fromJson(json).copyWith(b2: packageInfo.buildNumber);
    // debugPrint('Github Version=${version.toJson()}');
    // var lanz = JhEncryptUtils.aesEncrypt(version.lanz);
    // var helpUrl = JhEncryptUtils.aesEncrypt(version.helpUrl);
    //
    // debugPrint('加密后的：lanz=${lanz}');
    // debugPrint('加密后的：helpUrl=${helpUrl}');
    //
    // var _lanz = JhEncryptUtils.aesDecrypt(lanz);
    // var _helpUrl = JhEncryptUtils.aesDecrypt(helpUrl);
    // debugPrint('解密后的：_lanz=${_lanz}');
    // debugPrint('解密后的：_helpUrl=${_helpUrl}');
  }

  static Future<List<App>> appList(Version version) async {
    var data = '';
    final network = CachedNetwork();
    DateTime now = DateTime.now();
    int timestamp = now.microsecondsSinceEpoch;
    final url = '${version.apps}?t=$timestamp';
    try {
      debugPrint(url);
      data = await network.request(url, reacquire: true);
    } catch (error) {
      debugPrint(error.toString());
      for (var i = 0; i < version.githubs.length; i++) {
        final _url = version.githubs[i] + url;
        debugPrint('githubs=$i _url=$_url');
        try {
          data = await network.request(_url);
        } catch (error) {
          debugPrint(error.toString());
        }
      }
    }

    final json = jsonDecode(data);
    List<App> apps = [const App(id: 'BannerView')];
    if (json is List) {
      for (var element in json) {
        apps.add(App.fromJson(element));
      }
    } else {
      apps.add(App.fromJson(json));
    }
    return apps;
  }

  static Future<String> md(Version version) async {
    DateTime now = DateTime.now();
    int timestamp = now.microsecondsSinceEpoch;
    final url = '${version.md}?t=$timestamp';

    final network = CachedNetwork();
    try {
      debugPrint(url);
      return await network.request(url, reacquire: true);
    } catch (error) {
      debugPrint(error.toString());
      for (var i = 0; i < version.githubs.length; i++) {
        final _url = version.githubs[i] + url;
        try {
          return await network.request(_url);
        } catch (error) {
          debugPrint(error.toString());
        }
      }
    }
    return '';
  }
}
