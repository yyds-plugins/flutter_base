import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'result_data.g.dart';

@JsonSerializable(includeIfNull: false)
@CopyWith()
class ResultData {
  final int code;
  final dynamic list;
  final String msg;

  ResultData({
    this.code = 0,
    this.list,
    this.msg = '',
  });

  factory ResultData.fromJson(Map<String, dynamic> json) => _$ResultDataFromJson(json);
  Map<String, dynamic> toJson() => _$ResultDataToJson(this);
}
