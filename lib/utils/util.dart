import 'package:url_launcher/url_launcher.dart';

export 'package:flutter_base/utils/chore.dart';
export 'package:flutter_base/utils/log_toast.dart';
export 'package:flutter_base/utils/logger_util.dart';
export 'package:flutter_base/utils/permission_engine.dart';
export 'package:flutter_base/utils/time_parser.dart';
export 'package:flutter_base/utils/util.dart';
export 'package:flutter_base/utils/value_util.dart';

class Util {
  const Util._();
  static Future<void> LaunchUrl(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }
}
