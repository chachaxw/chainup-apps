
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'depth_map_entity.g.dart';
@JsonSerializable()
class DepthMapEntity {

	List<List>? buys;
	dynamic? middle;
	List<List>? asks;
  
  DepthMapEntity();

  factory DepthMapEntity.fromJson(Map<String, dynamic> json) => _$DepthMapEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DepthMapEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}