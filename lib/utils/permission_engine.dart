import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_alert_dialog/models/alert_dialog_text.dart';
import 'package:smart_alert_dialog/smart_alert_dialog.dart';

import 'logger_util.dart';

/**
 * 动态权限的申请与校验
 */
class PermissionEngine {
  // 私有构造函数
  PermissionEngine._privateConstructor();

  // 单例实例
  static final PermissionEngine _instance = PermissionEngine._privateConstructor();

  // 获取单例实例的访问点
  factory PermissionEngine() {
    return _instance;
  }

  /// 申请多媒体相册权限
  void requestPhotosPermission(void Function() success) async {
    //相册的选项
    if (Platform.isIOS) {
      //申请授权
      // final value = await PhotoManager.requestPermissionExtend();
      // if (value.hasAccess) {
      //   //已授权
      //   Log.d("相册已授权");
      //   success();
      // } else if (value == PermissionState.limited) {
      //   Log.d("相册访问受限，去设置受限");
      //   PhotoManager.presentLimited();
      // } else {
      //   Log.d("相册无授权，去设置");
      //
      //   await AppDefaultDialog(context, "无相册权限，前往设置", title: "提醒", confirmText: "去设置", confirmAction: () {
      //     openAppSettings();
      //   });
      // }
    } else {
      //Android是否有SD卡权限
      var status = await Permission.storage.status;
      late PermissionStatus ps;
      if (status.isGranted) {
        // 已经授权
        success();
      } else {
        // 未授权，则准备发起一次申请

        var permissionRequestFuture = Permission.photos.request();
        // 延迟500毫秒的Future
        var delayFuture = Future.delayed(Duration(milliseconds: 500), () => 'delay');

        // 使用Future.any等待上述两个Future中的任何一个完成
        var firstCompleted = await Future.any([permissionRequestFuture, delayFuture]);

        // 判断响应结果
        if (firstCompleted == 'delay') {
          Log.d("判断响应结果:1");
          // 如果是延迟Future完成了，表示500毫秒内没有获得权限响应，显示对话框
          _showPermissionDialog("“Newki爱学习”想访问你的多媒体相册 用于图片上传，图片保存等功能，请允许我获取您的权限");
          // 再次等待权限请求结果
          ps = await permissionRequestFuture;
          SmartDialog.dismiss(tag: "permission");
        } else {
          Log.d("判断响应结果:2");
          // 权限请求已完成，立刻取消对话框展示（如果已经展示的话）
          SmartDialog.dismiss(tag: "permission");
          ps = firstCompleted as PermissionStatus;
        }

        if (ps.isGranted) {
          // 用户授权
          success();
        } else {
          // 权限被拒绝
          await AppDefaultDialog("请到您的手机设置打开相册的权限", title: "提醒", confirmText: "去设置", confirmAction: () {
            openAppSettings();
          });
        }
      }
    }
  }

  /// 申请相机权限
  void requestCameraPermission(void Function() success) async {
    // 获取当前的权限
    var status = await Permission.camera.status;
    if (status.isGranted) {
      // 已经授权
      success();
    } else {
      // 未授权，则准备发起一次申请
      var permissionRequestFuture = Permission.camera.request();

      // 延迟500毫秒的Future
      var delayFuture = Future.delayed(Duration(milliseconds: 500), () => 'delay');

      // 使用Future.any等待上述两个Future中的任何一个完成
      var firstCompleted = await Future.any([permissionRequestFuture, delayFuture]);

      // 判断响应结果
      if (firstCompleted == 'delay') {
        // 如果是延迟Future完成了，表示500毫秒内没有获得权限响应，显示对话框
        _showPermissionDialog("“Newki爱学习”申请调用您的相机权限 用于使用拍摄头像，图片上传保存等功能，请允许我获取您的权限");
        // 再次等待权限请求结果
        status = await permissionRequestFuture;
        SmartDialog.dismiss(tag: "permission");
      } else {
        // 权限请求已完成，立刻取消对话框展示（如果已经展示的话）
        SmartDialog.dismiss(tag: "permission");
        status = firstCompleted as PermissionStatus;
      }

      if (status.isGranted) {
        // 用户授权
        success();
      } else {
        // 权限被拒绝
        await AppDefaultDialog("请到您的手机设置打开相机的权限", title: "提醒", confirmText: "去设置", confirmAction: () {
          openAppSettings();
        });
      }
    }
  }

  /// 校验并申请定位权限
  Future<bool> requestLocationPermission(BuildContext context) async {
    // 获取当前的权限
    var status = await Permission.location.status;
    if (status.isGranted) {
      // 已经授权
      return true;
    } else {
      // 未授权，则准备发起一次申请
      var permissionRequestFuture = Permission.location.request();

      // 延迟500毫秒的Future
      var delayFuture = Future.delayed(Duration(milliseconds: 500), () => 'delay');

      // 使用Future.any等待上述两个Future中的任何一个完成
      var firstCompleted = await Future.any([permissionRequestFuture, delayFuture]);

      // 判断响应结果
      if (firstCompleted == 'delay') {
        // 如果是延迟Future完成了，表示500毫秒内没有获得权限响应，显示对话框
        _showPermissionDialog("“Newki爱学习”想访问您的定位权限获取您的位置来推荐附近的工作");
        // 再次等待权限请求结果
        status = await permissionRequestFuture;
        SmartDialog.dismiss(tag: "permission");
      } else {
        Log.d("权限请求已完成,立刻取消对话框展示");
        // 权限请求已完成，立刻取消对话框展示（如果已经展示的话）
        SmartDialog.dismiss(tag: "permission");
        status = firstCompleted as PermissionStatus;
      }

      if (status.isGranted) {
        // 用户授权
        return true;
      } else {
        // 权限被拒绝
        await AppDefaultDialog("请到您的手机设置打开定位的权限", title: "提醒", confirmText: "去设置", confirmAction: () {
          openAppSettings();
        });
        return false;
      }
    }
  }

  /// 广告追踪权限
  Future<bool> requestAppTrackingTransparencyPermission() async {
    // 获取当前的权限
    var status = await Permission.appTrackingTransparency.status;
    if (status.isGranted) {
      // 已经授权
      return true;
    } else {
      // 未授权，则准备发起一次申请
      var permissionRequestFuture = Permission.appTrackingTransparency.request();

      // 延迟500毫秒的Future
      var delayFuture = Future.delayed(Duration(milliseconds: 500), () => 'delay');

      // 使用Future.any等待上述两个Future中的任何一个完成
      var firstCompleted = await Future.any([permissionRequestFuture, delayFuture]);

      // 判断响应结果
      if (firstCompleted == 'delay') {
        // 如果是延迟Future完成了，表示500毫秒内没有获得权限响应，显示对话框
        // 再次等待权限请求结果
        status = await permissionRequestFuture;
      } else {
        Log.d("权限请求已完成,立刻取消对话框展示");
        // 权限请求已完成，立刻取消对话框展示（如果已经展示的话）
        status = firstCompleted as PermissionStatus;
      }
      if (status.isGranted) {
        // 用户授权
        return true;
      } else {
        // 权限被拒绝
        return false;
      }
    }
  }

  Future<void> AppDefaultDialog(String des, {required String title, required String confirmText, void Function()? confirmAction}) async {
    SmartDialog.show(
      clickMaskDismiss: false,
      backDismiss: true,
      tag: "permission",
      maskColor: Colors.transparent,
      builder: (c) => SmartAlertDialog(
        title: title,
        text: AlertDialogText(confirm: confirmText, cancel: '取消', dismiss: '确定'),
        message: des,
        onConfirmPressed: () => confirmAction,
        onCancelPressed: () => SmartDialog.dismiss,
      ),
    );

    // await showCupertinoDialog(
    //     context: context,
    //     builder: (context) {
    //       return CupertinoAlertDialog(
    //         title: Text(title),
    //         content: Text(des),
    //         actions: <Widget>[
    //           CupertinoDialogAction(
    //             onPressed: () {
    //               Navigator.pop(context);
    //             },
    //             child: const Text('取消'),
    //           ),
    //           CupertinoDialogAction(
    //             onPressed: confirmAction,
    //             child: Text(confirmText),
    //           ),
    //         ],
    //       );
    //     });
  }

  Future<bool> checkConnectivity() async {
    Completer<bool> completer = Completer();
    StreamSubscription<List<ConnectivityResult>> subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      // Received changes in available connectivity types!
      if (result != ConnectivityResult.none) {
        if (!completer.isCompleted) completer.complete(true);
      }
      // This condition is for demo purposes only to explain every connection type.
      // Use conditions which work for your requirements.
      if (result.contains(ConnectivityResult.mobile)) {
        // Mobile network available.
        debugPrint('ConnectivityResult.mobile');
      } else if (result.contains(ConnectivityResult.wifi)) {
        // Wi-fi is available.
        // Note for Android:
        // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
        debugPrint('ConnectivityResult.wifi');
      } else if (result.contains(ConnectivityResult.ethernet)) {
        // Ethernet connection available.
        debugPrint('ConnectivityResult.ethernet');
      } else if (result.contains(ConnectivityResult.vpn)) {
        // Vpn connection active.
        // Note for iOS and macOS:
        // There is no separate network interface type for [vpn].
        // It returns [other] on any device (also simulator)
        debugPrint('ConnectivityResult.vpn');
      } else if (result.contains(ConnectivityResult.bluetooth)) {
        // Bluetooth connection available.
        debugPrint('ConnectivityResult.bluetooth');
      } else if (result.contains(ConnectivityResult.other)) {
        // Connected to a network which is not in the above mentioned networks.
        debugPrint('ConnectivityResult.other');
      } else if (result.contains(ConnectivityResult.none)) {
        // No available network types
        debugPrint('ConnectivityResult.none');
      }
    });
    return await completer.future;
  }

  //顶部展示权限声明详情弹窗
  void _showPermissionDialog(String desc) {
    SmartDialog.show(
      clickMaskDismiss: false,
      backDismiss: true,
      tag: "permission",
      maskColor: Colors.transparent,
      builder: (c) => SmartAlertDialog(
        title: "Are you liking it?",
        text: AlertDialogText(),
        message: desc,
        onConfirmPressed: () => print("do something on confirm"),
        onCancelPressed: () => print("do something on cancel"),
      ),
    );
  }
}
