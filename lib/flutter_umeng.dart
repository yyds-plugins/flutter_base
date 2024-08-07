import 'package:fl_umeng_apm/fl_umeng_apm.dart';
import 'package:flutter/cupertino.dart';

class FlutterUMeng {
  /// 初始化
  static Future<void> initSDK({String androidAppKey = '', String iosAppKey = '', String channel = ''}) async {
    /// 注册友盟 统计 性能检测
    final bool data = await FlUMeng().init(androidAppKey: androidAppKey, iosAppKey: iosAppKey, channel: channel);
    debugPrint('UMeng 初始化成功 = $data');

    /// 注册友盟性能监测
    final bool dataAPM = await FlUMengAPM().init();
    debugPrint('FlUMengAPM 初始化成功 = $dataAPM');
  }
}
