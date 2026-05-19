import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/ws_send_msg_entity.dart';
import 'package:json_annotation/json_annotation.dart';


WsSendMsgEntity $WsSendMsgEntityFromJson(Map<String, dynamic> json) {
  final WsSendMsgEntity wsSendMsgEntity = WsSendMsgEntity();
  final String? event = jsonConvert.convert<String>(json['event']);
  if (event != null) {
    wsSendMsgEntity.event = event;
  }
  final WsSendMsgParams? params = jsonConvert.convert<WsSendMsgParams>(
      json['params']);
  if (params != null) {
    wsSendMsgEntity.params = params;
  }
  return wsSendMsgEntity;
}

Map<String, dynamic> $WsSendMsgEntityToJson(WsSendMsgEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['event'] = entity.event;
  data['params'] = entity.params.toJson();
  return data;
}

extension WsSendMsgEntityExtension on WsSendMsgEntity {
  WsSendMsgEntity copyWith({
    String? event,
    WsSendMsgParams? params,
  }) {
    return WsSendMsgEntity()
      ..event = event ?? this.event
      ..params = params ?? this.params;
  }
}

WsSendMsgParams $WsSendMsgParamsFromJson(Map<String, dynamic> json) {
  final WsSendMsgParams wsSendMsgParams = WsSendMsgParams();
  final String? channel = jsonConvert.convert<String>(json['channel']);
  if (channel != null) {
    wsSendMsgParams.channel = channel;
  }
  final String? cb_id = jsonConvert.convert<String>(json['cb_id']);
  if (cb_id != null) {
    wsSendMsgParams.cb_id = cb_id;
  }
  return wsSendMsgParams;
}

Map<String, dynamic> $WsSendMsgParamsToJson(WsSendMsgParams entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['channel'] = entity.channel;
  data['cb_id'] = entity.cb_id;
  return data;
}

extension WsSendMsgParamsExtension on WsSendMsgParams {
  WsSendMsgParams copyWith({
    String? channel,
    String? cb_id,
  }) {
    return WsSendMsgParams()
      ..channel = channel ?? this.channel
      ..cb_id = cb_id ?? this.cb_id;
  }
}