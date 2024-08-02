import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network/cached_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:html_parser_plus/html_parser_plus.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import '../flutter_leancloud.dart';
import '../models/app.dart';
import '../models/version.dart';
import '../widget/update_dialog/update_dialog.dart';

part 'version.g.dart';

@riverpod
class ApkFileUrl extends _$ApkFileUrl {
  static UpdateDialog? dialog;
  static double progress = 0.0;
  static String loadFilePath = '';

  @override
  Future<Version> build() async {
    var version = await ref.read(versionNotifierProvider.future);
    loadFilePath = '${await getFilePath()}flutter_v${version.version}(${version.build}).apk';

    return version;
  }

  Future<String?> getFilePath() async {
    String? docPath;
    if (Platform.isAndroid) {
      docPath = "/storage/emulated/0/Download/";
      Directory dir = Directory(docPath);
      try {
        dir.listSync();
      } catch (e) {
        // 一些系统没有权限
        docPath = (await getExternalStorageDirectory())?.path;
        docPath = '$docPath/';
      }
    } else {
      docPath = (await getTemporaryDirectory()).path;
      docPath = docPath.replaceFirst("Library/Caches", "Documents/");
    }
    return docPath;
  }

  Future<String> apkFileUrl(String url) async {
    final network = CachedNetwork();
    try {
      debugPrint("直接嗅探 URL=$url");
      return await jxApkUrl(url);
    } catch (error) {
      debugPrint(error.toString());
      final version = await ref.read(versionNotifierProvider.future);
      for (var i = 0; i < version.jxs.length; i++) {
        final _url = version.jxs[i] + version.url;
        debugPrint('jxs=$i url=$_url');
        try {
          var html = await network.request(version.url);
          Map<String, dynamic> json = jsonDecode(html);
          if (int.parse(json['code']) == 200) {
            if (json['data'] != null) {
              return json['data']['url'];
            }
            if (json['down'] != null) {
              return json['down'];
            }
          }
        } catch (error) {
          debugPrint(error.toString());
        }
      }
    }
    return '';
  }

  //有新版本更新
  void onUpdateApk(BuildContext context) async {
    final version = await future;
    if (!version.isNew) return; //暂无更新
    if (!context.mounted) return;
    showUpdateDialog(context, version, onDownloadApk: (savePath) async {
      installPlugin(savePath);
    });
  }

  ///检查更新
  void checkUpdateApk(BuildContext context) async {
    final version = await future;
    if (!version.isNew) return; //暂无更新
    final bool isFile = await isFileExists(loadFilePath);
    if (isFile) {
      installPlugin(loadFilePath);
    } else {
      if (!context.mounted && !version.isMode) return;
      showUpdateDialog(context, version, onDownloadApk: (savePath) async {
        installPlugin(savePath);
      });
    }
  }

  // 分享 APK
  void onShareApk(BuildContext context) async {
    final version = await future;
    debugPrint(loadFilePath);
    final bool isFile = await isFileExists(loadFilePath);
    if (isFile) {
      Share.shareXFiles([XFile(loadFilePath)]);
    } else {
      if (!context.mounted) return;
      showUpdateDialog(context, version, onDownloadApk: (savePath) async {
        Share.shareXFiles([XFile(savePath)]);
      });
    }
  }

  /// 更新弹窗
  void showUpdateDialog(BuildContext context, Version version, {required void Function(String) onDownloadApk}) {
    if (dialog != null && dialog!.isShowing()) return;
    final cancelToken = CancelToken();
    dialog = UpdateDialog.showUpdate(context,
        width: 300,
        title: version.title,
        updateContent: version.msg,
        titleTextSize: 17,
        contentTextSize: 14,
        buttonTextSize: 14,
        extraHeight: 5,
        radius: 8,
        themeColor: Colors.red,
        progressBackgroundColor: const Color(0x5AFFAC5D),
        isForce: version.isMode, // 是否是强制更新
        updateButtonText: '下载',
        ignoreButtonText: '忽略此版本',
        enableIgnore: !version.isMode, //可忽略更新
        onIgnore: () {
      debugPrint('onIgnore');
      cancelToken.cancel('cancelled');
      dialog!.dismiss();
    }, onUpdate: () async {
      var url = await apkFileUrl(version.url);
      debugPrint('version.url=$url');
      final req = await downloadApk(url, loadFilePath, cancelToken);
      dialog!.dismiss();
      onDownloadApk(req);
    }, onClose: () {
      debugPrint('onClose');
      cancelToken.cancel('cancelled');
      dialog!.dismiss();
    });
  }

  //  网络上下载apk
  static Future<String> downloadApk(String url, String savePath, CancelToken cancelToken) async {
    try {
      SmartDialog.showToast('开始下载...');
      var response = await Dio().download(url, savePath, cancelToken: cancelToken, onReceiveProgress: (count, total) {
        debugPrint("count  $count total=$total");
        final value = count / total;
        if (progress != value) {
          if (progress < 1.0) {
            progress = count / total;
          } else {
            progress = 0.0;
          }
          dialog!.update(progress);
          debugPrint("${(progress * 100).toStringAsFixed(2)}%");
        }
      });
      debugPrint("Response  ${response.data}");
      SmartDialog.showToast('下载成功！');
      return savePath;
    } on DioException catch (e) {
      print('Download failed with error: $e');
      SmartDialog.showToast('下载失败！');
      return '';
    }
  }

  static installPlugin(String savePath) async {
    final res = await InstallPlugin.install(savePath);
    if (res['isSuccess'] == true) SmartDialog.showToast('安装成功！');
    debugPrint("install apk ${res['isSuccess'] == true ? 'success' : 'fail:${res['errorMessage'] ?? ''}'}");
  }

  ///判断文件存不存在
  static Future<bool> isFileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      // 处理异常情况
      return false;
    }
  }

  //============================================================================
  /// 嗅探视频URL
  static Future<String> jxApkUrl(
    String url,
  ) async {
    Completer<String> completer = Completer();

    late HeadlessInAppWebView headlessWebView;
    InAppWebViewController _webViewController;

    Future<void> _handleResult(String url, {String tag = ''}) async {
      await headlessWebView.dispose();
      if (!completer.isCompleted) completer.complete(url);
    }

    debugPrint('嗅探初始化 $url');
    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(url)),
      // initialSettings: InAppWebViewSettings(isInspectable: kDebugMode),
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
              useOnLoadResource: true, useShouldInterceptAjaxRequest: true, useShouldInterceptFetchRequest: true, useShouldOverrideUrlLoading: true),
          android: AndroidInAppWebViewOptions(useShouldInterceptRequest: true),
          ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true, useOnNavigationResponse: true)),
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },

      onLoadStop: (controller, webUri) async {
        var html = await controller.evaluateJavascript(source: "document.body.innerHTML");
        debugPrint('File html: $html');

        final parser = HtmlParser();
        var item = parser.parse(html);
        final name = parser.query(item, '//div[@class=\'appname\']@text');
        debugPrint('--->>>items name>>>${name}');

        // Extract the values of 'var link =' and 'var urlpt ='
        RegExp linkRegex = RegExp(r"var link = '(.*?)';");
        RegExp urlptRegex = RegExp(r"var urlpt = '(.*?)';");

        Match? linkMatch = linkRegex.firstMatch(html);
        Match? urlptMatch = urlptRegex.firstMatch(html);

        if (linkMatch != null && urlptMatch != null) {
          String linkValue = linkMatch.group(1) ?? '';
          String urlptValue = urlptMatch.group(1) ?? '';
          debugPrint('Urlpt value: ${urlptValue + linkValue}');

          _handleResult(urlptValue + linkValue, tag: 'onLoadStop');
        } else {
          _handleResult('', tag: 'onLoadStop');
        }
      },
    );

    await headlessWebView.run();
    debugPrint('webView.run()');

    return await completer.future;
  }
}

@riverpod
class VersionNotifier extends _$VersionNotifier {
  @override
  Future<Version> build() async {
    final objectId = Platform.isAndroid ? '665d7227df41fa26e2727f5e' : '665d72d1df41fa26e2727f5f';
    return await FlutterLeanCloud.lcBuild(objectId);
  }
}

@riverpod
class Apps extends _$Apps {
  @override
  Future<List<App>> build() async {
    var version = await ref.read(versionNotifierProvider.future);
    return await FlutterLeanCloud.appList(version);
  }
}

@riverpod
class ReadMe extends _$ReadMe {
  @override
  Future<String> build() async {
    final version = await ref.read(versionNotifierProvider.future);
    return await FlutterLeanCloud.md(version);
  }
}
