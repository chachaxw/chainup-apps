// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _ExchangeApi implements ExchangeApi {
  _ExchangeApi(
    this._dio, {
    this.baseUrl,
  });

  final Dio _dio;

  String? baseUrl;

  @override
  Future<BaseResultVx<UserInfoEntity>> getUserInfo(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<UserInfoEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-ex-api/common/user_info',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<UserInfoEntity>.fromJson(
      _result.data!,
      (json) => UserInfoEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<TaskCenterIndexEntity>> getTaskCenterIndex(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<TaskCenterIndexEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/task_center_index',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<TaskCenterIndexEntity>.fromJson(
      _result.data!,
      (json) => TaskCenterIndexEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<TaskCenterIndexEntity>> getTaskCenterIndexByNoToken(
      map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<TaskCenterIndexEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/no_token/task_center_index',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<TaskCenterIndexEntity>.fromJson(
      _result.data!,
      (json) => TaskCenterIndexEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<List<TaskInfoListEntity>>> getTaskInfoList(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<List<TaskInfoListEntity>>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/user_task_info_list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<List<TaskInfoListEntity>>.fromJson(
      _result.data!,
      (json) => (json as List<dynamic>)
          .map<TaskInfoListEntity>(
              (i) => TaskInfoListEntity.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
    return value;
  }

  @override
  Future<BaseResultVx<List<TaskInfoListEntity>>> getTaskInfoListByNoToken(
      map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<List<TaskInfoListEntity>>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/no_token/user_task_info_list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<List<TaskInfoListEntity>>.fromJson(
      _result.data!,
      (json) => (json as List<dynamic>)
          .map<TaskInfoListEntity>(
              (i) => TaskInfoListEntity.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
    return value;
  }

  @override
  Future<BaseResultVx<dynamic>> taskSignIn(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/do_daily_sign_in',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<dynamic>.fromJson(
      _result.data!,
      (json) => json as dynamic,
    );
    return value;
  }

  @override
  Future<BaseResultVx<dynamic>> claimTaskReward(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/claim_task_reward',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<dynamic>.fromJson(
      _result.data!,
      (json) => json as dynamic,
    );
    return value;
  }

  @override
  Future<BaseResultVx<RewardCenterIndexEntity>> getRewardCenterIndex(
      map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<RewardCenterIndexEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/reward_center_index',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<RewardCenterIndexEntity>.fromJson(
      _result.data!,
      (json) => RewardCenterIndexEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<WithdrawInfoListEntity>> getUserWithdrawList(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<WithdrawInfoListEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/user_withdraw_record_list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<WithdrawInfoListEntity>.fromJson(
      _result.data!,
      (json) => WithdrawInfoListEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<MarketCoinInfo>> getPublicInfoMarket(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<MarketCoinInfo>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-ex-api/common/public_info_market',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<MarketCoinInfo>.fromJson(
      _result.data!,
      (json) => MarketCoinInfo.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<TaskCenterRewardVoucherEntity>> getRewardVoucherList(
      map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<TaskCenterRewardVoucherEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/user_reward_voucher_list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<TaskCenterRewardVoucherEntity>.fromJson(
      _result.data!,
      (json) =>
          TaskCenterRewardVoucherEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<TaskCenterRewardRecordEntity>> getRewardRecordList(
      map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<TaskCenterRewardRecordEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/user_reward_record_list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<TaskCenterRewardRecordEntity>.fromJson(
      _result.data!,
      (json) =>
          TaskCenterRewardRecordEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<dynamic>> doWithdrawdReward(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/do_withdraw_reward',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<dynamic>.fromJson(
      _result.data!,
      (json) => json as dynamic,
    );
    return value;
  }

  @override
  Future<BaseResultVx<dynamic>> useRewardVoucher(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fe-task-api/do_use_reward_voucher',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<dynamic>.fromJson(
      _result.data!,
      (json) => json as dynamic,
    );
    return value;
  }

  @override
  Future<BaseResultVx<UserAssetProfitLossDataListEntity>> profitAndLossAnalysis(
      map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<UserAssetProfitLossDataListEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/assets/profit/lever/profit_and_loss_analysis',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<UserAssetProfitLossDataListEntity>.fromJson(
      _result.data!,
      (json) => UserAssetProfitLossDataListEntity.fromJson(
          json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<dynamic>> getAssetsChartData(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/singleCoin/getAssetsChartData',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<dynamic>.fromJson(
      _result.data!,
      (json) => json as dynamic,
    );
    return value;
  }

  @override
  Future<BaseResultVx<SingleCoinProfitEntity>> getProfitAndLossData(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<SingleCoinProfitEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/assets/profit/profit_and_loss_data',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<SingleCoinProfitEntity>.fromJson(
      _result.data!,
      (json) => SingleCoinProfitEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<ProfitAndLossDataResListEntity>> getProfitAndLossDataList(
      map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<ProfitAndLossDataResListEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/assets/profit/profit_and_loss_data_list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<ProfitAndLossDataResListEntity>.fromJson(
      _result.data!,
      (json) =>
          ProfitAndLossDataResListEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<dynamic>> getAssetConvertSymbolRate(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/assets/asset_convert_symbol_rate',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<dynamic>.fromJson(
      _result.data!,
      (json) => json as dynamic,
    );
    return value;
  }

  @override
  Future<BaseResultVx<dynamic>> getCanCustomDate(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<dynamic>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/assets/profit/can_custom_date',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<dynamic>.fromJson(
      _result.data!,
      (json) => json as dynamic,
    );
    return value;
  }

  @override
  Future<BaseResultVx<AccountBalanceEntity>> getAccountBalance(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<AccountBalanceEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/finance/v5/account_balance',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<AccountBalanceEntity>.fromJson(
      _result.data!,
      (json) => AccountBalanceEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<CoinAssetsLocationEntity>> getAssetDistribution(
      map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<CoinAssetsLocationEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/asset/getAssetDistribution',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<CoinAssetsLocationEntity>.fromJson(
      _result.data!,
      (json) => CoinAssetsLocationEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<CoinAssetsChartListEntity>> getCoinAssetsChartData(
      map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<CoinAssetsChartListEntity>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/asset/getAssetsChartData',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<CoinAssetsChartListEntity>.fromJson(
      _result.data!,
      (json) =>
          CoinAssetsChartListEntity.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<BaseResultVx<MarketCoinInfo>> getAppPublicInfoMarket(map) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<BaseResultVx<MarketCoinInfo>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/common/public_info_market',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BaseResultVx<MarketCoinInfo>.fromJson(
      _result.data!,
      (json) => MarketCoinInfo.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
