

import 'package:chainup_flutter_ex/event/event.dart';
import 'package:flutter/cupertino.dart';

import '../routes/routes.dart';

/// 自定一个NavigatorObserver，用于监听 Route 事件
class EXRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    _onRouteChange(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _onRouteChange(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _onRouteChange(newRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _onRouteChange(route);
  }

  void _onRouteChange(Route? route) {
    /// 在这里去告诉原生是否可以开启侧滑返回手势
    /// 当canPop()为 true 时说明导航处于二级或多级界面，此时原生需要禁止原生的侧滑返回
    /// 当canPop()为 false 时说明导航处于一级界面，此时原生需要打开原生的侧滑返回
    // print('是否可以返回：${route?.navigator?.canPop()}');
    final canPop = route?.navigator?.canPop();

    Routes.pushNvEvent(
        ev: NvEvent.flutter_canPop, param: {"flutter_canPop": canPop});
    Event.eventBus.fire(MessageEvent(MessageEvent.navigationChange,
        pageName: route?.settings.name));
  }
}
