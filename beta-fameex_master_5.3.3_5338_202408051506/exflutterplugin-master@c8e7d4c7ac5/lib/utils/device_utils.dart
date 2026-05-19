import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/foundation.dart';

import 'log_utils.dart';

class Device {
  static bool get isDesktop => !isWeb && (isWindows || isLinux || isMacOS);
  static bool get isMobile => isAndroid || isIOS;
  static bool get isWeb => kIsWeb;

  static bool get isWindows => !isWeb && Platform.isWindows;
  static bool get isLinux => !isWeb && Platform.isLinux;
  static bool get isMacOS => !isWeb && Platform.isMacOS;
  static bool get isAndroid => !isWeb && Platform.isAndroid;
  static bool get isFuchsia => !isWeb && Platform.isFuchsia;
  static bool get isIOS => !isWeb && Platform.isIOS;

  static late AndroidDeviceInfo _androidInfo;
  static late IosDeviceInfo _iosInfo;
  static late PackageInfo _packageInfo;

  static Future<void> initDeviceInfo() async {
    if (isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      _androidInfo = await deviceInfo.androidInfo;
    }
    if(isIOS){
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      _iosInfo = await deviceInfo.iosInfo;
    }
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /*
  * 获取设备平台标识
  * */
  static String systemPlatform() {
    if (isMacOS || isIOS) {
      return "ios";
    } else {
      return "Android";
    }
  }

  /*
  * 设备系统版本号
  * */
  static String systemVersion(){
    if(isMacOS || isIOS){
      return _iosInfo.systemVersion.toString();
    } else {
      return _androidInfo.version.baseOS.toString();
    }
  }

  /*
  * 应用版本号
  * */
  static String appVersion(){
    return _packageInfo.version.toString();
  }

  /*
  * 应用名称
  * */
  static String appName(){
    LogUtil.e("appName:${_packageInfo.appName}");
    return _packageInfo.appName.toString();
  }

  /*
  * 应用构建版本号
  * */
  static String appBuildVersion(){
    return _packageInfo.buildNumber.toString();
  }

  /*
  * 设备的UUID
  * */
  static String UUID(){
    return _uuid();
  }

  /*
  * 设备的UDID
  * */
  static String UDID(){
    return _uuid();
  }

  static String _uuid(){
    if(isMacOS || isIOS){
      return _iosInfo.identifierForVendor.toString();
    } else {
      return _androidInfo.id.toString();
    }
  }

  static PackageInfo packageInfo(){
    return _packageInfo;
  }

  static String version() {
    return _packageInfo.version;
  }

  static String buildId() {
    return  _packageInfo.buildNumber;
  }

  /// 使用前记得初始化
  static int getAndroidSdkInt() {
    if (isAndroid && _androidInfo != null) {
      return _androidInfo.version.sdkInt ?? -1;
    } else {
      return -1;
    }
  }
}
