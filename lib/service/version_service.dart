library leancloud_storage;

import 'dart:convert';

import 'package:cached_network/cached_network.dart';
import 'package:flutter_base/utils/logger_util.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/app.dart';
import '../models/version.dart';

class VersionService {
  factory VersionService() => _instance ??= VersionService._();

  static VersionService? _instance;

  VersionService._();

  static Future<Version> fetchVersion(String objectId) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      LCQuery<LCObject> query = LCQuery('version');
      final value = await query.get(objectId);
      final version = Version.fromJson(json.decode(value.toString())).copyWith(b2v: packageInfo.version, b2: packageInfo.buildNumber);
      return version;
    } catch (error) {
      Log.d(error.toString());
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
    // Log.d('request url=${url}');
    // final data = await network.request(url, duration: duration);
    // Map<String, dynamic> json = jsonDecode(data);
    // var version = Version.fromJson(json).copyWith(b2: packageInfo.buildNumber);
    // Log.d('Github Version=${version.toJson()}');
    // var lanz = JhEncryptUtils.aesEncrypt(version.lanz);
    // var helpUrl = JhEncryptUtils.aesEncrypt(version.helpUrl);
    //
    // Log.d('加密后的：lanz=${lanz}');
    // Log.d('加密后的：helpUrl=${helpUrl}');
    //
    // var _lanz = JhEncryptUtils.aesDecrypt(lanz);
    // var _helpUrl = JhEncryptUtils.aesDecrypt(helpUrl);
    // Log.d('解密后的：_lanz=${_lanz}');
    // Log.d('解密后的：_helpUrl=${_helpUrl}');
  }

  static Future<List<App>> fetchAppList(
    Version version,
    CachedNetwork network,
  ) async {
    var data = '';
    try {
      Log.d(version.apps);
      data = await network.request(version.apps, reacquire: true);
    } catch (error) {
      Log.d(error.toString());
      Log.d('githubs=${version.githubs}');

      for (var i = 0; i < version.githubs.length; i++) {
        final _url = version.githubs[i] + version.apps;
        Log.d('githubs=$i _url=$_url');
        try {
          data = await network.request(_url,reacquire: true);
        } catch (error) {
          Log.d(error.toString());
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

  static Future<String> fetchMd(
    Version version,
    CachedNetwork network,
  ) async {
    try {
      return await network.request(version.md, reacquire: true);
    } catch (error) {
      Log.d(error.toString());
      for (var i = 0; i < version.githubs.length; i++) {
        DateTime now = DateTime.now();
        int timestamp = now.microsecondsSinceEpoch;
        final _url = version.githubs[i] + version.md;

        try {
          return await network.request(_url,reacquire: true);
        } catch (error) {
          Log.d(error.toString());
        }
      }
    }
    return '';
  }
}
