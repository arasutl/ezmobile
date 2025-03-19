class Settings {
  String? description;
  String? title;
  List<Rules>? rules;

  Settings({this.description, this.title, this.rules});

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
        description: json['description'],
        title: json['title'],
        rules: json['rules'] != null
            ? (json['rules'] as List).map((i) => Rules.fromJson(i)).toList()
            : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['title'] = title;
    return data;
  }
}

class Rules {
  String? id;
  bool? isConditionalRule;
  String? name;
  // List<dynam>? conditions;
  List<Calculations>? calculations;

  Rules(
      {this.id,
      this.isConditionalRule,
      this.name,
      // this.conditions,
      this.calculations});

  Rules.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isConditionalRule = json['isConditionalRule'];
    name = json['name'];
    // if (json['conditions'] != null) {
    //   conditions = <Null>[];
    //   json['conditions'].forEach((v) {
    //     conditions!.add(new Null.fromJson(v));
    //   });
    // }
    if (json['calculations'] != null) {
      calculations = <Calculations>[];
      json['calculations'].forEach((v) {
        calculations!.add(Calculations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isConditionalRule'] = isConditionalRule;
    data['name'] = name;
    // if (this.conditions != null) {
    //   data['conditions'] = this.conditions!.map((v) => v.toJson()).toList();
    // }
    if (calculations != null) {
      data['calculations'] = calculations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Calculations {
  String? id;
  String? fieldId;
  String? columnId;
  List<Formula>? formula;

  Calculations({this.id, this.fieldId, this.columnId, this.formula});

  Calculations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fieldId = json['fieldId'];
    columnId = json['columnId'];
    if (json['formula'] != null) {
      formula = <Formula>[];
      json['formula'].forEach((v) {
        formula!.add(Formula.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fieldId'] = fieldId;
    data['columnId'] = columnId;
    if (formula != null) {
      data['formula'] = formula!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Formula {
  String? id;
  String? name;
  String? label;
  String? value;

  Formula({this.id, this.name, this.label, this.value});

  Formula.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    label = json['label'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['label'] = label;
    data['value'] = value;
    return data;
  }
}

class Publish {
  String? publishOption;
  String? publishSchedule;
  String? unpublishSchedule;

  Publish({this.publishOption, this.publishSchedule, this.unpublishSchedule});

  Publish.fromJson(Map<String, dynamic> json) {
    publishOption = json['publishOption'];
    publishSchedule = json['publishSchedule'];
    unpublishSchedule = json['unpublishSchedule'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['publishOption'] = publishOption;
    data['publishSchedule'] = publishSchedule;
    data['unpublishSchedule'] = unpublishSchedule;
    return data;
  }
}
