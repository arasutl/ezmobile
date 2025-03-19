class GeneralX {
  String? dividerType;
  bool? hideLabel;
  String? placeholder;
  String? size;
  String? tooltip;
  String? visibility;
  String? url;

  GeneralX(
      {this.dividerType,
      this.hideLabel,
      this.placeholder,
      this.size,
      this.tooltip,
      this.url,
      this.visibility});

  factory GeneralX.fromJson(Map<String, dynamic> json) {
    return GeneralX(
      dividerType: json['dividerType'],
      hideLabel: json['hideLabel'],
      placeholder: json['placeholder'],
      size: json['size'],
      tooltip: json['tooltip'],
      visibility: json['visibility'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dividerType'] = dividerType;
    data['hideLabel'] = hideLabel;
    data['placeholder'] = placeholder;
    data['size'] = size;
    data['tooltip'] = tooltip;
    data['visibility'] = visibility;
    data['url'] = url;
    return data;
  }
}
