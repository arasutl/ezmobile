abstract class WorkflowRepository {
  Future<dynamic> getData();
  Future<dynamic> getWorkflowSections();
  Future<dynamic> getAllWorkflowTicketCount();
  Future<dynamic> getWorkflowTicketCountById(String workflowId);
  Future<dynamic> getMyInboxList(Map<String, dynamic> payload);
  Future<dynamic> getInboxList(Map<String, dynamic> payload, String workflowId);
  Future<dynamic> getFormData(String formId);
  Future<dynamic> getWorkflowData(int workflowId);
  Future<dynamic> getInboxItem(int workflowId, String processId, String transactionId);
  Future<dynamic> submitWorkflowForm(Map<String, dynamic> payload);
  Future<dynamic> workflowAttachments(int workflowId, int formId);
  Future<dynamic> workflowComments(int workflowId, int formEntryId);
  Future<dynamic> postWorkflowComment(
      int workflowId, int processId, int transactionId, Map<String, dynamic> payload);
  Future<dynamic> getFileSettings(int workflowId, int transactionId);
  Future<dynamic> uploadAttachments(List<Map<String, dynamic>> payloads);
  Future<dynamic> deleteAttachments(
      int repositoryId, int deletionType, Map<String, dynamic> payload);
  Future<dynamic> getProcessHistory(int workflowId, int processId);
  Future<dynamic> getAllForms(Map<String, dynamic> payload);
  Future<dynamic> getDynamicTaskForm(int formId);
  Future<dynamic> getTaskList(int workflowId, int processId, Map<String, dynamic> payload);
  Future<dynamic> getTaskListtask(int formId, Map<String, dynamic> payload);
  Future<dynamic> getTaskComments(int formId, int entryId);
  Future<dynamic> getTaskAttachments(int formId, int entryId);
  Future<dynamic> uploadTaskAttachments(List<Map<String, dynamic>> payloads);
  Future<dynamic> postTaskComments(int formId, int entryId, Map<String, dynamic> payload);
  Future<dynamic> taskComments(int formId, int entryId);
  Future<dynamic> deleteTaskAttachment(int repositoryId, Map<String, dynamic> payload);
  Future<dynamic> uploadAndIndex(List<Map<String, dynamic>> payloads);
  Future<dynamic> shareMailWithAttachments(Map<String, dynamic> payload);
  Future<dynamic> mergeFiles(int wId, int pId, int tId, int rId, Map<String, dynamic> payload);
  Future<dynamic> uploadForStaticMetadata(int rId, dynamic file, List<String> formFields);
  Future<dynamic> signWithProcessId(int wId, int pId, int tId, Map<String, dynamic> payload);
  Future<dynamic> signWithProcessIdList(int wId, int pId);
  Future<dynamic> workflowAuditWithSlaFields(int wId, Map<String, dynamic> payload);
  Future<dynamic> getRepositoryDetails(int repositoryId);
}
