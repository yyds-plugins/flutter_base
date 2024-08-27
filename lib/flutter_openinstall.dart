import 'package:flutter/cupertino.dart';
import 'package:flutter_base/util/logger_util.dart';
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
    Log.d("installHandler : $data");
    installLog = "install result : channel=${data['channelCode']}, data=${data['bindData']}\n${data['shouldRetry']}";
    Log.d("installLog : $installLog");
  }

  static Future<void> wakeupHandler(Map<String, Object> data) async {
    Log.d("wakeupHandler : $data");
    wakeUpLog = "wakeup result : channel=${data['channelCode']}, data=${data['bindData']}\n";
    Log.d("wakeUpLog : $wakeUpLog");
  }
}
