// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Option _$OptionFromJson(Map<String, dynamic> json) {
  return Option(
    label: json['label'] as String,
    value: json['value'],
  );
}

Map<String, dynamic> _$OptionToJson(Option instance) => <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
    };
