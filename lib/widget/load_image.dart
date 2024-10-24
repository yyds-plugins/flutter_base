import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/utils_image.dart';

/// 图片加载（支持本地与网络图片）
class LoadImage extends StatelessWidget {
  const LoadImage(this.image,
      {Key? key,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
      this.format = ImageFormat.png,
      this.holderImg,
      this.cacheWidth,
      this.cacheHeight,
      this.httpHeaders,
      this.color})
      : super(key: key);

  final String image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ImageFormat format;
  final String? holderImg;
  final int? cacheWidth;
  final int? cacheHeight;
  final Map<String, String>? httpHeaders;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty || image.startsWith('http')) {

      Widget _error = Container(width: width, height: height,decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ));

      Widget _image = holderImg != null
          ? LoadAssetImage(holderImg!, height: height, width: width, fit: fit)
          : Container(width: width, height: height, child: Center(child: CupertinoActivityIndicator()));

      return CachedNetworkImage(
        imageUrl: image,
        httpHeaders: httpHeaders,
        placeholder: (_, __) => _image,
        errorWidget: (_, __, dynamic error) => _error,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        color: color, //目标颜色
        colorBlendMode: BlendMode.color, //颜色混合模式
      );
    } else {
      return LoadAssetImage(
        image,
        height: height,
        width: width,
        fit: fit,
        format: format,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
    }
  }
}

/// 加载本地资源图片
class LoadAssetImage extends StatelessWidget {
  const LoadAssetImage(this.image,
      {Key? key, this.width, this.height, this.cacheWidth, this.cacheHeight, this.fit, this.format = ImageFormat.png, this.color})
      : super(key: key);

  final String image;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;
  final BoxFit? fit;
  final ImageFormat format;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ImageUtils.getImgPath(image, format: format),
      height: height,
      width: width,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      fit: fit,
      color: color,

      /// 忽略图片语义
      excludeFromSemantics: true,
    );
  }
}
