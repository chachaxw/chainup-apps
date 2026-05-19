// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'depth_map_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepthMapEntity _$DepthMapEntityFromJson(Map<String, dynamic> json) =>
    DepthMapEntity()
      ..buys = (json['buys'] as List<dynamic>?)
          ?.map((e) => e as List<dynamic>)
          .toList()
      ..middle = json['middle']
      ..asks = (json['asks'] as List<dynamic>?)
          ?.map((e) => e as List<dynamic>)
          .toList();

Map<String, dynamic> _$DepthMapEntityToJson(DepthMapEntity instance) =>
    <String, dynamic>{
      'buys': instance.buys,
      'middle': instance.middle,
      'asks': instance.asks,
    };
