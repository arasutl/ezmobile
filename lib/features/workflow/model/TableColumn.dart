import 'package:ez/features/workflow/model/SettingsX.dart';

class TableColumn {
  String? id;
  String? label;
  SettingsX? settings;
  String? size;
  String? type;

  TableColumn({this.id, this.label, this.settings, this.size, this.type});

  factory TableColumn.fromJson(Map<String, dynamic> json) {
    return TableColumn(
      id: json['id'],
      label: json['label'],
      settings: json['settings'] != null
          ? SettingsX.fromJson(json['settings'])
          : null,
      size: json['size'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['label'] = label;
    data['size'] = size;
    data['type'] = type;
    if (settings != null) {
      data['settings'] = settings?.toJson();
    }
    return data;
  }
}
