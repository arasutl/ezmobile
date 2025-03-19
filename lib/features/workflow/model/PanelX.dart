import 'Field.dart';
import 'SettingsXX.dart';

class PanelX {
  List<Field>? fields;
  String? id;
  SettingsXX? settings;

  PanelX({this.fields, this.id, this.settings});

  factory PanelX.fromJson(Map<String, dynamic> json) {
    return PanelX(
      fields: json['fields'] != null
          ? (json['fields'] as List).map((i) => Field.fromJson(i)).toList()
          : null,
      id: json['id'],
      settings: json['settings'] != null ? SettingsXX.fromJson(json['settings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (fields != null) {
      data['fields'] = fields?.map((v) => v.toJson()).toList();
    }
    if (settings != null) {
      data['settings'] = settings?.toJson();
    }
    return data;
  }
}
