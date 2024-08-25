import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;

part 'barbershop.g.dart';


@JsonSerializable()
class Barbershop {
  final int? id;
  final String? name;
  final String? address;
  final double? x; // latitude
  final double? y; // longitude
  final String? tel;
  final String? thumUrl;
  final String? bizhourInfo;

  Barbershop({
    this.id,
    this.name,
    this.address,
    this.x,
    this.y,
    this.tel,
    this.thumUrl,
    this.bizhourInfo,
  });

  // Method to `fromJson` is useful for decoding an instance of `Barbershop` from a map
  factory Barbershop.fromJson(Map<String, dynamic> json) => _$BarbershopFromJson(json);
  Map<String, dynamic> toJson() => _$BarbershopToJson(this);
}
