class PositionOrder {
  int? id;
  int? contractId;
  String? positionVolume;
  String? openAvgPrice;
  String? unRealizedAmount;
  String? orderSide;

  PositionOrder(
      {this.id,
        this.contractId,
        this.positionVolume,
        this.openAvgPrice,
        this.unRealizedAmount,
      this.orderSide});

  PositionOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    contractId = json['contractId'];
    positionVolume = json['positionVolume'].toString();
    openAvgPrice = json['openAvgPrice'].toString();
    unRealizedAmount = json['unRealizedAmount'].toString();
    orderSide = json['orderSide'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['contractId'] = this.contractId;
    data['positionVolume'] = this.positionVolume.toString();
    data['openAvgPrice'] = this.openAvgPrice.toString();
    data['unRealizedAmount'] = this.unRealizedAmount.toString();
    data['orderSide'] = this.orderSide.toString();
    return data;
  }
}
