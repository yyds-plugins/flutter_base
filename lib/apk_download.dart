library apk_download;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network/cached_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  static Future<String> _getFilePath(String filename) async {
    Directory? dir;
    try {
      if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory(); // 针对 iOS
      } else {
        dir = Directory('/storage/emulated/0/Download/'); // 针对 android
        if (!await dir.exists()) dir = (await getExternalStorageDirectory())!;
      }
    } catch (err) {
      print("Cannot get download folder path $err");
    }
    return "${dir?.path}$filename";
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
    debugPrint(savePath);
    final bool isFile = await isFileExists(savePath);
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
      var url = await apkFileUrl(version);
      debugPrint('version.url=$url');
      String savePath = await _getFilePath(version.fileName); // 获取存储在本地的路径
      final req = await downloadApk(url, savePath, cancelToken);
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

  static Future<String> apkFileUrl(Version version) async {
    final network = CachedNetwork();
    try {
      debugPrint("直接嗅探 URL=${version.url}");
      return await jxApkUrl(version.url);
    } catch (error) {
      debugPrint(error.toString());
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
