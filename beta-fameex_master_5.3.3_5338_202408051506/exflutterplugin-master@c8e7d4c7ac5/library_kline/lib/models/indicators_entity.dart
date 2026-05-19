import 'package:chainup_flutter_ex/page/klineSetting/kline_indicator_manager.dart';
import 'package:flutter/widgets.dart';

class IndicatorsEntity {
  String? name;
  int? num;
  bool? isOpen;
  Color? lineColor;
  int? lineColorHex;
  KlineIndicatorType? type;
  IndicatorsEntity({
    required this.name,
    required this.num,
    required this.isOpen,
    required this.lineColor,
    required this.type,
    this.lineColorHex,
  });

  IndicatorsEntity.fromJson(Map<String, dynamic> json) {
    name = (json['name'] as String);
    num = (json['num'] as int);
    isOpen = (json['isOpen'] as bool);
    lineColorHex = ((json['lineColorHex'] ?? 0) as int);
    lineColor = Color((json['lineColorHex']) ?? 0 as int);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['num'] = this.num;
    data['isOpen'] = this.isOpen;
    data['lineColorHex'] = this.lineColor?.value;
    return data;
  }
}
