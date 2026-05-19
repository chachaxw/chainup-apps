class EntrustOrder {
  String? orderType;
  String? contractOtherName;
  String? positionType;
  String? orderId;
  String? type;
  String? dealVolume;
  String? price;
  String? triggerPrice;
  String? id;
  int? contractSide;
  int? pricePrecision;
  String? side;
  String? volume;
  String? contractId;
  String? open;
  int? triggerType;
  bool? isTriggerOrder;
  String? ctime;

  EntrustOrder(
      {
        this.orderType,
        this.contractOtherName,
        this.positionType,
        this.orderId,
        this.type,
        this.dealVolume,
        this.price,
        this.triggerPrice,
        this.id,
        this.contractSide,
        this.pricePrecision,
        this.side,
        this.volume,
        this.contractId,
        this.open,
        this.triggerType,
        this.isTriggerOrder,
        this.ctime
      });

  EntrustOrder.fromJson(Map<String, dynamic> json) {
    orderType = json['orderType'].toString();
    contractOtherName = json['contractOtherName'];
    positionType = json['positionType'].toString();
    orderId = json['orderId'];
    type = json['type'].toString();
    dealVolume = json['dealVolume'].toString();
    ctime = json['ctime'].toString();
    price = json['price'].toString();
    triggerPrice = json['triggerPrice'].toString();
    id = json['id'];
    contractSide = json['contractSide'];
    pricePrecision = json['pricePrecision'];
    side = json['side'];
    volume = json['volume'].toString();
    contractId = json['contractId'].toString();
    open = json['open'];
    isTriggerOrder = json['isTriggerOrder'];
    triggerType = json['triggerType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderType'] = this.orderType.toString();
    data['contractOtherName'] = this.contractOtherName;
    data['positionType'] = this.positionType.toString();
    data['orderId'] = this.orderId;
    data['type'] = this.type;
    data['dealVolume'] = this.dealVolume;
    data['price'] = this.price;
    data['triggerPrice'] = this.triggerPrice;
    data['id'] = this.id;
    data['contractSide'] = this.contractSide;
    data['pricePrecision'] = this.pricePrecision;
    data['side'] = this.side;
    data['volume'] = this.volume;
    data['contractId'] = this.contractId;
    data['open'] = this.open;
    data['triggerType'] = this.triggerType;
    data['isTriggerOrder'] = this.isTriggerOrder;
    data['ctime'] = this.ctime;
    return data;
  }
}