class Validation {
  List<Object>? allowedFileTypes;
  String? contentRule;
  List<EnableSettings>? enableSettings;
  String? fieldRule;
  int? maxFileSize;
  dynamic maximum;
  dynamic minimum;
  String? dateRange;
  String? timeRange;
  int? maxiDays;
  int? miniDays;
  int? maxiTime;
  int? miniTime;
  List<dynamic>? assignOtherControls;
  String? answerIndicator;
  List<dynamic>? mandatorySettings;
  List<dynamic>? readonlySettings;
  String? timeFormat;
  String? rangeType;
  String? maximumNumberField;

  Validation(
      {this.allowedFileTypes,
      this.contentRule,
      this.enableSettings,
      this.fieldRule,
      this.maxFileSize,
      this.maximum,
      this.minimum,
      this.dateRange,
      this.timeRange,
      this.maxiDays,
      this.miniDays,
      this.maxiTime,
      this.miniTime,
      this.assignOtherControls,
      this.answerIndicator,
      this.mandatorySettings,
      this.readonlySettings,
      this.timeFormat,
      this.rangeType,
      this.maximumNumberField});

  factory Validation.fromJson(Map<String, dynamic> json) {
    return Validation(
        allowedFileTypes: json['allowedFileTypes'] != null
            ? (json['allowedFileTypes'] as List).map((i) => Object).toList()
            : null,
        contentRule: json['contentRule'] ?? "",
        enableSettings: json['enableSettings'] != null
            ? (json['enableSettings'] as List).map((i) => EnableSettings.fromJson(i)).toList()
            : [],
        fieldRule: json['fieldRule'],
        maxFileSize: json['maxFileSize'],
        maximum: json['maximum'],
        minimum: json['minimum'],
        dateRange: json['dateRange'],
        timeRange: json['timeRange'],
        maxiDays: json['maxiDays'],
        miniDays: json['miniDays'],
        maxiTime: json['maxiTime'],
        miniTime: json['miniTime'],
        rangeType: json['rangeType'],
        maximumNumberField: json['maximumNumberField'],
        assignOtherControls: json["assignOtherControls"] ?? [],
        answerIndicator: json["answerIndicator"] ?? "",
        mandatorySettings: json["mandatorySettings"] ?? [],
        readonlySettings: json["readonlySettings"] ?? [],
        timeFormat: json["timeFormat"] ?? "12");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['contentRule'] = contentRule;
    data['fieldRule'] = fieldRule;
    data['maxFileSize'] = maxFileSize;
    data['maximum'] = maximum;
    data['minimum'] = minimum;
    if (allowedFileTypes != null) {
      data['allowedFileTypes'] = allowedFileTypes?.map((v) => v).toList();
    }
    if (enableSettings != null) {
      data['enableSettings'] = enableSettings?.map((v) => v).toList();
    }
    return data;
  }
}

class EnableSettings {
  String? id;
  String? value;
  List<String>? controls;

  EnableSettings({this.id, this.value, this.controls});

  EnableSettings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    value = json['value'];
    controls = json['controls'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['value'] = value;
    data['controls'] = controls;
    return data;
  }
}
