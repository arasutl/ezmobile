import 'package:ez/features/workflowinitiate/model/Controllist.dart';

class WorkFlowMain {
  List<Controllist>? controllist;
  String? createdAt;
  String? createdBy;
  String? description;
  int? entryCount;
  String? error;
  String? formJson;
  String? formTable;
  int? id;
  bool? isDeleted;
  int? isEdit;
  String? layout;
  String? modifiedAt;
  String? modifiedBy;
  String? name;
  String? publishOption;
  int? repositoryId;
  int? tenantId;
  String? type;

  WorkFlowMain(
      {this.controllist,
      this.createdAt,
      this.createdBy,
      this.description,
      this.entryCount,
      this.error,
      this.formJson,
      this.formTable,
      this.id,
      this.isDeleted,
      this.isEdit,
      this.layout,
      this.modifiedAt,
      this.modifiedBy,
      this.name,
      this.publishOption,
      this.repositoryId,
      this.tenantId,
      this.type});

  factory WorkFlowMain.fromJson(Map<String, dynamic> json) {
    return WorkFlowMain(
      controllist: json['controllist'] != null
          ? (json['controllist'] as List).map((i) => Controllist.fromJson(i)).toList()
          : null,
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
      description: json['description'],
      entryCount: json['entryCount'],
      error: json['error'],
      formJson: json['formJson'],
      formTable: json['formTable'],
      id: json['id'],
      isDeleted: json['isDeleted'],
      isEdit: json['isEdit'],
      layout: json['layout'],
      modifiedAt: json['modifiedAt'],
      modifiedBy: json['modifiedBy'],
      name: json['name'],
      publishOption: json['publishOption'],
      repositoryId: json['repositoryId'],
      tenantId: json['tenantId'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['createdBy'] = createdBy;
    data['description'] = description;
    data['entryCount'] = entryCount;
    data['error'] = error;
    data['formJson'] = formJson;
    data['formTable'] = formTable;
    data['id'] = id;
    data['isDeleted'] = isDeleted;
    data['isEdit'] = isEdit;
    data['layout'] = layout;
    data['modifiedAt'] = modifiedAt;
    data['modifiedBy'] = modifiedBy;
    data['name'] = name;
    data['publishOption'] = publishOption;
    data['repositoryId'] = repositoryId;
    data['tenantId'] = tenantId;
    data['type'] = type;
    if (controllist != null) {
      data['controllist'] = controllist?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
