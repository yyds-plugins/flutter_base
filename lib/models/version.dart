import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/util.dart';
import 'app.dart';

part 'version.g.dart';

@JsonSerializable()
@CopyWith()
@collection
@Name("version")
class Version {
  int get id => Util.fastHash('version');
  final String name; //App名称
  final String title; //更新标题
  final String msg; //
  final String url; // 更新url

  final String testFlight; //
  final String md; //
  final List<App> apps; //
  final String version; //版本号
  final String build; //build版本 最新版本
  final String b2v; //本地v版本号
  final String b2; //本地build版本
  final String platform; //
  final bool isMode; //
  final List<String> vipjx; // vip视频解析 Url
  final List<String> githubs; //

  final String sourceUrl; //



  final DateTime? updateAt; // 更新时间
  final DateTime? createAt; // 创建时间

  Version({
    this.name = '',
    this.title = '',
    this.msg = '',
    this.url = '',
    this.testFlight = '',
    this.md = '',
    this.apps = const [],
    this.version = '',
    this.build = '',
    this.b2v = '',
    this.b2 = '',
    this.platform = '',
    this.isMode = false,
    this.githubs = const [],
    this.sourceUrl = "",
    this.vipjx = const [],
    DateTime? createAt,
    DateTime? updateAt,
  })  : createAt = createAt ?? DateTime.now(),
        updateAt = updateAt ?? DateTime.now();

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

  String get fileName {
    String fileName = "$name$version($build).apk'"; // 设定下载文件的名称
    return fileName;
  }

  factory Version.fromJson(Map<String, dynamic> json) => _$VersionFromJson(json);
  Map<String, dynamic> toJson() => _$VersionToJson(this);
}
