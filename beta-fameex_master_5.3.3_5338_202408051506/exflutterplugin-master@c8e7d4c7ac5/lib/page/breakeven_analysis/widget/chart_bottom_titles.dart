import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:flutter/material.dart';

class ChartBottomTitles extends StatelessWidget {
  final List<String> dataList;
  const ChartBottomTitles({required this.dataList, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _childrenWidget(),
    );
  }

  List<Widget> _childrenWidget() {
    List<Widget> _children = [];
    if (dataList.isNotEmpty) {
      for (var i = 0; i < dataList.length; i++) {
        _children.add(_item(i, dataList[i].toString()));
      }
    }
    return _children;
  }

  _item(int idnex, String text) {
    return Builder(
      builder: (context) {
        return Text(
          text,
          style: ExThemes.textstyle_hr_color2_12(context),
        );
      },
    );
  }
}
