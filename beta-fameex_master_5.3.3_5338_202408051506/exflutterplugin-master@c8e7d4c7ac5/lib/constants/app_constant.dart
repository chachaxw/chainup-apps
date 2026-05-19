class AppConstant {
  static const SECRET = "jiaoyisuo@2017";

  static bool isZh = false;
  static String waterPath = "";


  /******************手机短信类型：START***********************/
  //手机号码注册
  static const REGISTER_MOBILE = 1;

  //绑定手机号码
  static const BIND_MOBILE = 2;

  //修改手机号码
  static const CHANGE_MOBILE = 3;

  //绑定邮箱
  static const BIND_EMAIL = 4;

  //设置资金密码
  static const SET_CAPITAL_PWD = 6;

  //修改资金密码
  static const CHANGE_CAPITAL_PWD = 7;

  //修改密码
  static const CHANGE_PWD = 9;

  //添加数字货币地址
  static const ADD_WITHDRAW_ADDRESS = 11;

  //修改&删除数字货币地址
  static const CHANGE_WITHDRAW_ADDRESS = 12;

  //数字货币提现
  static const CRYPTO_WITHDRAW = 13;

  //关闭手机验证
  static const CLOSE_MOBILE_VERIFY = 14;

  //修改邮箱
  static const CHANGE_EMAIL = 15;

  //找回密码
  static const FIND_PWD_MOBILE = 24;

  //手机登录
  static const MOBILE_LOGIN = 25;

  //关闭Google认证
  static const CLOASE_GOOGLE_VERIFY = 26;

  //开启或关闭手势密码
  static const GESTURE_PWD = 27;

  //添加收款方式
  static const ADD_PAYMENT_OTC = 28;

  //邮箱注册
  static const REGISTER_EMAIL = 1;

  //找回密码
  static const FIND_PWD_EMAIL = 3;

  //邮箱登录
  static const EMAIL_LOGIN = 4;

  //注销登录
  static const USER_LOGOUT = 222;


/***********邮箱短信类型：END************/

}

class PairSheetType {

  static const DEPOSIT = 1;

  static const WITHDRAWAL = 2;

  static const TRANSFER = 3;

}

class AccountType {

  static const SPOT_ACCOUNT = 1;

  static const C2C_ACCOUNT = 2;

  static const CO_ACCOUNT = 3;

  static const LEVERAGE_ACCOUNT = 4;

}

class LoginVerifyType {

  static const LOGIN_GOOOGLE = 1;

  static const LOGIN_PHONE = 2;

  static const LOGIN_EMAIL = 3;

}

class SecurityType {


  //绑定手机
  static const BIND_PHONE = 1000;

  //绑定GA
  static const BIND_GA = 1001;

  //开关手势登录
  static const OPEN_CLOSE_HANDPWD = 1002;

  //绑定邮箱
  static const BIND_EMAIL = 1003;

  //修改邮箱
  static const MODIFY_EMAIL = 1004;

  //修改手机
  static const MODIFY_PHONE = 1005;

  //关闭Google
  static const CLOSE_GA = 1006;

  //关闭手机
  static const CLOSE_PHONE = 1007;

  //添加收款方式
  static const ADD_PAYMENT_OTC = 1008;
}