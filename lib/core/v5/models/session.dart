import 'package:json_annotation/json_annotation.dart';

part 'session.g.dart';

@JsonSerializable(explicitToJson: true)
class Session {
  Session({
    required this.key,
    required this.token,
    required this.iv,
    required this.twoFactorAuthentication,
  });

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

  final String key;
  final String token;
  final String iv;
  final bool twoFactorAuthentication;

  Map<String, dynamic> toJson() => _$SessionToJson(this);
}
