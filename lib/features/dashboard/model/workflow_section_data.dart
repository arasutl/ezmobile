class WorkflowSectionData {
  int? id;
  int? tenantId;
  String name = "";
  String? description;
  String? initiatedBy;
  int? repositoryId;
  int? wFormId;
  String? processColumns;
  String? prefix;
  int? genNo;
  String? flowJson;
  dynamic flowstatus;
  String? error;
  String? createdBy;
  String? createdAt;
  String? modifiedBy;
  String? modifiedAt;
  bool? isDeleted;
  int? inboxCount;
  int? processCount;
  int? completedCount;
  String? modifiedBlockIds;
  int? blockStatus;
  int? workspaceId;
  int? isEdit;
  int? hasSLASettings;
  List<dynamic>? completedInfo;
  int? paymentProcessCount;
  String? tokenUserId;
  String? completedQuery;
  String? jsonSettings;

  WorkflowSectionData(
      {this.id,
        this.tenantId,
        required this.name,
        this.description,
        this.initiatedBy,
        this.repositoryId,
        this.wFormId,
        this.processColumns,
        this.prefix,
        this.genNo,
        this.flowJson,
        this.flowstatus,
        this.error,
        this.createdBy,
        this.createdAt,
        this.modifiedBy,
        this.modifiedAt,
        this.isDeleted,
        this.inboxCount,
        this.processCount,
        this.completedCount,
        this.modifiedBlockIds,
        this.blockStatus,
        this.workspaceId,
        this.isEdit,
        this.hasSLASettings,
        this.completedInfo,
        this.paymentProcessCount,
        this.tokenUserId,
        this.completedQuery,
        this.jsonSettings});

  WorkflowSectionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tenantId = json['tenantId'];
    name = json['name'] ?? "";
    description = json['description'];
    initiatedBy = json['initiatedBy'];
    repositoryId = json['repositoryId'];
    wFormId = json['wFormId'];
    processColumns = json['processColumns'];
    prefix = json['prefix'];
    genNo = json['genNo'];
    flowJson = json['flowJson'];
    flowstatus = json['flowstatus'];
    error = json['error'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    modifiedBy = json['modifiedBy'];
    modifiedAt = json['modifiedAt'];
    isDeleted = json['isDeleted'];
    inboxCount = json['inboxCount'];
    processCount = json['processCount'];
    completedCount = json['completedCount'];
    modifiedBlockIds = json['modifiedBlockIds'];
    blockStatus = json['blockStatus'];
    workspaceId = json['workspaceId'];
    isEdit = json['isEdit'];
    hasSLASettings = json['hasSLASettings'];
    completedInfo = json['completedInfo'];
    paymentProcessCount = json['paymentProcessCount'];
    tokenUserId = json['tokenUserId'];
    completedQuery = json['completedQuery'];
    jsonSettings = json['jsonSettings'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tenantId'] = tenantId;
    data['name'] = name;
    data['description'] = description;
    data['initiatedBy'] = initiatedBy;
    data['repositoryId'] = repositoryId;
    data['wFormId'] = wFormId;
    data['processColumns'] = processColumns;
    data['prefix'] = prefix;
    data['genNo'] = genNo;
    data['flowJson'] = flowJson;
    data['flowstatus'] = flowstatus;
    data['error'] = error;
    data['createdBy'] = createdBy;
    data['createdAt'] = createdAt;
    data['modifiedBy'] = modifiedBy;
    data['modifiedAt'] = modifiedAt;
    data['isDeleted'] = isDeleted;
    data['inboxCount'] = inboxCount;
    data['processCount'] = processCount;
    data['completedCount'] = completedCount;
    data['modifiedBlockIds'] = modifiedBlockIds;
    data['blockStatus'] = blockStatus;
    data['workspaceId'] = workspaceId;
    data['isEdit'] = isEdit;
    data['hasSLASettings'] = hasSLASettings;
    data['completedInfo'] = completedInfo;
    data['paymentProcessCount'] = paymentProcessCount;
    data['tokenUserId'] = tokenUserId;
    data['completedQuery'] = completedQuery;
    data['jsonSettings'] = jsonSettings;
    return data;
  }
}