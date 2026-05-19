import 'package:chainup_flutter_ex/constants/icon_constant.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/widgets/ex_refresh_loading.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:math' as math;

class ExSmartRefresher extends StatefulWidget {
  final Widget? child;

  /// header indicator displace before content
  ///
  /// If reverse is false,header displace at the top of content.
  /// If reverse is true,header displace at the bottom of content.
  /// if scrollDirection = Axis.horizontal,it will display at left or right
  ///
  /// from 1.5.2,it has been change RefreshIndicator to Widget,but remember only pass sliver widget,
  /// if you pass not a sliver,it will throw error
  final Widget? header;

  /// footer indicator display after content
  ///
  /// If reverse is true,header displace at the top of content.
  /// If reverse is false,header displace at the bottom of content.
  /// if scrollDirection = Axis.horizontal,it will display at left or right
  ///
  /// from 1.5.2,it has been change LoadIndicator to Widget,but remember only pass sliver widget,
  //  if you pass not a sliver,it will throw error
  final Widget? footer;
  // This bool will affect whether or not to have the function of drop-up load.
  final bool enablePullUp;

  /// controll whether open the second floor function
  final bool enableTwoLevel;

  /// This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePullDown;

  /// callback when header refresh
  ///
  /// when the callback is happening,you should use [RefreshController]
  /// to end refreshing state,else it will keep refreshing state
  final VoidCallback? onRefresh;

  /// callback when footer loading more data
  ///
  /// when the callback is happening,you should use [RefreshController]
  /// to end loading state,else it will keep loading state
  final VoidCallback? onLoading;

  /// callback when header ready to twoLevel
  ///
  /// If you want to close twoLevel,you should use [RefreshController.closeTwoLevel]
  final OnTwoLevel? onTwoLevel;

  /// Controll inner state
  final RefreshController controller;

  /// child content builder
  final RefresherBuilder? builder;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final Axis? scrollDirection;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final bool? reverse;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final ScrollController? scrollController;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final bool? primary;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final ScrollPhysics? physics;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final double? cacheExtent;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final int? semanticChildCount;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final DragStartBehavior? dragStartBehavior;

  const ExSmartRefresher(
      {Key? key,
      required this.controller,
      this.child,
      this.header,
      this.footer,
      this.enablePullDown = true,
      this.enablePullUp = false,
      this.enableTwoLevel = false,
      this.onRefresh,
      this.onLoading,
      this.onTwoLevel,
      this.dragStartBehavior,
      this.primary,
      this.cacheExtent,
      this.semanticChildCount,
      this.reverse,
      this.physics,
      this.scrollDirection,
      this.scrollController})
      : builder = null,
        super(key: key);

  @override
  State<ExSmartRefresher> createState() => _ExExSmartRefresherState();
}

class _ExExSmartRefresherState extends State<ExSmartRefresher> {
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: widget.controller,
      header: widget.header ??
          CustomHeader(
            builder: (context, mode) {
              String text = "";
              Widget icon = Container();
              switch (mode) {
                case RefreshStatus.idle:
                  text = "common_text_downToRefresh".tr;
                  icon = BreakevenAnalysisIcon.iconLoadingDropdown();
                  break;
                case RefreshStatus.canRefresh:
                  text = "common_text_triggerRefresh".tr;
                  icon = BreakevenAnalysisIcon.iconLoadingDropdown();
                  break;
                case RefreshStatus.refreshing:
                  text = "common_text_refreshing".tr;
                  icon = const RefreshLoadingWidget();
                  break;
                case RefreshStatus.completed:
                  text = "common_text_refresh_complete".tr;
                  icon = BreakevenAnalysisIcon.iconLoadingLoadedsuccessfully();
                  break;
                case RefreshStatus.failed:
                  text = "common_text_refresh_failed".tr;
                  icon = BreakevenAnalysisIcon.iconLoadingFailed();
                  break;
                // case RefreshStatus.canTwoLevel:
                //   text = "canTwoLevel";
                //   break;
                // case RefreshStatus.twoLevelOpening:
                //   text = "twoLevelOpening";
                //   break;
                // case RefreshStatus.twoLeveling:
                //   text = "twoLeveling";
                //   break;
                // case RefreshStatus.twoLevelClosing:
                //   text = "twoLevelClosing";
                //   break;
                default:
              }
              return Center(
                child: Column(
                  children: [
                    icon,
                    Gaps.vGap4,
                    Text(
                      text,
                      style: ExThemes.textstyle_hr_color1_12(context),
                    ),
                  ],
                ),
              );
            },
          ),
      footer: widget.footer ??
          CustomFooter(
            builder: (context, mode) {
              String text = "";
              Widget icon = Container();
              switch (mode) {
                case LoadStatus.idle:
                  text = "common_text_upToRefresh".tr;
                  icon = Transform.rotate(
                    angle: math.pi, // 旋转180度
                    child: BreakevenAnalysisIcon.iconLoadingDropdown(),
                  );
                  break;
                case LoadStatus.canLoading:
                  text = "common_text_triggerRefresh".tr;
                  icon = Transform.rotate(
                    angle: math.pi, // 旋转180度
                    child: BreakevenAnalysisIcon.iconLoadingDropdown(),
                  );
                  break;
                case LoadStatus.loading:
                  text = "common_text_refreshing".tr;
                  icon = const RefreshLoadingWidget();
                  break;
                case LoadStatus.failed:
                  text = "common_text_refresh_failed".tr;
                  icon = BreakevenAnalysisIcon.iconLoadingFailed();
                  break;
                case LoadStatus.noMore:
                  text = "common_text_refresh_complete".tr;
                  icon = BreakevenAnalysisIcon.iconLoadingLoadedsuccessfully();
                  break;
                default:
              }
              return Center(
                child: Column(
                  children: [
                    icon,
                    Gaps.vGap4,
                    Text(
                      text,
                      style: ExThemes.textstyle_hr_color1_12(context),
                    ),
                  ],
                ),
              );
            },
          ),
      enablePullDown: widget.enablePullDown,
      enablePullUp: widget.enablePullUp,
      enableTwoLevel: widget.enableTwoLevel,
      onRefresh: widget.onRefresh,
      onLoading: widget.onLoading,
      onTwoLevel: widget.onTwoLevel,
      dragStartBehavior: widget.dragStartBehavior,
      primary: widget.primary,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      reverse: widget.reverse,
      physics: widget.physics,
      scrollDirection: widget.scrollDirection,
      scrollController: widget.scrollController,
      child: widget.child,
    );
  }
}
