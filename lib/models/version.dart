import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'version.g.dart';

@JsonSerializable()
@CopyWith()
class Version {
  final String name; //App名称
  final String title; //更新标题
  final String msg; //
  final String url; // 更新url
  final List<String> jxs; // apk解析 Url
  final String testFlight; //
  final String md; //
  final String apps; //
  final String version; //版本号
  final String build; //build版本 最新版本
  final String b2v; //本地v版本号
  final String b2; //本地build版本
  final String platform; //
  final bool isMode; //
  final String feedUrl; // 订阅 url
  final String sourceUrl; // 订阅 url
  final List<String> githubs; //

  Version({
    this.name = '',
    this.title = '',
    this.msg = '',
    this.url = '',
    this.jxs = const [],
    this.testFlight = '',
    this.md = '',
    this.apps = '',
    this.version = '',
    this.build = '',
    this.b2v = '',
    this.b2 = '',
    this.platform = '',
    this.isMode = false,
    this.feedUrl = '',
    this.sourceUrl = '',
    this.githubs = const [],
  });

  bool get isNew {
    if (build.isEmpty) return false;
    var newList = build.split('.');
    var oldList = b2.split('.');
    if (newList.isEmpty || oldList.isEmpty) return false;
    var isNew = false;
    for (int i = 0; i < newList.length; i++) {
      int newVersion = int.parse(newList[i]);
      int oldVersion = int.parse(oldList[i]);
      if (newVersion > oldVersion) {
        isNew = true;
      } else if (newVersion < oldVersion) {
        isNew = false;
      }
    }
    return isNew;
  }

  factory Version.fromJson(Map<String, dynamic> json) => _$VersionFromJson(json);
  Map<String, dynamic> toJson() => _$VersionToJson(this);
}
