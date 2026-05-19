
import 'dart:async';
import 'dart:ffi';

import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:library_kline/utils/storage_utils.dart';

import '../../models/guide_item_entity.dart';
import '../../routes/routes.dart';
import 'item_guie_dialog.dart';


class ItemGuideManager {
  ItemGuideManager._internal();
  factory ItemGuideManager() => _instance;
  static late final ItemGuideManager _instance = ItemGuideManager._internal();

  BuildContext? mBuildContext;
  List<ItemGuideModel>? items;
  KumiPopupWindow? mGuideKumiPopupWindow = null;



  void startPopGuides(BuildContext? context,GlobalKey key){
     mBuildContext=context;

    var guideFlag = ExStorageUtils.getObject(ExStorageUtils.KLINE_V_GUIDE1_STATUS,def: "0");
    if("1"==guideFlag) return;

    if (items == null){
      return;
    }
    if (items!.isEmpty){
      saveGuideKey();
      return;
    }
    final item = items!.first;
    print("item.title = ${item.title}");
    popGuide(context,key,item.key!,item);
  }


  void popGuide(BuildContext? context,GlobalKey targetViewKey,GlobalKey key,ItemGuideModel guide) {
    mGuideKumiPopupWindow = showPopupWindow(
      context!,
      gravity: KumiPopupGravity.leftTop,
      curve: Curves.easeInOutCubic,
      bgColor: Colors.grey.withOpacity(0),
      clickOutDismiss: true,
      clickBackDismiss: true,
      customAnimation: true,
      customPop: false,
      customPage: false,
      targetRenderBox:
      (targetViewKey.currentContext?.findRenderObject() as RenderBox),
      underStatusBar: false,
      underAppBar: true,
      offsetX: 0,
      offsetY: 36,
      duration: const Duration(milliseconds: 100),
      onShowStart: (pop) {
        print("guide onShowStart>>>");
      },
      onShowFinish: (pop) {
        print("guide onShowFinish>>>");
      },
      onDismissStart: (pop) {
        print("guide onDismissStart>>>");
      },
      onDismissFinish: (pop) {
        print("guide onDismissFinish>>>");
        goonGuide(mBuildContext??context,targetViewKey);
      },
      onClickOut: (pop) {

        print("guide onClickOut");
      },
      onClickBack: (pop) {
        print("guide onClickBack");
      },
      childFun: (pop) {
          return StatefulBuilder(
            key: GlobalKey(),
            builder: (BuildContext context, StateSetter setState) {
              return GestureDetector(
                  onTap: (){
                    mGuideKumiPopupWindow?.dismiss(context);
                    print("guide dissmiss");
                    // goonGuide(mBuildContext!,targetViewKey);
                  },
                  child: ItemGuideDialog(itemGuideModel: guide)
              );
            },
          );

      },
    );

  }

  void goonGuide(BuildContext context,GlobalKey targetViewKey){
    if (items!.isNotEmpty){
      items!.removeAt(0);
      print("items.length =>${items!.length}");
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      print("第二次处理");
      startPopGuides(context,targetViewKey);
    });
  }
  void saveGuideKey(){
    ExStorageUtils.putObject(ExStorageUtils.KLINE_V_GUIDE1_STATUS, "1");
    //兼容安卓
    Routes.pushNvEvent(
        ev: NvEvent.kline_guide_flag,
        param: {"flagStr": "1"}
    );

  }
}
