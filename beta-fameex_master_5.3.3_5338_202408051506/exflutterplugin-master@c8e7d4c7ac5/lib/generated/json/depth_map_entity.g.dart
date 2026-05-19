import 'package:chainup_flutter_ex/generated/json/base/json_convert_content.dart';
import 'package:chainup_flutter_ex/models/depth_map_entity.dart';
import 'package:json_annotation/json_annotation.dart';


DepthMapEntity $DepthMapEntityFromJson(Map<String, dynamic> json) {
  final DepthMapEntity depthMapEntity = DepthMapEntity();
  final List<List>? buys = (json['buys'] as List<dynamic>?)?.map(
          (e) =>
          (e as List<dynamic>).map(
                  (e) => e).toList()).toList();
  if (buys != null) {
    depthMapEntity.buys = buys;
  }
  final dynamic middle = json['middle'];
  if (middle != null) {
    depthMapEntity.middle = middle;
  }
  final List<List>? asks = (json['asks'] as List<dynamic>?)?.map(
          (e) =>
          (e as List<dynamic>).map(
                  (e) => e).toList()).toList();
  if (asks != null) {
    depthMapEntity.asks = asks;
  }
  return depthMapEntity;
}

Map<String, dynamic> $DepthMapEntityToJson(DepthMapEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['buys'] = entity.buys;
  data['middle'] = entity.middle;
  data['asks'] = entity.asks;
  return data;
}

extension DepthMapEntityExtension on DepthMapEntity {
  DepthMapEntity copyWith({
    List<List>? buys,
    dynamic middle,
    List<List>? asks,
  }) {
    return DepthMapEntity()
      ..buys = buys ?? this.buys
      ..middle = middle ?? this.middle
      ..asks = asks ?? this.asks;
  }
}