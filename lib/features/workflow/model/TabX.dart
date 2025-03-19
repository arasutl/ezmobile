class TabX {
  String? id;
  String? label;
  int? panel;
  String? value;

  TabX({this.id, this.label, this.panel, this.value});

  factory TabX.fromJson(Map<String, dynamic> json) {
    return TabX(
      id: json['id'],
      label: json['label'],
      panel: json['panel'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['label'] = label;
    data['panel'] = panel;
    data['value'] = value;
    return data;
  }
}
