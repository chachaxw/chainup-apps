import '../entity/k_entity.dart';

class KLineEntity extends KEntity {
  late double open;
  late double high;
  late double low;
  late double close;
  late double vol;
  double? amount;
  int? count;
  int? id;

  bool? orderIsBuy;
  bool? orderIsSell;
  String? orderPrice;
  String? orderVol;


  KLineEntity(
      this.open,
      this.high,
      this.low,
      this.close,
      this.vol,
      this.amount,
      this.id,
  { this.orderIsBuy,
    this.orderIsSell,
    this.orderPrice,
    this.orderVol,}
      );

  KLineEntity.fromJson(Map<String, dynamic> json) {
    open = (json['open'] as num).toDouble();
    high = (json['high'] as num).toDouble();
    low = (json['low'] as num).toDouble();
    close = (json['close'] as num).toDouble();
    vol = (json['vol'] as num).toDouble();
    amount = (json['amount'] as num?)?.toDouble();
    count = json['count'] as int?;
    id = json['id'] as int?;
    orderIsBuy = json['orderIsBuy'] as bool?;
    orderIsSell = json['orderIsSell'] as bool?;
    orderPrice = json['orderPrice'] as String?;
    orderVol = json['orderVol'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['open'] = this.open;
    data['close'] = this.close;
    data['high'] = this.high;
    data['low'] = this.low;
    data['vol'] = this.vol;
    data['amount'] = this.amount;
    data['count'] = this.count;
    data['orderIsBuy'] = this.orderIsBuy;
    data['orderIsSell'] = this.orderIsSell;
    data['orderPrice'] = this.orderPrice;
    data['orderVol'] = this.orderVol;
    return data;
  }

  @override
  String toString() {
    return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, id: $id, orderIsBuy: $orderIsBuy, orderIsSell: $orderIsSell}';
  }
}
