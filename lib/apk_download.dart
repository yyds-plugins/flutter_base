library apk_download;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network/cached_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/utils/util.dart';
import 'package:flutter_base/widget/update_dialog/update_dialog.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:html_parser_plus/html_parser_plus.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'models/version.dart';

class ApkDownload {
  static UpdateDialog? dialog;
  static double progress = 0.0;

  static Future<String> _getFilePath(String fileName) async {
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

    var path = '$docPath$fileName';
    ;
    if (kDebugMode) {
      Log.e(path);
    }
    return path;
  }

  //有新版本更新
  static void onUpdateApk(BuildContext context, Version version) async {
    if (!version.isNew) return; //暂无更新
    String savePath = await _getFilePath(version.fileName); // 获取存储在本地的路径
    if (!context.mounted) return;
    showUpdateDialog(context, version, savePath, onDownloadApk: (savePath) async {
      installPlugin(savePath);
    });
  }

  ///检查更新
  static void checkUpdateApk(BuildContext context, Version version) async {
    if (!version.isNew) return; //暂无更新
    String savePath = await _getFilePath(version.fileName); // 获取存储在本地的路径
    final bool isFile = await isFileExists(savePath);
    if (isFile) {
      installPlugin(savePath);
    } else {
      if (!context.mounted && !version.isMode) return;
      showUpdateDialog(context, version, savePath, onDownloadApk: (savePath) async {
        installPlugin(savePath);
      });
    }
  }

  // 分享 APK
  static void onShareApk(BuildContext context, Version version) async {
    String savePath = await _getFilePath(version.fileName); // 获取存储在本地的路径
    final bool isFile = await isFileExists(savePath);
    Log.d('savePath=$savePath isFile=$isFile');

    if (isFile) {
      Share.shareXFiles([XFile(savePath)]);
    } else {
      if (!context.mounted) return;
      showUpdateDialog(context, version, savePath, onDownloadApk: (savePath) async {
        Share.shareXFiles([XFile(savePath)]);
      });
    }
  }

  /// 更新弹窗
  static void showUpdateDialog(BuildContext context, Version version, String apkPath, {required void Function(String) onDownloadApk}) {
    if (dialog != null && dialog!.isShowing()) return;
    final cancelToken = CancelToken();

    final isMode = version.isMode;

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
        isForce: isMode, // 是否是强制更新
        updateButtonText: '下载',
        ignoreButtonText: '忽略此版本',
        enableIgnore: !isMode, //可忽略更新
        onIgnore: () {
      Log.d('onIgnore');
      cancelToken.cancel('cancelled');
      dialog!.dismiss();
    }, onUpdate: () async {
      await Util.LaunchUrl(version.url);

      // if (Platform.isAndroid) {
      //   var url = await apkFileUrl(version);
      //   Log.d('version.url=$url');
      //   String savePath = await _getFilePath(version.fileName); // 获取存储在本地的路径
      //   final req = await downloadApk(url, savePath, cancelToken);
      //   onDownloadApk(req);
      // } else {
      //   await Util.LaunchUrl(version.url);
      // }
    }, onClose: () {
      Log.d('onClose');
      cancelToken.cancel('cancelled');
      dialog!.dismiss();
    });
  }

  //  网络上下载apk
  static Future<String> downloadApk(String url, String savePath, CancelToken cancelToken) async {
    try {
      SmartDialog.showToast('开始下载...');

      var response = await Dio().download(url, savePath, cancelToken: cancelToken, onReceiveProgress: (count, total) {
        Log.d("count  $count total=$total");
        final value = count / total;
        if (progress != value) {
          if (progress < 1.0) {
            progress = count / total;
          } else {
            progress = 0.0;
          }
          dialog!.update(progress);
          Log.d("${(progress * 100).toStringAsFixed(2)}%");
        }
      });
      Log.d("Response  ${response.data}");
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
    Log.d("install apk ${res['isSuccess'] == true ? 'success' : 'fail:${res['errorMessage'] ?? ''}'}");
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

  static Future<String> apkFileUrl(Version version) async {
    final network = CachedNetwork();
    try {
      Log.d("直接嗅探 URL=${version.url}");
      return await jxApkUrl(version.url);
    } catch (error) {
      Log.d(error.toString());
      for (var i = 0; i < version.jxs.length; i++) {
        final _url = version.jxs[i] + version.url;
        Log.d('jxs=$i url=$_url');
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
          Log.d(error.toString());
        }
      }
    }
    return '';
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

    Log.d('嗅探初始化 $url');
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
        Log.d('File html: $html');

        final parser = HtmlParser();
        var item = parser.parse(html);
        final name = parser.query(item, '//div[@class=\'appname\']@text');
        Log.d('--->>>items name>>>${name}');

        // Extract the values of 'var link =' and 'var urlpt ='
        RegExp linkRegex = RegExp(r"var link = '(.*?)';");
        RegExp urlptRegex = RegExp(r"var urlpt = '(.*?)';");

        Match? linkMatch = linkRegex.firstMatch(html);
        Match? urlptMatch = urlptRegex.firstMatch(html);

        if (linkMatch != null && urlptMatch != null) {
          String linkValue = linkMatch.group(1) ?? '';
          String urlptValue = urlptMatch.group(1) ?? '';
          Log.d('Urlpt value: ${urlptValue + linkValue}');

          _handleResult(urlptValue + linkValue, tag: 'onLoadStop');
        } else {
          _handleResult('', tag: 'onLoadStop');
        }
      },
    );

    await headlessWebView.run();
    Log.d('webView.run()');

    return await completer.future;
  }
}
