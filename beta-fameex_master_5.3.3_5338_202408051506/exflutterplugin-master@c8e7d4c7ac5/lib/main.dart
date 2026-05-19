import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:chainup_flutter_ex/event/route_observer.dart';
import 'package:chainup_flutter_ex/utils/app_utils.dart';
import 'package:chainup_flutter_ex/utils/log_utils.dart';
import 'package:chainup_flutter_ex/utils/native_notifition.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:library_kline/kline_constant.dart';
import 'package:library_kline/utils/ExColors_util.dart';
import 'package:library_kline/utils/klineCoinInfo.dart';
import 'package:library_kline/utils/storage_utils.dart';

import 'I10n/translation_service.dart';
import 'base/controller/themes_controller.dart';
import 'constants/api_constant.dart';
import 'constants/app_constant.dart';
import 'routes/routes.dart';
import 'themes/Themes.dart';
import 'utils/device_utils.dart';
import 'utils/injection.dart';
import '../../event/event.dart';

List<StreamSubscription>? _appStremSubList;

void main() async {
  await GetStorage.init();
  parseRouter();
  await Injection().init();
  await Device.initDeviceInfo();
  await ScreenUtil.ensureScreenSize();
  NativeNotifition.getInstance().init();
  // listenEvent();
  setPortrait();
  runApp(App());
}

class App extends StatelessWidget {
  final ThemesController themeController = Get.put(ThemesController());

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: '',
        theme: ExThemes.lightTheme,
        darkTheme: ExThemes.darkTheme,
        themeMode: getThemeMode(themeController.theme),
        getPages: Routes.routes,
        initialRoute: Routes.KLINE_DETAIL,
        locale: TranslationService.locale,
        fallbackLocale: TranslationService.fallbackLocale,
        translations: TranslationService(),
        navigatorObservers: [EXRouteObserver()],
        // routingCallback: (routing) {
        //   if (routing?.current == Routes.INITIAL) {
        //     Routes.pushPage(routeName: Routes.KLINE_HORIZONTAL);
        //   }
        // }
      ),
    );
  }

  ThemeMode getThemeMode(String type) {
    ThemeMode themeMode = ThemeMode.system;
    switch (type) {
      case "system":
        themeMode = ThemeMode.system;
        break;
      case "dark":
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.light;
        break;
    }
    return themeMode;
  }
}

void setPortrait() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

void parseRouter() {
  String url = window.defaultRouteName;
  if (kDebugMode) {
    debugPrint("origin url:$url");
  }
  String paramsJson =
      !url.contains("?") ? "{}" : url.substring(url.indexOf("?") + 1);
  if (kDebugMode) {
    debugPrint("paramsJson: ${paramsJson}");
  }
  Map<String, dynamic> params = json.decode(paramsJson);
  if (kDebugMode) {
    if (params.keys.isEmpty) {
      params = {
        "isDebug": "1",
        "domain": "mi.com",
        "exToken":
            "c94358bca598d0ed1b9a38276e7fef5d1575885e71ec40098233aeaefdaf013a",
        "lan": "",
        "theme": "light",
        "riseFallTrend": 0,
        "needSubWs": true,
        // "main1": "#FFD532",
        // "main2": "#D9B52B",
        // "main3": "#FFF9E0",
        // "main4": "#D9B52B",
        // "text4": "#000000",
      };
    }
  }

  if (kDebugMode) {
    debugPrint("parse json: ${params}");
  }
  if (params.containsKey("exToken")) {
    ExStorageUtils.putObject(ExStorageUtils.TOKEN, params["exToken"]);
  }
  if (params.containsKey("needSubWs")) {
    AppUtil.needSubWs = params["needSubWs"] as bool;
  }
  if (params.containsKey("lan")) {
    ExStorageUtils.putObject(ExStorageUtils.LAN, params["lan"]);
  }
  if (params.containsKey("theme")) {
    ExStorageUtils.putObject(ExStorageUtils.THEME, params["theme"]);
  } else {
    ExStorageUtils.putObject(ExStorageUtils.THEME, 'light');
  }
  if (params.containsKey("main1")) {
    ExColorsUtil.update(main1: params["main1"]);
  }
  if (params.containsKey("main2")) {
    ExColorsUtil.update(main2: params["main2"]);
  }
  if (params.containsKey("main3")) {
    ExColorsUtil.update(main3: params["main3"]);
  }
  if (params.containsKey("main4")) {
    ExColorsUtil.update(main4: params["main4"]);
  }
  if (params.containsKey("text4")) {
    ExColorsUtil.update(text4: params["text4"]);
  }
  if (params.containsKey("riseFallTrend")) {
    ExStorageUtils.putObject(
        ExStorageUtils.RISE_FALL_COLOR, params["riseFallTrend"]);
    final riseFallTrend = params["riseFallTrend"];
    KlineConstant.COLOR_TYPE =
        riseFallTrend == 1 || riseFallTrend == "1" ? 1 : 0;
  } else {
    KlineConstant.COLOR_TYPE = 0;
  }
  if (params.containsKey("isDebug")) {
    AppUtil.setDebug(params["isDebug"]);
  }
  if (params.containsKey("domain")) {
    String domain = params["domain"];
    if (domain.contains("http")) {
      ApiConstant.BASE_URL = domain;
    } else {
      ApiConstant.BASE_URL = "https://www.${params["domain"]}/";
    }
  }
  if (params.containsKey("klineGuideFlag")) {
    var flagStr = params["klineGuideFlag"] as String;
    ExStorageUtils.putObject(ExStorageUtils.KLINE_V_GUIDE1_STATUS, flagStr);
  }
  if (params.containsKey(ExStorageUtils.COIN_ANALYSIS_COIN_SYMBOLS)) {
    ExStorageUtils.putObject(ExStorageUtils.COIN_ANALYSIS_COIN_SYMBOLS,
        params[ExStorageUtils.COIN_ANALYSIS_COIN_SYMBOLS]);
  }
  if (params.containsKey(ExStorageUtils.MARGIN_ANALYSIS_TYPE)) {
    ExStorageUtils.putObject(ExStorageUtils.MARGIN_ANALYSIS_TYPE,
        params[ExStorageUtils.MARGIN_ANALYSIS_TYPE]);
  }
  if (params.containsKey(ExStorageUtils.SHOW_OR_HIDE_ASSETS_AMOUNT)) {
    ExStorageUtils.putObject(ExStorageUtils.SHOW_OR_HIDE_ASSETS_AMOUNT,
        params[ExStorageUtils.SHOW_OR_HIDE_ASSETS_AMOUNT]);
  }
  if (params.containsKey(ExStorageUtils.UUID_CU)) {
    ExStorageUtils.putObject(
        ExStorageUtils.UUID_CU, params[ExStorageUtils.UUID_CU]);
  }
  if (params.containsKey(ExStorageUtils.DEVICE)) {
    ExStorageUtils.putObject(
        ExStorageUtils.DEVICE, params[ExStorageUtils.DEVICE]);
  }
  if (params.containsKey("waterPath")) {
    AppConstant.waterPath=params["waterPath"] as String;
  }

  if (params.containsKey("lan")) {
    AppConstant.isZh = params["lan"].toString().contains("zh");
    KLineCoinInfo.isChinese = AppConstant.isZh;
    print("KLineCoinInfo.isChinese= ${KLineCoinInfo.isChinese}");
  }
  LogUtil.e("AppConstant.isZh:" + AppConstant.isZh.toString());

  // ExStorageUtils.putObject(ExStorageUtils.TOKEN,"f99da127fd68efe31c4392e93b419d38829f6e5824ef4d01a3d299a85566ef5b");
  // ExStorageUtils.putObject(ExStorageUtils.LAN,"zh_CN");
  // ApiConstant.BASE_URL="http://www.creaverse.online/";
  // AppUtil.setDebug("1");
}
// void listenEvent() {
//   addStremSub(Event.eventBus.on<MessageEvent>().listen((event) {
//     if (event.msg_type == MessageEvent.nativeNotifitionEvent) {
//       nativeMethods(event.msg_content);
//     }
//   }));
// }
//
// void nativeMethods(dynamic data) {
//   if (data is Map) {
//     String method = data["method"];
//     dynamic arguments = data["arguments"];
//     Map<String, dynamic> params = json.decode(arguments);
//     switch (method) {
//       case "updateConfig":
//         updateAppconfig(params);
//         break;
//       default:
//         break;
//     }
//   }
// }
//
// //更新语言 / 涨跌色 /皮肤
// void updateAppconfig(Map<String, dynamic> params){
//   print("parse json: ${params}");
//   if (params.containsKey("theme")) {
//     final theme = params["theme"];
//     final old = ExStorageUtils.getObject(ExStorageUtils.THEME);
//     if (theme != old){
//       if (theme == "dark"){
//         Get.changeTheme(ExThemes.darkTheme);
//       }else{
//         Get.changeTheme(ExThemes.lightTheme);
//       }
//       ExStorageUtils.putObject(ExStorageUtils.THEME, params["theme"]);
//     }
//   }
// }

// ///管理Eventbus解订阅
// void addStremSub(StreamSubscription? streamSubscription) {
//   _appStremSubList ??= [];
//   if (streamSubscription != null) {
//     _appStremSubList?.add(streamSubscription);
//   }
// }
