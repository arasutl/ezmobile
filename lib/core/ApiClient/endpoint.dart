class EndPoint {
  //:- Api Urls
  // static const BaseUrl = "https://edmsuat.sobhaapps.com/SANDBOXAPI/api/";
  static const rootUrl = "https://eztapi.ezofis.com";
  static const BaseUrl = "https://eztapi.ezofis.com/api/";
  static const MainPortalURL = 'https://eztapi.ezofis.com/api/portal/';
  //:- method endpoints
  static const login = "authentication/login";
  static const loginsocialGoogle = "authentication/socialLogin";
  static const getuserDetails = "authentication/userSession";
  static const formworkflowinitiate = 'form/';
  static const api_taskList = '';

  //for Sobha
  static const getuserDetailsSobha = "profile/";

  static const workflowListByUserId = "workflow/listByUserId";
  static const dashboardWorkflowStatistics = "dashboard/workflow/";
  static const allWorkflowTicketCount = "overview/allworkflowticketCount";
  static const workflowTicketCountById = "overview/workflow/ticketCountByUserId/";
  static const myInboxList = "workflow/myInboxList";
  static const inboxList = "workflow/inboxList/";
  static const formData = "form/";
  static const workflowData = "workflow/";
  static const inboxItem = "mobile/workflow/inboxList/";
  static const workflowTransaction = "workflow/transaction";
  static const workflowAttachments = "workflow/attachmentList/";
  static const workflowFileSettings = "mobile/workflow/fileSettings/";
  static const workflowUploadAttachment = "workflow/attachmentWithProcessId";
  static const deleteWorkflowAttachment = "menu/file/delete/";
  static const processHistory = "workflow/processHistory/";
  static const allForms = "form/all";
  static const dynamicTaskForm = "form/";
  static const taskList = "workflow/taskList/";
  static const taskComments = "form/taskComments/";
  static const taskAttachments = "form/taskAttachmentList/";
  static const uploadTaskAttachmentWithEntryId = "form/taskAttachmentWithEntryId";
  static const uploadAndIndex = "uploadAndIndex/upload";
  static const globalSearch = "globalSearch";
  static const fileIndex = "file/indexValues";
  static const fileComments = "file/comments/";
  static const documentActivity = "report/repository/documentActivity/";
  static const repositoryDetails = "repository/";
  static const firebaseToken = "mobile/userDevice";
  static const avatarBinary = "user/avatarBinary";
  static const changePassword = "user/";
  static const shareMailWithAttachments = "MailSettings/ShareMailWithAttachments";
  static const mergeFiles = "file/mergeFiles/";
  static const uploadForStaticMetadata = "uploadAndIndex/uploadforStaticMetadata";
  static const signWithProcessId = "workflow/signWithProcessId/";
  static const signWithProcessIdList = "workflow/signWithProcessIdList/";
  static const allNotifications = "other/notification/all";
  static const notifications = "other/notification/";
  static const workflowAuditWithSlaFields = "report/workflowAuditWithSlaFields/";
  static const clearAllNotifications = "other/notification/clearAll/";
  static const taskList_task = "form/";
  static getPath(var method) {}
}
