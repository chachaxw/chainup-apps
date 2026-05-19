import 'package:chainup_flutter_ex/models/reward_center_index_entity.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import '../../../constants/api_constant.dart';
import '../../../models/account_balance_entity.dart';
import '../../../models/coin_assets_chart_data_entity.dart';
import '../../../models/coin_assets_location_entity.dart';
import '../../../models/market_coin_entity.dart';
import '../../../models/query_profit_and_loss_entity.dart';
import '../../../models/task_center_index_entity.dart';
import '../../../models/task_center_reward_record_entity.dart';
import '../../../models/task_center_reward_voucher.dart';
import '../../../models/task_info_list_entity.dart';
import '../../../models/user_asset_profit_loss_data_lever_entity.dart';
import '../../../models/user_info_entity.dart';
import '../../../models/withdraw_list_item_entity.dart';
import '../dio_client.dart';
import '../result/base_result_vx.dart';

part 'exchange_api.g.dart';

@RestApi()
abstract class ExchangeApi {
  factory ExchangeApi({Dio? dio, String? baseUrl}) {
    dio ??= DioClient().dio;
    return _ExchangeApi(dio, baseUrl: baseUrl ?? ApiConstant.BASE_URL);
  }

  @POST("/fe-ex-api/common/user_info")
  Future<BaseResultVx<UserInfoEntity>> getUserInfo(
      @Body() Map<String, dynamic> map);

  @POST("/fe-task-api/task_center_index")
  Future<BaseResultVx<TaskCenterIndexEntity>> getTaskCenterIndex(
      @Body() Map<String, dynamic> map);

  @POST("/fe-task-api/no_token/task_center_index")
  Future<BaseResultVx<TaskCenterIndexEntity>> getTaskCenterIndexByNoToken(
      @Body() Map<String, dynamic> map);

  //用户任务列表
  @POST("/fe-task-api/user_task_info_list")
  Future<BaseResultVx<List<TaskInfoListEntity>>> getTaskInfoList(
      @Body() Map<String, dynamic> map);

  //用户任务列表
  @POST("/fe-task-api/no_token/user_task_info_list")
  Future<BaseResultVx<List<TaskInfoListEntity>>> getTaskInfoListByNoToken(
      @Body() Map<String, dynamic> map);

  //立即签到-每日签到
  @POST("/fe-task-api/do_daily_sign_in")
  Future<BaseResultVx> taskSignIn(@Body() Map<String, dynamic> map);

  //领取任务奖励
  @POST("/fe-task-api/claim_task_reward")
  Future<BaseResultVx> claimTaskReward(@Body() Map<String, dynamic> map);

  //奖励中心首页
  @POST("/fe-task-api/reward_center_index")
  Future<BaseResultVx<RewardCenterIndexEntity>> getRewardCenterIndex(
      @Body() Map<String, dynamic> map);

  //提现列表
  @POST("/fe-task-api/user_withdraw_record_list")
  Future<BaseResultVx<WithdrawInfoListEntity>> getUserWithdrawList(
      @Body() Map<String, dynamic> map);

  ///web获取币种
  @POST("/fe-ex-api/common/public_info_market")
  Future<BaseResultVx<MarketCoinInfo>> getPublicInfoMarket(
      @Body() Map<String, dynamic> map);

  ///获取奖励的优惠券列表
  @POST("/fe-task-api/user_reward_voucher_list")
  Future<BaseResultVx<TaskCenterRewardVoucherEntity>> getRewardVoucherList(
      @Body() Map<String, dynamic> map);

  ///获取奖励的明细列表
  @POST("/fe-task-api/user_reward_record_list")
  Future<BaseResultVx<TaskCenterRewardRecordEntity>> getRewardRecordList(
      @Body() Map<String, dynamic> map);

  ///奖励提现
  @POST("/fe-task-api/do_withdraw_reward")
  Future<BaseResultVx> doWithdrawdReward(@Body() Map<String, dynamic> map);

  ///使用优惠券
  @POST("/fe-task-api/do_use_reward_voucher")
  Future<BaseResultVx> useRewardVoucher(@Body() Map<String, dynamic> map);

  ///杠杆盈亏分析 查询
  @POST("/assets/profit/lever/profit_and_loss_analysis")
  Future<BaseResultVx<UserAssetProfitLossDataListEntity>> profitAndLossAnalysis(
      @Body() Map<String, dynamic> map);

  ///单币种 每日盈亏统计--盈亏折线图
  @POST("/singleCoin/getAssetsChartData")
  Future<BaseResultVx> getAssetsChartData(@Body() Map<String, dynamic> map);

  ///盈亏查询接口(区分时间,区分场景)
  @POST("/assets/profit/profit_and_loss_data")
  Future<BaseResultVx<SingleCoinProfitEntity>> getProfitAndLossData(
      @Body() Map<String, dynamic> map);

  ///批量查询盈亏 今日 7日 30日盈亏
  @POST("/assets/profit/profit_and_loss_data_list")
  Future<BaseResultVx<ProfitAndLossDataResListEntity>> getProfitAndLossDataList(
      @Body() Map<String, dynamic> map);

  ///汇率实时查询接口
  @POST("/assets/asset_convert_symbol_rate")
  Future<BaseResultVx> getAssetConvertSymbolRate(
      @Body() Map<String, dynamic> map);

  ///资产分析是否显示自定义筛选开关
  @POST("/assets/profit/can_custom_date")
  Future<BaseResultVx> getCanCustomDate(@Body() Map<String, dynamic> map);

  ///资产总额
  @POST("/finance/v5/account_balance")
  Future<BaseResultVx<AccountBalanceEntity>> getAccountBalance(
      @Body() Map<String, dynamic> map);

  ///每日盈亏统计--资产分布
  @POST("/asset/getAssetDistribution")
  Future<BaseResultVx<CoinAssetsLocationEntity>> getAssetDistribution(
      @Body() Map<String, dynamic> map);

  ///每日盈亏统计--盈亏折线图
  @POST("/asset/getAssetsChartData")
  Future<BaseResultVx<CoinAssetsChartListEntity>> getCoinAssetsChartData(
      @Body() Map<String, dynamic> map);

  ///app获取币种
  @POST("/common/public_info_market")
  Future<BaseResultVx<MarketCoinInfo>> getAppPublicInfoMarket(
      @Body() Map<String, dynamic> map);
}
