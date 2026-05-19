// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_send_msg_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WsSendMsgEntity _$WsSendMsgEntityFromJson(Map<String, dynamic> json) =>
    WsSendMsgEntity()
      ..event = json['event'] as String
      ..params =
          WsSendMsgParams.fromJson(json['params'] as Map<String, dynamic>);

Map<String, dynamic> _$WsSendMsgEntityToJson(WsSendMsgEntity instance) =>
    <String, dynamic>{
      'event': instance.event,
      'params': instance.params,
    };

WsSendMsgParams _$WsSendMsgParamsFromJson(Map<String, dynamic> json) =>
    WsSendMsgParams()
      ..channel = json['channel'] as String
      ..cb_id = json['cb_id'] as String;

Map<String, dynamic> _$WsSendMsgParamsToJson(WsSendMsgParams instance) =>
    <String, dynamic>{
      'channel': instance.channel,
      'cb_id': instance.cb_id,
    };
