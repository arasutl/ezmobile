class SettingsXXX {
  String? description;
  String? title;

  SettingsXXX({this.description, this.title});

  factory SettingsXXX.fromJson(Map<String, dynamic> json) {
    return SettingsXXX(
      description: json['description'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['title'] = title;
    return data;
  }
}
