class InboxDetails {
  final String requestNo;
  final String stage, raisedAt, raisedBy;
  final dynamic lastAction;
  final int processId;
  final int? formId;
  final int? formEntryId;
  final String activityId;
  final String transaction_createdAt;
  final int transactionId;

  final bool bread;
  final dynamic formData;
  final int attachmentCount;
  final int commentsCount;
  final List<dynamic>? subWorkflowTransactions;

  InboxDetails(
      {required this.requestNo,
      required this.stage,
      required this.raisedAt,
      required this.transaction_createdAt,
      required this.raisedBy,
      required this.lastAction,
      required this.processId,
      this.formEntryId,
      this.formId,
      required this.activityId,
      required this.transactionId,
      required this.formData,
      required this.bread,
      required this.attachmentCount,
      required this.commentsCount,
      this.subWorkflowTransactions});

  factory InboxDetails.fromJson(Map<String, dynamic> json) {

    return InboxDetails(
        requestNo: json['requestNo'],
        stage: json['stage'] ?? json['stageName'] ?? "",
        raisedAt: json['raisedAt'],
        raisedBy: json['raisedBy'],
        transaction_createdAt: json['transaction_createdAt'] ?? json["raisedAt"] ?? "",
        lastAction: json['lastAction'],
        processId: json['processId'],
        formEntryId: json['formData']?['formEntryId'],
        activityId: json['activityId'],
        transactionId: json['transactionId'],
        formId: json['formData']?['formId'],
        formData: json['formData'],
        attachmentCount: json['attachmentCount'],
        commentsCount: json['commentsCount'],
        subWorkflowTransactions: (json['subworkflowTransaction'] ?? [] ).map((elm) => InboxDetails.fromJson(elm)).toList(),
        bread: true);
  }
}
