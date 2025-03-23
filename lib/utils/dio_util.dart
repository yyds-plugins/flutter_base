import 'dart:convert';
import 'dart:io';
import 'package:charset/charset.dart';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DioUtil {
  DioUtil({this.prefix, this.temporaryDirectory, this.timeout, this.cacheDuration});

  String identifier = 'libCachedNetworkData';
  String? prefix;
  Directory? temporaryDirectory;
  Duration? timeout;
  Duration? cacheDuration;

  /// Use to acquire data from network or the cached file.
  ///
  /// Allowed method is one of [GET, POST].
  /// If method is null, the default method is [GET].
  ///
  /// If duration is null, the file will last forever, or will be reacquired while
  /// duration from file created to now is greater than duration specified in the
  /// param.
  Future<dynamic> request(
    String url, {
    Map<String, dynamic>? body,
    String? charset,
    Duration? duration,
    String? method,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    bool reacquire = false,
  }) async {
    timeout ??= const Duration(seconds: 10);
    duration ??= cacheDuration;
    String cacheUrl = url;
    if (body != null) {
      cacheUrl = '$url?${body.entries.map((entry) {
        return '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}';
      }).join('&')}';
    }
    final valid = await _valid(cacheUrl, duration: duration);

    if (!valid || reacquire) {
      final data = await _request(
              body: body,
              charset: charset,
              method: method,
              url: url,
              headers: headers,
              responseType: responseType)
          .timeout(timeout!);
      await _cache(cacheUrl, jsonEncode(data));
      return jsonEncode(data);
    } else {
      final file = await _generate(cacheUrl);
      return file.readAsString();
    }
  }

  /// Check the given url is cached or not.
  Future<bool> cached(String url) async {
    temporaryDirectory ??= await getTemporaryDirectory();
    final hash = md5.convert(utf8.encode(url)).toString();
    String filePath;
    if (prefix != null) {
      filePath = path.join(temporaryDirectory!.path, identifier, prefix, hash);
    } else {
      filePath = path.join(temporaryDirectory!.path, identifier, hash);
    }
    final file = File(filePath);
    return file.exists();
  }

  /// Validate the cached file.
  ///
  /// If the file exists and size is greater than 0, and the file is not expired,
  ///  return true.
  Future<bool> _valid(String url, {Duration? duration}) async {
    final file = await _generate(url);
    final exist = await file.exists();
    final stat = await file.stat();
    final size = stat.size;
    final createdAt = stat.changed;
    final now = DateTime.now();
    final permanent = duration == null;
    var expired = false;
    if (!permanent) {
      expired = now.difference(createdAt).compareTo(duration) > 0;
    }
    return exist && size > 0 && !expired;
  }

  /// Use to generate cache file.
  ///
  /// The file will be saved in [temporaryDirectory].
  Future<File> _generate(String url) async {
    temporaryDirectory ??= await getTemporaryDirectory();
    final hash = md5.convert(utf8.encode(url)).toString();
    String filePath;
    if (prefix != null) {
      filePath = path.join(temporaryDirectory!.path, identifier, prefix, hash);
    } else {
      filePath = path.join(temporaryDirectory!.path, identifier, hash);
    }
    return File(filePath);
  }

  /// Use to fetch data from network.
  ///
  /// This function will return the plain text no matter has redirect or not.
  Future<dynamic> _request({
    Map<String, dynamic>? body,
    String? charset,
    String? method,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    required String url,
  }) async {
    // final uri = Uri.parse(url);
    Response response;

    final dio = Dio(BaseOptions(
      headers: headers,
      responseType: responseType,
    ));
    //只在测试的时候添加
    dio.interceptors.add(
      LogInterceptor(
        responseBody: true,
        requestBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    );
    if (method?.toLowerCase() == 'post') {
      response = await dio.post(url, queryParameters: body);
    } else {
      response = await dio.get(url, queryParameters: body);
    }

    return response.data;
  }

  /// Use to cache data.
  ///
  /// Write content to file
  Future<void> _cache(String url, String content) async {
    final file = await _generate(url);
    await file.create(recursive: true);
    await file.writeAsString(content);
  }
}
