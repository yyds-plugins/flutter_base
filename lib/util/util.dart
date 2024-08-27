import 'package:url_launcher/url_launcher.dart';

class Util {
  const Util._();
  static Future<void> LaunchUrl(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }
}
