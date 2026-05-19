import 'package:get_storage/get_storage.dart';

class ExStorageUtils {
  static final _GetStorage = GetStorage();

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
  static const KLINE_TIME_scale = "kline_time_scale";
  static const RISE_FALL_COLOR = "rise_fall_color";
  static const C2C_PUBLIC_INFO = "c2c_public_info";
  static const KLINE_INDICATOS_MA = "kline_indicatos_ma";
  static const KLINE_INDICATOS_EMA = "kline_indicatos_ema";
  static const KLINE_TIME_SHOW_LIST = "show_kline_detail_list";
  static const KLINE_MAIN_INDICATOS_SELECT_LIST =
      "show_kline_main_indicatos_list";
  static const KLINE_SEC_INDICATOS_SELECT_LIST =
      "show_kline_secondary_indicatos_list";
  static const KLINE_VOL_INDICATOS_SELECT_STATUS =
      "show_kline_vol_indicatos_status";
  static const KLINE_ORDER_VISIBLE_STATUS = "kline_order_visible";
  static const KLINE_HOLD_COST_VISIBLE_STATUS = "KLINE_HOLD_COST_VISIBLE_STATUS";
  static const KLINE_HISTORICAL_COMMISSION_VISIBLE_STATUS = "KLINE_HISTORICAL_COMMISSION_VISIBLE_STATUS";
  static const KLINE_V_GUIDE1_STATUS = "kline_v_guide1";
  static const COIN_ANALYSIS_COIN_SYMBOLS = "coinAnalysisCoinSymbols";

  static const MARGIN_ANALYSIS_TYPE = "marginAnalysisType";
  static const SHOW_OR_HIDE_ASSETS_AMOUNT = "showOrHideAssetsAmount";
  static const UUID_CU = "UUID-CU";
  static const DEVICE = "device";
  static const LOCAL_ASSET_CONVERT_SYMBOL_RATE =
      "local_asset_convert_symbol_rate"; //本地缓存汇率信息

  static void putObject(String key, Object value) {
    _GetStorage.write(key, value);
  }

  static Object? getObject(String key, {Object? def}) {
    return _GetStorage.read(key) ?? def;
  }

  static String getString(String key) {
    return _GetStorage.read(key) ?? "";
  }

  static int getInt({required String key, int? def}) {
    return _GetStorage.read<int>(key) ?? (def ?? -1);
  }

  static void removeObject(String key) {
    _GetStorage.remove(key);
  }

  static bool getBoolean({required String key, bool? def}) {
    return _GetStorage.read<bool>(key) ?? def ?? false;
  }

  static void setKlineTimeId(int id) {
    ExStorageUtils.putObject(ExStorageUtils.KLINE_TIME_ID, id);
  }

  static void setKlineTimeScale(String scale) {
    ExStorageUtils.putObject(ExStorageUtils.KLINE_TIME_scale, scale);
  }

  static String getKlineTimeScale() {
    return ExStorageUtils.getObject(ExStorageUtils.KLINE_TIME_scale,
        def: "15min") as String;
  }

  static int getKlineTimeId() {
    return ExStorageUtils.getInt(key: ExStorageUtils.KLINE_TIME_ID, def: 3);
  }

//存 write
//取 read
//删 remove
//清空所有 erase
}
