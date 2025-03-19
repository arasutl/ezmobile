class SelectedFileUpload {
  SelectedFileUpload(
      {required this.name,
      required this.size,
      required this.type,
      required this.file,
      required this.workflowId,
      required this.repositoryId,
      required this.processId,
      required this.transactionId,
      required this.fields});

  final String name;
  final String size;
  final String type;
  final dynamic file;
  final String workflowId;
  final String repositoryId;
  final String processId;
  final String transactionId;
  final String fields;
}
