
import 'package:decimal/decimal.dart';
import 'package:library_kline/utils/klineCoinInfo.dart';
import 'package:library_kline/utils/storage_utils.dart';

import 'decimal_util.dart';

class NumberUtil {

  /**
   * @param needZh 是否需要处理中文
   * */
  static String customformat(double n,int fractionDigits,{bool? needZh}) {
    var isChinese = KLineCoinInfo.isChinese;
    var isNeedZh = true;
    if(needZh!=null){
      isNeedZh = needZh;
    }
    if (isChinese && isNeedZh){
      if (n >= 100000000) {
        n /= 100000000;
        return "${showSNormal(n.toString(), 2,isShowThous: true)}亿";
      } else if (n >= 10000) {
        n /= 10000;
        return "${showSNormal(n.toString(), 2,isShowThous: true)}万";
      } else {
        return showSNormal(n.toString(), fractionDigits,isShowThous: true);
      }
    }else {
      if (n >= 1000000000) {
        n /= 1000000000;
        return "${showSNormal(n.toString(), 2,isShowThous: true)}B";
        // return "${n.toStringAsFixed(2)}B";
      } else if (n >= 1000000) {
        n /= 1000000;
        return "${showSNormal(n.toString(), 2,isShowThous: true)}M";
      }  else if (n >= 1000) {
          n /= 1000;
          return "${showSNormal(n.toString(), 2,isShowThous: true)}K";
      } else {
        return showSNormal(n.toString(), fractionDigits,isShowThous: true);
        // return n.toStringAsFixed(4);
      }
    }
  }

  static String volFormat(double n) {
    // final pre = KLineCoinInfo.mSymbolPricePrecision;
    final pre = getContractMultiplierPrecisionByMultiplier(KLineCoinInfo.mMultiplier);
    return numberFormat(n.toString(),pre,isAmount: false);
  }

  //保留多少位小数
  static int _fractionDigits = 2;

  static set fractionDigits(int value) {
    if (value != _fractionDigits) _fractionDigits = value;
  }
  /**
   * @rounding 舍位
   * @digits  精度
   * */
  static String format(double price, {int digits = -1,bool rounding = false}) {
    final int digits0 = digits >= 0 ? digits : _fractionDigits;
    String newPrice = price.toString();
    if (rounding){
      String _price=(price).toStringAsFixed(digits0);
      newPrice = toRoundingString(_price.toString(),digits0);
    }
    return DecimalUtil.showSNormal(newPrice, isShowThous: true, digits: digits0);
    // return price.toStringAsFixed(_fractionDigits);
  }

  static String toRoundingString(String value,int digits){
    var sb = StringBuffer(value);
    if(value.contains(".")){
      var arr = value.split(".");
      var intValue = arr[0];
      var precisionValue = arr[1];
      if(digits<=0) return intValue.toString();
      if(precisionValue.length>=digits){
        sb = StringBuffer();
        sb.write(intValue);
        sb.write(".");
        sb.write(precisionValue.substring(0,digits));
      }else{
        sb = StringBuffer();
        sb.write(value);
        for(var i=0;i<(digits-precisionValue.length);i++){
          sb.write("0");
        }
      }
    }else{
      if(digits>0){
        sb.write(".");
        for(var i=0;i<digits;i++){
          sb.write("0");
        }
      }
    }

    return sb.toString();
  }


  static String showSNormal(dynamic? valueStr, int fractionDigits,
      {String? unit,bool? isShowPrefix,bool? isShowThous}) {
    String valuestr = double.tryParse(valueStr.toString()).toString();
    num? value = num.tryParse((valueStr ?? "0").toString());
    String valueBuffer = "0";
    if (value == null) return valueBuffer;
    if (fractionDigits == 0) {
      if (valuestr.lastIndexOf(".") != -1) {
        valueBuffer = valuestr.split(".")[0];
      } else {
        valueBuffer = valuestr;
      }
    } else {
      if (valuestr.lastIndexOf(".") == -1) {
        valueBuffer = value.toStringAsFixed(fractionDigits);
      } else {
        if ((valuestr.length - valuestr.lastIndexOf(".") - 1) <
            fractionDigits) {
          valueBuffer = value
              .toStringAsFixed(fractionDigits)
              .substring(0, valuestr.lastIndexOf(".") + fractionDigits + 1)
              .toString();
        } else {
          valueBuffer = valuestr
              .substring(0, valuestr.lastIndexOf(".") + fractionDigits + 1)
              .toString();
        }
      }
    }
    if(isShowThous==true){
      valueBuffer = thousThandToNumber(valueBuffer);
    }
    return unit == null ? valueBuffer : "${valueBuffer + " " + unit}";
  }


  /**
   * isAmount  成交额 以及 成交量需要该字段
   * isAmount  true  成交额 -需要乘以面值
   *           false 成交量 -需进行是张和币的换算
   *
   * */

  static String numberFormat(dynamic? valueStr,int digits, {bool? isAmount}){
    var valueBuffer = valueStr is String ? valueStr : valueStr.toString();
    var result = valueBuffer;
    int newDigits = digits;
    final faceValue = KLineCoinInfo.mMultiplier;
    if (isAmount != null){
      if (isAmount == true){ //成交额  乘以面值
        result = mulStr(result, faceValue, newDigits);
      }else{
        if (KLineCoinInfo.isCoin) { //如果是币
          result = mulStr(result, faceValue, newDigits);
        }else{
          newDigits = 0;
        }
      }
    }
    // print("valueStr => ${valueStr} faceValue => ${faceValue} digits = ${newDigits} reslut =>${result}");
    final dounleVale =  double.parse(result);
    return customformat(dounleVale, newDigits);
  }

  /// 乘
  static String mulStr(String a, String b, int fractionDigits,{bool? isShowPrefix}) {
    var buff = Decimal.parse(a) * Decimal.parse(b);
    return showSNormal(buff, fractionDigits,isShowPrefix: isShowPrefix);
  }

  static String thousThandToNumber(String number) {
    String formattedNumber = number;
    String? smallPoint; //小数部分
    if (formattedNumber.contains(".")){
      final arr = formattedNumber.split(".");
      formattedNumber = arr[0];
      smallPoint = arr[1];
    }
    List<String> parts = [];
    while (formattedNumber.length > 3) {
      parts.add(formattedNumber.substring(formattedNumber.length - 3));
      formattedNumber = formattedNumber.substring(0, formattedNumber.length - 3);
    }
    if (formattedNumber.isNotEmpty) {
      parts.add(formattedNumber);
    }
    parts = parts.reversed.toList();
    var result = parts.join(',');
    if (smallPoint != null){
      result = "$result.$smallPoint";
    }
    return result;
  }

   static int getContractMultiplierPrecisionByMultiplier(String multiplierBuff) {
    if (multiplierBuff.contains(".")) {
      int index = multiplierBuff.indexOf(".");
      int num = index < 0 ? 0 : multiplierBuff.length - index - 1;
      return num;
    } else {
      return 0;
    }
  }
}
