import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app.g.dart';

@JsonSerializable()
@CopyWith()
class App {
  final String id;
  final String url;
  final String name;
  final String description;
  final String iconUrl;
  final String packageName;
  final String bundleId;
  final String urlScheme;
  const App.a(
    this.id,
    this.url,
    this.name,
    this.description,
    this.iconUrl,
    this.packageName,
    this.bundleId,
    this.urlScheme,
  );
  const App({
    this.id = '',
    this.url = '',
    this.name = '',
    this.description = '',
    this.iconUrl = '',
    this.packageName = '',
    this.bundleId = '',
    this.urlScheme = '',
  });

  factory App.fromJson(Map<String, dynamic> json) => _$AppFromJson(json);
  Map<String, dynamic> toJson() => _$AppToJson(this);
}
