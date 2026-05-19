import 'dart:collection';

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 通用请求参数封装
class RequestParams {
  RequestParams();

  final Map<String, dynamic> _params = {};

  RequestParams put(String key, dynamic value) {
    if (value != null) {
      _params[key] = value;
    }
    return this;
  }

  void remove(String key) {
    _params.remove(key);
  }

  Map<String, dynamic> getRequestBody() {
    encryParameter(_params);
    return _params;
  }

  static  encryParameter(Map<String, dynamic> params) {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    params["time"] = timestamp.round().toString();
    SplayTreeMap<String, String> sortedMap = SplayTreeMap.from(params);
    List<String> array = [];
    for (final String key in sortedMap.keys) {
      // array.add("$key=${sortedMap[key]}");
      array.add(key);
      array.add(sortedMap[key].toString());
    }
    array.add("jiaoyisuo@2017");
    final resultString = array.join();
    // var key = utf8.encode("jiaoyisuo@2017");
    // var bytes = utf8.encode(resultString);
    // var hmacSha1 = Hmac(md5, key);
    // var digest = hmacSha1.convert(bytes);
    var uint8List=Utf8Encoder().convert(resultString);
    var digest= md5.convert(uint8List);
    params["sign"] = digest.toString();
  }
}
