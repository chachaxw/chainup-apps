
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../base/controller/base_controller.dart';
import 'package:library_kline/utils/storage_utils.dart';
class DebugController extends BaseController {

  TextEditingController accountController=TextEditingController();
  TextEditingController pwdController=TextEditingController();
  final FocusNode accountFocusNode=FocusNode();
  final FocusNode pwdFocusNode=FocusNode();
  List<String> mHighlightStr=[];
  var isButtonEnable = false.obs;
  var mButtonStr = "保存代理".obs;

  @override
  void onInit() {
    super.onInit();
    mHighlightStr.clear();
    // mHighlightStr.add("ETH");
    mHighlightStr.add("ETH3S");
    mHighlightStr.add("ETH");
    mHighlightStr.add("etf_notes_multipleL".trParams({"number": "3"}));
    mHighlightStr.add("etf_notes_multipleS".trParams({"number": "3"}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    showSuccess();
    if(!ExStorageUtils.getString(ExStorageUtils.DEBUG_IP).isEmpty){
      accountController.text=ExStorageUtils.getString(ExStorageUtils.DEBUG_IP);
      pwdController.text=ExStorageUtils.getString(ExStorageUtils.DEBUG_PORT);
      isButtonEnable.value=true;
      mButtonStr.value=  "关闭代理";
    }
  }

  @override
  void loadNet() {
  }

  void setProxy(String ip,String port) {
    ExStorageUtils.putObject(ExStorageUtils.DEBUG_IP,ip);
    ExStorageUtils.putObject(ExStorageUtils.DEBUG_PORT,port);
    ExStorageUtils.putObject(ExStorageUtils.PROXY_ENABLE,!ip.isEmpty);
    mButtonStr.value= ip.isEmpty ? "保存代理" : "关闭代理";
    isButtonEnable.value=ip.isEmpty ? false : true;

  }

}
