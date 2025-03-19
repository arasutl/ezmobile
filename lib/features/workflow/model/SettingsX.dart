import 'package:ez/features/workflow/model/SpecificX.dart';

import 'GeneralX.dart';
import 'Validation.dart';

class SettingsX {
  GeneralX? general;
  SpecificX? specific;
  Validation? validation;

  SettingsX({this.general, this.specific, this.validation});

  factory SettingsX.fromJson(Map<String, dynamic> json) {
    return SettingsX(
        general: json['general'] != null ? GeneralX.fromJson(json['general']) : null,
        specific: json['specific'] != null ? SpecificX.fromJson(json['specific']) : null,
        validation: json['validation'] != null ? Validation.fromJson(json['validation']) : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (general != null) {
      data['general'] = general?.toJson();
    }
    if (specific != null) {
      data['specific'] = specific?.toJson();
    }
    if (validation != null) {
      data['validation'] = validation?.toJson();
    }
    return data;
  }
}
