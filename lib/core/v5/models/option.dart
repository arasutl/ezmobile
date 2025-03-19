import 'package:json_annotation/json_annotation.dart';

part 'option.g.dart';

@JsonSerializable(explicitToJson: true)
class Option {
  const Option({
    required this.label,
    required this.value,
  });

  factory Option.empty() => const Option(label: '', value: '');

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);

  final String label;
  final dynamic value;

  Map<String, dynamic> toJson() => _$OptionToJson(this);
}
