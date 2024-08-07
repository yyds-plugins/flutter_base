import 'package:flutter/cupertino.dart';
import 'package:openinstall_flutter_plugin/openinstall_flutter_plugin.dart';

class FlutterOpeninstall {
  static String wakeUpLog = "";
  static String installLog = "";
  static final OpeninstallFlutterPlugin _openinstallFlutterPlugin = OpeninstallFlutterPlugin();

  /// 初始化
  static Future<void> initSDK({String channel = ''}) async {
    _openinstallFlutterPlugin.setDebug(true);
    _openinstallFlutterPlugin.init(wakeupHandler);
    _openinstallFlutterPlugin.install(installHandler);
    _openinstallFlutterPlugin.setChannel(channel);
  }

  static Future<void> installHandler(Map<String, Object> data) async {
    debugPrint("installHandler : $data");
    installLog = "install result : channel=${data['channelCode']}, data=${data['bindData']}\n${data['shouldRetry']}";
    debugPrint("installLog : $installLog");
  }

  static Future<void> wakeupHandler(Map<String, Object> data) async {
    debugPrint("wakeupHandler : $data");
    wakeUpLog = "wakeup result : channel=${data['channelCode']}, data=${data['bindData']}\n";
    debugPrint("wakeUpLog : $wakeUpLog");
  }
}
