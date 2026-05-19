//
// import 'dart:typed_data';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
//
// /// 用于读取原生资源中的图片
// class NativeImageProvider extends ImageProvider<NativeImageProvider> {
//
//   final String imageName;
//   final double scale;
//   final Uint8List bytes;
//
//   const NativeImageProvider(this.imageName ,this.bytes,{this.scale: 1.0});
//
//   @override
//   ImageStreamCompleter load(key) {
//     return new MultiFrameImageStreamCompleter(
//         codec: _loadAsync(key),
//         scale: key.scale,
//         informationCollector: (StringBuffer information) {
//           information.writeln('Image provider: $this');
//           information.write('Image key: $key');
//         });
//   }
//
//   Future _loadAsync(NativeImageProvider key) async {
//     /// 读不到原生图片，开始读取images
//     if (bytes == null || bytes.lengthInBytes == 0) {
//       AssetBundle assetBundle = PlatformAssetBundle();
//       ByteData byteData = await assetBundle.load("assets/images/$imageName.png");
//       return await PaintingBinding.instance.instantiateImageCodec(byteData.buffer.asUint8List());
//     } else {
//       return await _loadAsyncFromFile(key, bytes);
//     }
//   }
//
//   Future _loadAsyncFromFile(NativeImageProvider key, Uint8List bytes) async {
//     assert(key == this);
//     if (bytes.lengthInBytes == 0) {
//       throw new Exception("bytes[] was empty");
//     }
//     return await ui.instantiateImageCodec(bytes);
//   }
//
//   @override
//   Future<NativeImageProvider> obtainKey(ImageConfiguration configuration) {
//     // TODO: implement obtainKey
//     return SynchronousFuture<NativeImageProvider>(this);
//   }
// }
//
// /// 获取原生图片
// Future getNativeImage(String imageName) async {
//   Uint8List bytes =
//   await channel.invokeMethod('getNativeImage', {'imageName': imageName});
//   setState(() {
//     imageIcon = bytes;
//   });
// }
//
// Image(image: NativeImageProvider('cc_white_return', imageIcon),)
