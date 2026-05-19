import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/bottom_sheet_entity.dart';
import '../models/task_center_index_entity.dart';
import '../models/user_info_entity.dart';
import '../page/taskCenter/item_checked_in_dialog.dart';
import '../page/taskCenter/item_kyc_check_dialog.dart';
import '../page/taskCenter/item_received_success_dialog.dart';
import '../widgets/ex_bottom_dialog.dart';
import '../widgets/ex_bottom_select_list.dart';
import '../widgets/ex_dialog.dart';
import '../widgets/ex_loading.dart';

/// @description :get 扩展函数
extension GetExtension on GetInterface {
  ///隐藏dialog
  dismiss() {
    if (Get.isDialogOpen != null && Get.isDialogOpen!) {
      Get.back();
    }
  }

  ///显示dialog
  showLoading({String text = ''}) {
    if (Get.isDialogOpen != null && Get.isDialogOpen!) {
      Get.back();
    }
    Get.dialog(LoadingDialog(),
        transitionDuration: const Duration(milliseconds: 500),
        barrierDismissible: false);
  }

  ///显示公共弹窗
  showCommonDialog({
    String title = '',
    String content = '',
    String negaText = '',
    String posiText = '',
    bool negaVisible = true,
    bool posiVisible = true,
    bool iconVisible = false,
    bool isNeedAutoDismiss = true,
    VoidCallback? negaTap,
    VoidCallback? posiTap,
    backKey = false,
    isCloseOther = true,
    Color? okBtnTextColor,
  }) {
    if (Get.isDialogOpen != null && Get.isDialogOpen! && isCloseOther) {
      Get.back();
    }
    Get.dialog(
        CommonDialog(
          title: title,
          content: content,
          negaText: negaText.isEmpty ? "text88".tr : negaText,
          posiText: posiText.isEmpty ? "text8".tr : posiText,
          negaVisible: negaVisible,
          posiVisible: posiVisible,
          negaTap: negaTap,
          posiTap: posiTap,
          iconVisible: iconVisible,
          okBtnTextColor: okBtnTextColor,
          isNeedAutoDismiss: isNeedAutoDismiss,
        ),
        transitionDuration: const Duration(milliseconds: 500),
        barrierDismissible: backKey);
  }

  showDialogList(){
    if (Get.isDialogOpen != null && Get.isDialogOpen!) {
      Get.back();
    }
    Get.dialog(
        CommonListDialog(dialogList: ListDialogItem.getDialogList()),
        transitionDuration: const Duration(milliseconds: 500),
    );
  }
  ///显示公共底部List弹窗
  showBottomListDialog({
    required List<BottomSheetEntity> datas,
    required Function(int)? itemClickTap,
    int? currentSelected = -1,
  }) {
    if (Get.isBottomSheetOpen != null && Get.isBottomSheetOpen!) {
      Get.back();
    }
    Get.bottomSheet(
      ExBottomDialog(
          datas: datas,
          currentSelected: currentSelected ?? -1,
          itemClickTap: itemClickTap),
      isScrollControlled: true,
    );
  }

  /**
   * 显示公共底部List弹窗(V2)
   * 语言、颜色、等等
   */
  showBottomListDialogV2({
    required List<BottomSheetEntity> datas,
    required Function(int)? itemClickTap,
    required int currentSelected,
    required String title,
  }) {
    if (Get.isBottomSheetOpen != null && Get.isBottomSheetOpen!) {
      Get.back();
    }
    Get.bottomSheet(
      SheetSelectList(
          title: title,
          datas: datas,
          currentSelected: currentSelected,
          itemClickTap: itemClickTap),
    );
  }

  //显示选择照片弹窗
  showSelPicBottomListDialog({
    required Function(int)? itemClickTap,
  }) {
    if (Get.isBottomSheetOpen != null && Get.isBottomSheetOpen!) {
      Get.back();
    }
    List<BottomSheetEntity> selPicTypeData = [];
    selPicTypeData.add(BottomSheetEntity(showName: "拍照"));
    selPicTypeData.add(BottomSheetEntity(showName: "相册"));
    Get.bottomSheet(
      ExBottomDialog(
          datas: selPicTypeData,
          currentSelected: -1,
          itemClickTap: itemClickTap),
      isScrollControlled: true,
    );
  }

  /**
   * _rewardCoin 奖励币种
   * _rewardAmount 奖励数量
   *  rewardType 奖励类型
   * voidCallback 点击查看更多回调
   */
  showReceivedSuccessBox(String? _rewardCoin, String? _rewardAmount,
      {String? rewardType,
      String? viewMoreText,
      VoidCallback? viewMoreCallback,
      VoidCallback? okCallback}) {
    if (Get.isBottomSheetOpen != null && Get.isBottomSheetOpen!) {
      Get.back();
    }
    Get.dialog(
      ItemReceivedSuccessDialog(
        rewardCoin: _rewardCoin ?? "",
        rewardAmount: _rewardAmount ?? "",
        rewardType: rewardType,
        viewMoreText: viewMoreText,
        viewMoreCallback: () {
          viewMoreCallback?.call();
        },
        okCallback: okCallback,
      ),
    );
  }

  showKycCheckBox(
    UserInfoEntity mUserInfoEntity,
    VoidCallback _posiTap,
  ) {
    if (Get.isBottomSheetOpen != null && Get.isBottomSheetOpen!) {
      Get.back();
    }
    Get.dialog(
      ItemKycCheckDialog(
        posiTap: _posiTap,
        isOpenMobile: mUserInfoEntity.isOpenMobileCheck == 1,
        isOpenGA: mUserInfoEntity.googleStatus == 1,
        isIDAuth: mUserInfoEntity.authLevel == 1,
      ),
    );
  }

  showCheckInBox(
    TaskCenterIndexSignInInfo? _signInInfo,
    VoidCallback _posiTap,
  ) {
    if (Get.isBottomSheetOpen != null && Get.isBottomSheetOpen!) {
      Get.back();
    }
    Get.bottomSheet(
      isScrollControlled: true,
      ItemCheckedInDialog(
        signInInfo: _signInInfo,
        posiTap: _posiTap,
      ),
    );
  }
}
