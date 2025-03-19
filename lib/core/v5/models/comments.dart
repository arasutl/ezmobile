
class WorkflowCommentsData {
/*  processId:1082
  transactionId:2925
  comments:Test Comments
  externalCommentsby:
  createdAt:2023-09-08T06:59:40.40Z
  createdBy:8
  createdByEmail:raja@ezofis.com
  isDeleted:false*/

  dynamic sProcessId = 0;
  dynamic sTransactionId = 0;
  dynamic Comments = '';
  dynamic sExternalCommentsby = '';
  dynamic sCreatedAt = '';
  dynamic sCreatedBy = '';
  dynamic sCreatedByEmail = '';
  dynamic showTo = 1;
  bool bIsDeletes = false;
  WorkflowCommentsData(
      {required this.sProcessId,
      required this.sTransactionId,
      required this.Comments,
      required this.sExternalCommentsby,
      required this.sCreatedAt,
      required this.sCreatedBy,
      required this.sCreatedByEmail,
      required this.showTo,
      required this.bIsDeletes});

  WorkflowCommentsData.fromJson(Map<String, dynamic> json) {
    print(json);
    sProcessId = json['processId'];
    sTransactionId = json['transactionId'];
    Comments = json['comments'];
    sExternalCommentsby = json['externalCommentsby'];
    sCreatedAt =
        json['createdAt'].toString().substring(0, json['createdAt'].toString().indexOf('T') + 6);
    sCreatedByEmail = json['createdByEmail'];
    // bIsMe = json['createdBy'] == iLoginId;
    bIsDeletes = json['isDeleted'];
    sCreatedBy = json['createdBy'];
  }

  //String stringstudents = json.encode(commentsdatas);
  //print(commentsdatas.to);
}
