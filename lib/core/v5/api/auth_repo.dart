import 'package:dio/dio.dart';
import 'api.dart';

class AuthRepo {
  const AuthRepo();

  static Future<Response> login(Map<String, String> payload, String sUserEmail) {
    return Api().clientLogin(sUserEmail).post<dynamic>('validateMaster', data: payload);
  }

  static Future<Response> getUserDetails() {
    return Api().clientWithHeader().get<dynamic>('/authentication/userSession');
  }

  static Future<Response> getInboxListForFolder(int sWorkflowId, String payload, int sType) {
    switch (sType.toString()) {
      case '0':
        return Api()
            .clientWithHeader()
            .post<dynamic>('workflow/inboxList/$sWorkflowId', data: payload);

      case '1':
        return Api()
            .clientWithHeader()
            .post<dynamic>('workflow/processList/$sWorkflowId', data: payload);

      case '2':
        return Api()
            .clientWithHeader()
            .post<dynamic>('workflow/staredList/$sWorkflowId', data: payload);

      case '3':
        return Api()
            .clientWithHeader()
            .post<dynamic>('workflow/completedList/$sWorkflowId', data: payload);
    }

    return Api()
        .clientWithHeader()
        .post<dynamic>('workflow/inboxList/$sWorkflowId', data: payload); //7  or 6
  }

  static Future<Response> getInboxListMyInbox(
      String sWorkflowId, String sProcessId, String stransactionId, String sPayload) {
    return Api().clientWithHeader().post<dynamic>(
        '/mobile/workflow/inboxList/$sWorkflowId/$sProcessId/$stransactionId',
        data: sPayload);
  }

  static Future<Response> getCommentsList(int sWorkflowId, String sFormEntryId) {
    return Api()
        .clientWithHeader()
        .get<dynamic>('workflow/comments/$sWorkflowId/$sFormEntryId'); //7  or 6
  }

  static Future<Response> getFileList(int sWorkflowId, String sFormId) {
    return Api()
        .clientWithHeader()
        .get<dynamic>('workflow/attachmentList/$sWorkflowId/$sFormId'); //7  or 6
  }

  static Future<Response> getHistoryList(String sWorkflowId, String sFormEntryId) {
    return Api()
        .clientWithHeader()
        .get<dynamic>('workflow/processHistory/$sWorkflowId/$sFormEntryId'); //7  or 6
  }

  static Future<Response> getTaskList(int sWorkflowId, String sFormId, String payload) {
    return Api()
        .clientWithHeader()
        .post<dynamic>('workflow/taskList/$sWorkflowId/$sFormId', data: payload);
  }

  static Future<Response> postDeleteFiles(
      String sRepositoryId, String sFileIdsEncrypted, String sActionType, String sDeletionType) {
    return Api().clientWithHeader().post<dynamic>(
        'menu/file/delete/$sRepositoryId/$sActionType/$sDeletionType',
        data: sFileIdsEncrypted);
  }

  static Future<Response> getUserList(String payload) {
    return Api().clientWithHeader().post<dynamic>('user/list', data: payload);
  }

  static Future<Response> getUserProfilePhotoUpload(String payload) {
    return Api().clientWithHeader().post<dynamic>('user/avatarBinary', data: payload);
  }

  static Future<Response> postPasswordUpdate(String payload, String sUserId) {
    return Api().clientWithHeader().put<dynamic>('user/$sUserId', data: payload);
  }

  static Future<Response> getInboxSingleDetails(String sInboxID) {
    return Api().clientWithHeader().get<dynamic>(
          'form/$sInboxID',
        );
  }

  //workflow
  static Future<Response> postComments(
      String sWorkflowId, String sProcessId, String sTransactionId, String payload) {
    return Api()
        .clientWithHeader()
        .post<dynamic>('workflow/comments/$sWorkflowId/$sProcessId/$sTransactionId', data: payload);
  }

  static Future<Response> postAttachment(FormData payload) {
    return Api()
        .clientWithHeaderFile()
        .post<dynamic>('workflow/attachmentWithProcessId', data: payload);
  }

  static Future<Response> getTotalInboxCount() {
    return Api().clientWithHeader().get<dynamic>('workflow/myInboxCount');
  }

  static Future<Response> postWorkflow(String payload) {
    return Api().clientWithHeader().post<dynamic>('workflow/transaction', data: payload);
  }
}
