// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ResultDataCWProxy {
  ResultData code(int code);

  ResultData list(dynamic list);

  ResultData msg(String msg);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResultData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResultData(...).copyWith(id: 12, name: "My name")
  /// ````
  ResultData call({
    int? code,
    dynamic list,
    String? msg,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfResultData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfResultData.copyWith.fieldName(...)`
class _$ResultDataCWProxyImpl implements _$ResultDataCWProxy {
  const _$ResultDataCWProxyImpl(this._value);

  final ResultData _value;

  @override
  ResultData code(int code) => this(code: code);

  @override
  ResultData list(dynamic list) => this(list: list);

  @override
  ResultData msg(String msg) => this(msg: msg);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResultData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResultData(...).copyWith(id: 12, name: "My name")
  /// ````
  ResultData call({
    Object? code = const $CopyWithPlaceholder(),
    Object? list = const $CopyWithPlaceholder(),
    Object? msg = const $CopyWithPlaceholder(),
  }) {
    return ResultData(
      code: code == const $CopyWithPlaceholder() || code == null
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as int,
      list: list == const $CopyWithPlaceholder() || list == null
          ? _value.list
          // ignore: cast_nullable_to_non_nullable
          : list as dynamic,
      msg: msg == const $CopyWithPlaceholder() || msg == null
          ? _value.msg
          // ignore: cast_nullable_to_non_nullable
          : msg as String,
    );
  }
}

extension $ResultDataCopyWith on ResultData {
  /// Returns a callable class that can be used as follows: `instanceOfResultData.copyWith(...)` or like so:`instanceOfResultData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ResultDataCWProxy get copyWith => _$ResultDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultData _$ResultDataFromJson(Map<String, dynamic> json) => ResultData(
      code: (json['code'] as num?)?.toInt() ?? 0,
      list: json['list'],
      msg: json['msg'] as String? ?? '',
    );

Map<String, dynamic> _$ResultDataToJson(ResultData instance) =>
    <String, dynamic>{
      'code': instance.code,
      if (instance.list case final value?) 'list': value,
      'msg': instance.msg,
    };
