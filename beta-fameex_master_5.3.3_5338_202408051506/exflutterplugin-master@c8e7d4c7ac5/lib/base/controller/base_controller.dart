import 'dart:async';

import 'package:chainup_flutter_ex/ext/get_extension.dart';
import 'package:chainup_flutter_ex/routes/routes.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../net/http/app_except.dart';
import '../../net/http/result/base_result.dart';
import '../../net/http/result/base_result_vx.dart';
import '../../utils/log_utils.dart';
import '../../widgets/toast_mixin.dart';

///具有状态控制和网络请求能力的controller，等价MVVM中的ViewModel
abstract class BaseController<M> extends SuperController
    with ToastMixin, GetTickerProviderStateMixin {
  late M api;
  late EventBus eventBus;
  List<StreamSubscription>? _stremSubList;
  RxString barTitleString = "标题".obs;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var mCancelToken = CancelToken();
  var isClose = false;
  var isLandscape = false;
  @override
  void onInit() {
    super.onInit();
    Routes.pushNvEvent(
        ev: NvEvent.setBarColor,
        param: Get.isDarkMode
            ? {"statusBarColor": "#111111"}
            : {"statusBarColor": "#FFFFFF"});
    if (kDebugMode) {
      debugPrint('>>>>>>>onInit');
    }
  }

  void loadNet();

  /// 发起网络请求，同时处理异常，loading
  httpRequest<T>(Future<T> future, FutureOr<dynamic> Function(T value) onValue,
      {Function(Exception e)? error,
      Function(String code, String msg)? errorV2,
      bool showLoading = false,
      bool showErrorToast = true,
      bool handleError = false,
      bool handleSuccess = true}) {
    if (showLoading) {
      Get.showLoading();
    }
    future.then((t) {
      ///添加结果码判断（同时考虑加入List的判断逻辑）
      if (t is BaseResult) {
        baseResultHandler(
            t, handleSuccess, onValue, handleError, showErrorToast);
      } else if (t is BaseResultVx) {
        baseResultVxHandler(
            t, handleSuccess, onValue, handleError, errorV2, showErrorToast);
      } else {
        if (handleSuccess) {
          showSuccess();
        }
        onValue(t);
      }
    }).catchError((e) {
      if (kDebugMode) {
        debugPrint("网络请求异常====>error:$e");
        showToast(e.error.toString());
      }
      if (handleError) {
        showError(e: e);
      }
      if (error != null) {
        error(e);
      }
    }).whenComplete(() {
      if (showLoading) {
        Get.dismiss();
      }
    });
  }

  ///多网络请求简单封装
  multiHttpRequest(List<Future<dynamic>> futures,
      FutureOr<dynamic> Function(dynamic value) onValue,
      {Function(Exception e)? error,
      bool showLoading = false,
      bool handleError = true,
      bool showErrorToast = true,
      bool handleSuccess = true}) async {
    if (showLoading) {
      Get.showLoading();
    }
    Future.wait(futures).then((value) {
      if (value.isNotEmpty) {
        for (var element in value) {
          if (element is BaseResultVx) {
            var code = element.code.toString();
            if ("0" != code) {
              if ("10002" == code) {
                // Get.toNamed("/login");
                if (kDebugMode) {
                  debugPrint("用户未登录,跳转登录页面");
                }
                showToast(element.msg);
              } else {
                if (showErrorToast) {
                  showToast(element.msg);
                }
              }
              break;
            }
          } else if (element is BaseResult) {
            if ("200" != element.code) {
              if (showErrorToast) {
                showToast(element.msg);
              }
              break;
            }
          }
        }
      }

      onValue(value);
    }).catchError((e) {
      if (kDebugMode) {
        debugPrint("网络请求异常====>error:$e");
        showToast(e.toString());
      }

      if (handleError) {
        showError(e: e);
      }
      if (error != null) {
        error(e);
      }
    }).whenComplete(() {
      if (showLoading) {
        Get.dismiss();
      }
    });
  }

  void baseResultHandler<T>(
      t,
      bool handleSuccess,
      FutureOr<dynamic> Function(T value) onValue,
      bool handleError,
      bool showErrorToast) {
    if (200 == t.code) {
      if (handleSuccess) {
        showSuccess();
      }
      onValue(t);
    } else {
      if (showErrorToast) {
        showToast(t.msg);
      }
      showSuccess();
      // if (handleError) {
      //   showError(errorMessage: t.msg);
      // } else {
      //   onValue(t);
      //   if (handleSuccess) {
      //     showSuccess();
      //   }
      // }
    }
  }

  void BaseResultVxHandler<T>(
      t,
      bool handleSuccess,
      FutureOr<dynamic> Function(T value) onValue,
      bool handleError,
      bool showErrorToast) {
    if (0 == t.code) {
      if (handleSuccess) {
        showSuccess();
      }
      onValue(t);
    } else {
      if (showErrorToast) {
        showToast(t.msg);
      }
      showSuccess();
      // if (handleError) {
      //   showError(errorMessage: t.msg);
      // } else {
      //   onValue(t);
      //   if (handleSuccess) {
      //     showSuccess();
      //   }
      // }
    }
  }

  void baseResultVxHandler<T>(
      t,
      bool handleSuccess,
      FutureOr<dynamic> Function(T value) onValue,
      bool handleError,
      Function(String code, String msg)? errorV2,
      bool showErrorToast) {
    var code = t.code.toString();
    //||"10013" == code
    if ("0" == code) {
      if (handleSuccess) {
        showSuccess();
      }
      onValue(t);
    } else {
      if ("10002" == code) {
        // Get.toNamed("/login");
        if (kDebugMode) {
          debugPrint("用户未登录,跳转登录页面");
        }
        showToast(t.msg);
      } else {
        if (showErrorToast) {
          showToast(t.msg);
        }
        if (errorV2 != null) {
          errorV2(t.code.toString(), t.msg);
        }
      }
      showSuccess();
      // if (handleError) {
      //   showError(errorMessage: t.msg);
      // } else {
      //   onValue(t);
      //   if (handleSuccess) {
      //     showSuccess();
      //   }
      // }
    }
  }

  void baseGt3ResultHandler<T>(t, bool handleSuccess,
      FutureOr<dynamic> Function(T value) onValue, bool handleError) {
    showSuccess();
    if (t.code == "0") {
      onValue(t);
    } else {
      showToast(t.errorMsg);
    }
  }

  @override
  void onDetached() {
    if (kDebugMode) {
      debugPrint('>>>>>>>onDetached');
    }
  }

  @override
  void onInactive() {
    if (kDebugMode) {
      debugPrint('>>>>>>>onInactive');
    }
  }

  @override
  void onPaused() {
    if (kDebugMode) {
      debugPrint('>>>>>>>onPaused');
    }
  }

  @override
  void onResumed() {
    if (kDebugMode) {
      debugPrint('>>>>>>>onResumed');
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (kDebugMode) {
      debugPrint('>>>>>>>onReady');
    }
    if (useEventBus()) {
      eventBus = Get.find<EventBus>();
    }
    try {
      api = Get.find<M>();
    } catch (e) {
      print(e.toString());
    }
    // loadNet();
  }

  @override
  void onClose() {
    super.onClose();
    //解订阅EventBus
    disposeEventBus();
    if (kDebugMode) {
      debugPrint("onClose>>>");
    }
    mCancelToken.cancel();
    isClose = true;
  }

  ///解订阅StreamSubscription--关联EventBus
  void disposeEventBus() {
    _stremSubList?.forEach((element) {
      element.cancel();
    });
  }

  void showSuccess() {
    change(null, status: RxStatus.success());
  }

  void showEmpty() {
    change(null, status: RxStatus.empty());
  }

  void showError({String? errorMessage, Exception? e}) {
    if (e != null) {
      if (e is DioError && e.error is AppException) {
        var error = e.error as AppException;
        change(null, status: RxStatus.error(error.message));
      } else {
        change(null, status: RxStatus.error(errorMessage));
      }
    } else {
      change(null, status: RxStatus.error(errorMessage));
    }
  }

  void showLoading() {
    change(null, status: RxStatus.loading());
  }

  ///是否使用GetX查找EventBus
  bool useEventBus() => false;

  ///管理Eventbus解订阅
  void addStremSub(StreamSubscription? streamSubscription) {
    _stremSubList ??= [];
    if (streamSubscription != null) {
      _stremSubList?.add(streamSubscription);
    }
  }

  void setPortrait() {
    isLandscape = false;
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  }

  void setLandscape() {
    isLandscape = true;
    // if (isHorizontalKline) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    // SystemChrome.setEnabledSystemUIOverlays([]);
    // }
  }
}
