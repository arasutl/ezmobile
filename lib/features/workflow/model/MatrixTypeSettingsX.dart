import 'package:ez/features/workflow/model/SettingsX.dart';

class MatrixTypeSettingsX {

  String? id;
  String? label;
  String? type;
  SettingsX? settings;

  MatrixTypeSettingsX({this.id, this.label, this.type,this.settings});

  MatrixTypeSettingsX.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    type = json['type'];
    settings = json['settings'] != null
        ? SettingsX.fromJson(json['settings'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['label'] = label;
    data['type'] = type;
    if (settings != null) {
      data['settings'] = settings?.toJson();
    }
    return data;
  }
}
