///  jh_encrypt_utils.dart
///
///  Created by iotjin on 2020/08/18.
///  description:  base64、MD5、AES加解密(CBC/PKCS7)

// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_base/utils/logger_util.dart';

var _key = 'IW29Rp8JjroBZ10Nlheyfsc3CASiFd5P';
var _iv = 'W3lmxe2qRWD8kNbD';

// 128的keySize=16，192keySize=24，256keySize=32

class JhEncryptUtils {
  /// Base64编码
  static String encodeBase64(String data) {
    return base64Encode(utf8.encode(data));
  }

  /// Base64解码
  static String decodeBase64(String data) {
    return String.fromCharCodes(base64Decode(data));
  }

  /// AES加密
  static aesEncrypt(plainText) {
    try {
      final key = Key.fromUtf8(_key);
      final iv = IV.fromUtf8(_iv);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return encrypted.base64;
    } catch (err) {
      Log.d('AES encode error:$err');
      return plainText;
    }
  }

  /// AES解密
  static dynamic aesDecrypt(encrypted) {
    try {
      final key = Key.fromUtf8(_key);
      final iv = IV.fromUtf8(_iv);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt64(encrypted, iv: iv);
      return decrypted;
    } catch (err) {
      Log.d('AES decode error:$err');
      return encrypted;
    }
  }

//  /// AES加密
//  static aesEncode(String plainText) {
//    try {
//      final key = Key.fromBase64(base64Encode(utf8.encode(_key)));
//      final iv = IV.fromBase64(base64Encode(utf8.encode(_iv)));
//      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
//      final encrypted = encrypter.encrypt(plainText, iv: iv);
//      return encrypted.base64;
//    } catch (err) {
//      Log.d('AES encode error:$err');
//      return plainText;
//    }
//  }
//
//  /// AES解密
//  static aesDecode(dynamic encrypted) {
//    try {
//      final key = Key.fromBase64(base64Encode(utf8.encode(_key)));
//      final iv = IV.fromBase64(base64Encode(utf8.encode(_iv)));
//      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
//      final decrypted = encrypter.decrypt64(encrypted, iv: iv);
//      return decrypted;
//    } catch (err) {
//      Log.d('AES decode error:$err');
//      return encrypted;
//    }
//  }
}
