import 'package:get_storage/get_storage.dart';

class ExStorageUtils1 {


  static final _GetStorage =  GetStorage();

  static const IS_DEBUG = "is_debug";
  static const DEBUG_IP = "debug_ip";
  static const DEBUG_PORT = "debug_port";
  static const PROXY_ENABLE = "proxy_enable";
  static const TOKEN = "token";
  static const LAN = "lan";
  static const THEME = "theme";
  static const QUICK_TOKEN = "quick_token";
  static const USER_INFO = "user_info";
  static const CURRENCY_BALANCE_LIST = "currency_balance_list";
  static const CONTRACT_BALANCE_LIST = "contract_balance_list";
  static const C2C_BALANCE_LIST = "c2c_balance_list";
  static const LEVER_BALANCE_LIST = "lever_balance_list";
  static const LOCAL_GESTURE_PASSWORD = "local_gesture_password";
  static const PUBLIC_INFO = "public_info";
  static const MARKET_INFO = "market_info";
  static const CONTRACT_PUBLIC_INFO = "contract_public_info";
  static const CONTRACT_PRICE_BASIS = "contract_price_basis";
  static const CONTRACT_USER_INFO = "contract_user_info";
  static const CONTRACT_CURRENT_CONTRACTID = "contract_current_contract_id";
  static const IS_HIDE_ASSETS = "is_hide_assets";
  static const FINGERPRINT_STATE = "fingerprint_state";
  static const KLINE_TIME_ID = "kline_time_id";
  static const RISE_FALL_COLOR = "rise_fall_color";
  static const C2C_PUBLIC_INFO = "c2c_public_info";

  static void  putObject(String key, Object value) {
     _GetStorage.write(key, value);
  }

  static String getString(String key) {
    return _GetStorage.read(key)??"";
  }

  static int getInt({required String key, int? def}) {
    return _GetStorage.read<int>(key)??(def??-1);
  }

  static void removeObject(String key) {
     _GetStorage.remove(key);
  }

  static bool getBoolean({required String key,bool? def}) {
    return _GetStorage.read<bool>(key) ?? def??false;
  }



  static void setKlineTimeId(int id) {
    ExStorageUtils1.putObject(ExStorageUtils1.KLINE_TIME_ID, id);
  }

  static int getKlineTimeId() {
    return ExStorageUtils1.getInt(key: ExStorageUtils1.KLINE_TIME_ID,def: 3);
  }

//存 write
//取 read
//删 remove
//清空所有 erase
}
