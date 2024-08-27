import 'package:fl_umeng_apm/fl_umeng_apm.dart';
import 'package:flutter_base/util/logger_util.dart';

class FlutterUMeng {
  /// 初始化
  static Future<void> initSDK({String androidAppKey = '', String iosAppKey = '', String channel = ''}) async {
    /// 注册友盟 统计 性能检测
    final bool data = await FlUMeng().init(androidAppKey: androidAppKey, iosAppKey: iosAppKey, channel: channel);
    Log.d('UMeng 初始化成功 = $data');

    /// 注册友盟性能监测
    final bool dataAPM = await FlUMengAPM().init();
    Log.d('FlUMengAPM 初始化成功 = $dataAPM');
  }
}
