// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AppCWProxy {
  App id(String id);

  App url(String url);

  App name(String name);

  App description(String description);

  App iconUrl(String iconUrl);

  App packageName(String packageName);

  App bundleId(String bundleId);

  App urlScheme(String urlScheme);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `App(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// App(...).copyWith(id: 12, name: "My name")
  /// ````
  App call({
    String? id,
    String? url,
    String? name,
    String? description,
    String? iconUrl,
    String? packageName,
    String? bundleId,
    String? urlScheme,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApp.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApp.copyWith.fieldName(...)`
class _$AppCWProxyImpl implements _$AppCWProxy {
  const _$AppCWProxyImpl(this._value);

  final App _value;

  @override
  App id(String id) => this(id: id);

  @override
  App url(String url) => this(url: url);

  @override
  App name(String name) => this(name: name);

  @override
  App description(String description) => this(description: description);

  @override
  App iconUrl(String iconUrl) => this(iconUrl: iconUrl);

  @override
  App packageName(String packageName) => this(packageName: packageName);

  @override
  App bundleId(String bundleId) => this(bundleId: bundleId);

  @override
  App urlScheme(String urlScheme) => this(urlScheme: urlScheme);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `App(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// App(...).copyWith(id: 12, name: "My name")
  /// ````
  App call({
    Object? id = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? iconUrl = const $CopyWithPlaceholder(),
    Object? packageName = const $CopyWithPlaceholder(),
    Object? bundleId = const $CopyWithPlaceholder(),
    Object? urlScheme = const $CopyWithPlaceholder(),
  }) {
    return App(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      description:
          description == const $CopyWithPlaceholder() || description == null
              ? _value.description
              // ignore: cast_nullable_to_non_nullable
              : description as String,
      iconUrl: iconUrl == const $CopyWithPlaceholder() || iconUrl == null
          ? _value.iconUrl
          // ignore: cast_nullable_to_non_nullable
          : iconUrl as String,
      packageName:
          packageName == const $CopyWithPlaceholder() || packageName == null
              ? _value.packageName
              // ignore: cast_nullable_to_non_nullable
              : packageName as String,
      bundleId: bundleId == const $CopyWithPlaceholder() || bundleId == null
          ? _value.bundleId
          // ignore: cast_nullable_to_non_nullable
          : bundleId as String,
      urlScheme: urlScheme == const $CopyWithPlaceholder() || urlScheme == null
          ? _value.urlScheme
          // ignore: cast_nullable_to_non_nullable
          : urlScheme as String,
    );
  }
}

extension $AppCopyWith on App {
  /// Returns a callable class that can be used as follows: `instanceOfApp.copyWith(...)` or like so:`instanceOfApp.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AppCWProxy get copyWith => _$AppCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

App _$AppFromJson(Map<String, dynamic> json) => App(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      bundleId: json['bundleId'] as String? ?? '',
      urlScheme: json['urlScheme'] as String? ?? '',
    );

Map<String, dynamic> _$AppToJson(App instance) => <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'packageName': instance.packageName,
      'bundleId': instance.bundleId,
      'urlScheme': instance.urlScheme,
    };
