// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) {
  return Session(
    key: json['key'] as String,
    token: json['token'] as String,
    iv: json['iv'] as String,
    twoFactorAuthentication: json['twoFactorAuthentication'],
  );
}

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
      'key': instance.key,
      'token': instance.token,
      'iv': instance.iv,
      'twoFactorAuthentication': instance.twoFactorAuthentication,
    };
