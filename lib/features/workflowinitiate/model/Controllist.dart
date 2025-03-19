class Controllist {
  String? createdAt;
  String? createdBy;
  int? id;
  bool? isDeleted;
  bool? isMandatory;
  String? jsonId;
  String? modifiedAt;
  String? modifiedBy;
  String? name;
  int? parentId;
  String? type;
  int? wFormId;

  Controllist(
      {this.createdAt,
      this.createdBy,
      this.id,
      this.isDeleted,
      this.isMandatory,
      this.jsonId,
      this.modifiedAt,
      this.modifiedBy,
      this.name,
      this.parentId,
      this.type,
      this.wFormId});

  factory Controllist.fromJson(Map<String, dynamic> json) {
    return Controllist(
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
      id: json['id'],
      isDeleted: json['isDeleted'],
      isMandatory: json['isMandatory'],
      jsonId: json['jsonId'],
      modifiedAt: json['modifiedAt'],
      modifiedBy: json['modifiedBy'],
      name: json['name'],
      parentId: json['parentId'],
      type: json['type'],
      wFormId: json['wFormId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['createdBy'] = createdBy;
    data['id'] = id;
    data['isDeleted'] = isDeleted;
    data['isMandatory'] = isMandatory;
    data['jsonId'] = jsonId;
    data['modifiedBy'] = modifiedBy;
    data['name'] = name;
    data['parentId'] = parentId;
    data['type'] = type;
    data['wFormId'] = wFormId;
    data['modifiedAt'] = modifiedAt;

    return data;
  }
}
