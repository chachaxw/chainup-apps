import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'ws_send_msg_entity.g.dart';

@JsonSerializable()
class WsSendMsgEntity {

	late String event;
	late WsSendMsgParams params;
  
  WsSendMsgEntity();

  factory WsSendMsgEntity.fromJson(Map<String, dynamic> json) => _$WsSendMsgEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WsSendMsgEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class WsSendMsgParams {

	late String channel;
	late String cb_id;
  
  WsSendMsgParams();

  factory WsSendMsgParams.fromJson(Map<String, dynamic> json) => _$WsSendMsgParamsFromJson(json);

  Map<String, dynamic> toJson() => _$WsSendMsgParamsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}