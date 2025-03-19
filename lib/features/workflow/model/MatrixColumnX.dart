class MatrixColumnX {
  String? id;
  String? label;

  MatrixColumnX({this.id, this.label});

  factory MatrixColumnX.fromJson(Map<String, dynamic> json) {
    return MatrixColumnX(
      id: json['id'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['label'] = label;
    return data;
  }
}
