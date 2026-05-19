part of ex_icon_library;

class BreakevenAnalysisIcon {
  static Widget eyeIcon() {
    return Image.asset(
      Get.isDarkMode
          ? "images/dark/breakeven_analysis_eyeon_dark.png"
          : "images/light/breakeven_analysis_eyeon_light.png",
      width: 16,
      height: 16,
    );
  }

  static Widget assetsEyeoff() {
    return Image.asset(
      Get.isDarkMode
          ? "images/dark/assets_eyeoff.png"
          : "images/light/assets_eyeoff.png",
      width: 16,
      height: 16,
    );
  }

  static Widget hintIcon() {
    return Image.asset(
      Get.isDarkMode
          ? "images/dark/public_hint_10.png"
          : "images/light/public_hint_10.png",
      width: 10,
      height: 10,
    );
  }

  static Image iconLoadingDropdown(
      {double? width = 20, double? height = 20, Color? color}) {
    return Image.asset(
      Get.isDarkMode
          ? "images/dark/icon_loading_dropdown_dark.png"
          : "images/light/icon_loading_dropdown_light.png",
      height: width,
      width: height,
      color: color,
    );
  }

  static Image iconLoadingLoadedsuccessfully(
      {double? width = 20, double? height = 20, Color? color}) {
    return Image.asset(
      Get.isDarkMode
          ? "images/dark/ic_loading_loadedsuccessfully_dark.png"
          : "images/light/ic_loading_loadedsuccessfully_light.png",
      height: width,
      width: height,
      color: color,
    );
  }

  static Image iconLoading(
      {double? width = 20, double? height = 20, Color? color}) {
    return Image.asset(
      Get.isDarkMode
          ? "images/dark/ic_loading_dark.png"
          : "images/light/ic_loading_light.png",
      height: width,
      width: height,
      color: color,
    );
  }

  static Widget iconLoadingFailed({double? width = 20, double? height = 20}) {
    return SvgPicture.asset(
      Get.isDarkMode
          ? "images/svg/ic_loading_failed_dark.svg"
          : "images/svg/ic_loading_failed_light.svg",
      width: width,
      height: height,
    );
  }
}
