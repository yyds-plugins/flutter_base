library apk_download;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_installer/app_installer.dart';
import 'package:cached_network/cached_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/utils/util.dart';
import 'package:flutter_base/widget/update_dialog/update_dialog.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:html_parser_plus/html_parser_plus.dart';
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
  static void showUpdateDialog(BuildContext context, Version version, String apkPath,
      {required void Function(String) onDownloadApk}) {
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

      var response = await Dio().download(url, savePath, cancelToken: cancelToken,
          onReceiveProgress: (count, total) {
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
    final res = await AppInstaller.installApk(savePath);
    SmartDialog.showToast('安装成功！');
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
}
