library ex_icon_library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:library_kline/utils/ExColors_util.dart';

part 'breakeven_analysis_icon.dart';

class ExIcon {
  static final _colorUtil = ExColorsUtil();

  static String themeImage(String name) {
    return Get.isDarkMode ? "images/dark/$name.png" : "images/light/$name.png";
  }

  static String themeSvgImage(String name) {
    return "images/svg/$name.svg";
  }

  static Image icBack() {
    return Image.asset(
        Get.isDarkMode
            ? "images/dark/public_return.png"
            : "images/light/public_return.png",
        width: 20,
        height: 20);
  }

  static Widget icCornerMarkerSelect() {
    return SvgPicture.asset(
      "images/svg/public_selecteds.svg",
      color: _colorUtil.main_1,
    );
  }

  static Widget icEmptyData() {
    return Image.asset(
        Get.isDarkMode
            ? "images/dark/public_img_empty.png"
            : "images/light/public_img_empty.png",
        width: 80,
        height: 80);
  }

  static Widget noNetWorkImg() {
    return Image.asset(
        Get.isDarkMode
            ? "images/dark/public_img_wifi.png"
            : "images/light/public_img_wifi.png",
        width: 80,
        height: 80);
  }

  static Widget icKlineRetry() {
    return Image.asset(
      Get.isDarkMode
          ? "images/dark/trade_reload.png"
          : "images/light/trade_reload.png",
      width: 20,
      height: 20,
    );
  }

  static Widget icChartRetry() {
    return Image.asset(
      Get.isDarkMode
          ? "images/dark/trade_reload.png"
          : "images/light/trade_reload_light.png",
      width: 20,
      height: 20,
    );
  }

  static Image icTaskTopIllustration() {
    return Image.asset("images/light/task_top_illustration.png",
        width: 182, height: 173);
  }

  static Image icRewardTopIllustration() {
    return Image.asset("images/light/reward_top_illustration.png",
        width: 182, height: 172);
  }

  static Image icSignInNow() {
    return Image.asset("images/light/sign_in_now.png", width: 100, height: 36);
  }

  static Image icSignInMark() {
    return Image.asset("images/light/signed_in_mark.png",
        width: 20, height: 10);
  }

  static Image icSignNoMark() {
    return Image.asset("images/light/signed_no_mark.png",
        width: 20, height: 10);
  }

  static Image icSignInYes() {
    return Image.asset("images/light/sign_in_yes.png", width: 12, height: 12);
  }

  static Widget icSelected(double size) {
    return SvgPicture.asset(
      ExIcon.themeSvgImage("public_checked"),
      width: size,
      height: size,
      color: _colorUtil.main_1,
    );
  }

  static Image icUnSelected(double size) {
    return Image.asset(ExIcon.themeImage("quotes_unselected"),
        width: size, height: size);
  }

  static Image icSignInNo() {
    return Image.asset("images/light/sign_in_no.png", width: 12, height: 12);
  }

  static Image icSignReceivedSuccessfully() {
    return Image.asset("images/light/icon_received_successfully.png",
        width: 132, height: 115);
  }

  static Widget icTask1() {
    return SvgPicture.asset(
      Get.isDarkMode
          ? "images/svg/default_image.svg"
          : "images/svg/default_image.svg",
      width: 32,
      height: 32,
    );
  }

  // static Image icTask1() {
  //   return Image.asset("images/light/task_1.png", width: 32, height: 32);
  // }

  static Image icLoading() {
    return Image.asset(
      "images/light/common_loading.png",
      width: 60,
      height: 60,
    );
  }

  static Image icNoData() {
    return Image.asset("images/light/public_nocontentyet.png",
        width: 80, height: 80);
  }

  static Image icDialogTips() {
    return Image.asset("images/light/icon_dialog_tips.png",
        width: 60, height: 60);
  }

  static Image icKlineBuy() {
    return Image.asset("images/light/kline_buy.png", width: 15, height: 15);
  }

  static Image icKlineSell() {
    return Image.asset("images/light/kline_sell.png", width: 15, height: 15);
  }

  static Widget icKlineLoading() {
    return Get.isDarkMode ? Image.asset("images/dark/kline_loading.png", width: 15, height: 15):Image.asset("images/light/kline_loading.png", width: 15, height: 15);
  }

  static Image icSidebar() {
    return Image.asset(
        Get.isDarkMode
            ? "images/dark/icon_switch_coin.png"
            : "images/light/icon_switch_coin.png",
        width: 16,
        height: 16);
  }

  static Image icKlineFullscreen() {
    return Image.asset(
      "images/dark/icon_kline_fullscreen.png",
      width: 16,
      height: 16,
    );
  }

  static Image icKlineZoomout() {
    return Image.asset(
      "images/dark/trade_zoomout.png",
      width: 16,
      height: 16,
    );
  }

  static Image icKlineTools() {
    return Image.asset("images/dark/trade_setupthe.png", width: 16, height: 16);
  }

  static Image icKlineToolsCheck() {
    return Image.asset(themeImage("trade_setuptheclick"),
        width: 16, height: 16);
  }

  static Image icDropDown() {
    return Image.asset(
        Get.isDarkMode
            ? "images/dark/trade_arrow_down_small.png"
            : "images/light/trade_arrow_down_small.png",
        width: 8.0,
        height: 8.0);
  }

  static Image icDropDownSelected() {
    return Image.asset(
        Get.isDarkMode
            ? "images/dark/trade_arrow_superior_small_hover.png"
            : "images/light/trade_arrow_superior_small_hover.png",
        width: 8.0,
        height: 8.0);
  }

  static Image icShare() {
    return Image.asset(
      "images/dark/icon_share.png",
      width: 16,
      height: 16,
    );
  }

  static Image icNoFavorites() {
    return Image.asset(
      Get.isDarkMode
          ? "images/dark/public_notfavorited.png"
          : "images/light/public_notfavorited.png",
      width: 16,
      height: 16,
    );
  }

  static Widget icFavorites() {
    return SvgPicture.asset(
      "images/svg/public_favorites.svg",
      color: _colorUtil.main_1,
    );
  }

  static Widget icGuidePopTop() {
    return SvgPicture.asset(
      "images/svg/public_poptop.svg",
      color: _colorUtil.main_1,
    );
  }

  static Image icFundingRate() {
    return Image.asset(
      Get.isDarkMode
          ? "images/dark/trade_fundingrate.png"
          : "images/light/trade_fundingrate.png",
      width: 12,
      height: 12,
    );
  }

  static Widget icMarkPrice() {
    return SvgPicture.asset(
      "images/svg/trade_contract_pricetag.svg",
      color: _colorUtil.main_1,
    );
  }

  static Image icTradeAdd() {
    return Image.asset(
      "images/light/trade_add.png",
      width: 16,
      height: 16,
    );
  }

  static Image icTradeReduce() {
    return Image.asset(
      "images/light/trade_reduce.png",
      width: 16,
      height: 16,
    );
  }

  static Image icArrowRight({Color? color}) {
    return Image.asset(
      "images/light/public_arrow_right.png",
      width: 16,
      height: 16,
      color: color,
    );
  }

  static Image icHint() {
    return Image.asset(
      "images/light/public_hint.png",
      width: 16,
      height: 16,
    );
  }

  static Image icRewardsCenter() {
    return Image.asset(
      "images/light/icon_rewards_center.png",
      width: 36,
      height: 36,
    );
  }

  static Image icRewardsCenterRight() {
    return Image.asset(
      "images/light/icon_rewards_center_right.png",
      width: 24,
      height: 24,
    );
  }

  static Image icCheckinCenter() {
    return Image.asset(
      "images/light/icon_checkin_center.png",
      width: 36,
      height: 36,
    );
  }

  static Image icCheckinCenterRight() {
    return Image.asset(
      "images/light/icon_checkin_center_right.png",
      width: 24,
      height: 24,
    );
  }

  static Image icCheckinOver() {
    return Image.asset(
      "images/light/icon_checkin_over.png",
      width: 40,
      height: 40,
    );
  }

  static Image icCheckinCoin() {
    return Image.asset(
      "images/light/icon_checkin_coin.png",
      width: 48,
      height: 40,
    );
  }

  static Image icCheckinCoinSmall() {
    return Image.asset(
      "images/light/icon_checkin_coin.png",
      width: 20,
      height: 20,
    );
  }

  static Image icSubtract() {
    return Image.asset(
      "images/light/icon_subtract.png",
      width: 14,
      height: 14,
    );
  }

  static Image icTradeShare() {
    return Image.asset(
      "images/light/trade_share.png",
      width: 16,
      height: 16,
    );
  }

  static Image timedRewardLight() {
    return Image.asset(
      "images/light/icon_checkin_timed_reward_light.png",
      height: 40,
      width: 40,
    );
  }

  static Image timedRewardGray() {
    return Image.asset(
      "images/light/icon_checkin_timed_reward_gray.png",
      height: 40,
      width: 40,
    );
  }

  static Image viewMore({Color? color}) {
    return Image.asset(
      "images/light/icon_dialog_view_more.png",
      height: 14,
      width: 14,
      color: color,
    );
  }

  static Image rewardsHaveReceived() {
    return Image.asset(
      "images/light/icon_rewards_have_received.png",
      height: 5,
      width: 7,
    );
  }

  static Image emptyListIcon(
      {double? width = 80, double? height = 80, Color? color}) {
    return Image.asset(
      "images/light/empty_list_icon.png",
      height: width,
      width: height,
      color: color,
    );
  }

  static Widget taskKycCertificationRewards({double? width, double? height}) {
    return SvgPicture.asset(
      Get.isDarkMode
          ? "images/svg/task_kyc_certification_rewards.svg"
          : "images/svg/task_kyc_certification_rewards.svg",
      width: width,
      height: height,
    );
  }

  static Widget taskRecharge({double? width, double? height}) {
    return SvgPicture.asset(
      Get.isDarkMode
          ? "images/svg/task_recharge.svg"
          : "images/svg/task_recharge.svg",
      width: width,
      height: height,
    );
  }

  static Widget taskRegistrationRewards({double? width, double? height}) {
    return SvgPicture.asset(
      Get.isDarkMode
          ? "images/svg/task_registration_rewards.svg"
          : "images/svg/task_registration_rewards.svg",
      width: width,
      height: height,
    );
  }

  static Widget taskCurrency({double? width, double? height}) {
    return SvgPicture.asset(
      Get.isDarkMode
          ? "images/svg/task_currency.svg"
          : "images/svg/task_currency.svg",
      width: width,
      height: height,
    );
  }

  static Widget taskEtf({double? width, double? height}) {
    return SvgPicture.asset(
      Get.isDarkMode ? "images/svg/task_etf.svg" : "images/svg/task_etf.svg",
      width: width,
      height: height,
    );
  }

  static Widget taskFutures({double? width, double? height}) {
    return SvgPicture.asset(
      Get.isDarkMode
          ? "images/svg/task_futures.svg"
          : "images/svg/task_futures.svg",
      width: width,
      height: height,
    );
  }

  static Widget taskMargin({double? width, double? height}) {
    return SvgPicture.asset(
      Get.isDarkMode
          ? "images/svg/task_margin.svg"
          : "images/svg/task_margin.svg",
      width: width,
      height: height,
    );
  }

  static Widget taskEmptyData({double? width, double? height}) {
    return SvgPicture.asset(
      Get.isDarkMode
          ? "images/svg/public_img_task_empty.svg"
          : "images/svg/public_img_task_empty.svg",
      width: width,
      height: height,
    );
  }

  static Widget icCountdownBj() {
    return Image.asset(
      Get.isDarkMode
          ? "images/dark/ic_countdown_bj.png"
          : "images/light/ic_countdown_bj.png",
      width: 60,
      height: 60,
    );
  }
}
