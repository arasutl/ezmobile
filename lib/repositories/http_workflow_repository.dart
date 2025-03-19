import 'dart:convert';
import 'dart:math';

import 'package:ez/core/ApiClient/endpoint.dart';
import 'package:ez/core/v5/api/api.dart';
import 'package:ez/core/v5/models/comments.dart';
import 'package:ez/core/v5/utils/helper/aes_encryption.dart';
import 'package:ez/features/dashboard/model/workflow_section_data.dart';
import 'package:ez/features/workflow/model/Panel.dart';
import 'package:ez/repositories/workflow_repository.dart';
import 'package:get/get.dart';

import '../core/ApiClient/ApiService.dart';
import '../core/v5/models/popup/controllers/attachfilecontroller.dart';
import '../core/v5/models/popup/controllers/workflow_detail_controller.dart';
import 'package:dio/dio.dart' as Dio;

class HttpWorkflowRepository implements WorkflowRepository {
  HttpWorkflowRepository();

  @override
  Future<dynamic> getData() async {
    try {
      // Call the getUsers() method from the ApiService to fetch user data from the API.
      final controllerpopup = Get.put(WorkflowDetailController());
      // Map the API response data to a List of data objects using the User.fromJson() constructor.
      Map<String, dynamic> datajson = controllerpopup.sFormJSon;
      final result = Panel.fromJson(datajson);
      return result;
    } catch (e) {
      // If an exception occurs during the API call, throw an exception with an error message.
      throw Exception('Failed to fetch users');
    }
  }

  @override
  Future<List<WorkflowSectionData>> getWorkflowSections() async {
    var response = await Api()
        .clientWithHeader(responseType: Dio.ResponseType.plain)
        .get(EndPoint.workflowListByUserId);

    String responseStr = AaaEncryption.decryptAESaaa(response.data);
    List<WorkflowSectionData> workflowSectionDataList = (json.decode(responseStr) as List<dynamic>)
        .map((e) => WorkflowSectionData.fromJson(e))
        .toList();

    return workflowSectionDataList;
  }

  @override
  Future<Map<String, dynamic>> getAllWorkflowTicketCount() async {
    var response = await Api()
        .clientWithHeader(responseType: Dio.ResponseType.plain)
        .get(EndPoint.allWorkflowTicketCount);
    if (response.statusCode == 200) {
      String responseStr = AaaEncryption.decryptAESaaa(response.data);
      Map<String, dynamic> allWorkflowTicketCount =
          json.decode(responseStr) as Map<String, dynamic>;
      return allWorkflowTicketCount;
    } else {
      return {};
    }
  }

  @override
  Future getWorkflowTicketCountById(String workflowId) async {
    var response = await Api()
        .clientWithHeader(responseType: Dio.ResponseType.plain)
        .get(EndPoint.workflowTicketCountById + workflowId);
    String responseStr = AaaEncryption.decryptAESaaa(response.data);
    Map<String, dynamic> workflowTicketCount = json.decode(responseStr) as Map<String, dynamic>;
    return workflowTicketCount;
  }

  @override
  Future getMyInboxList(Map<String, dynamic> payload) async {
    var response = await Api().clientWithHeader(responseType: Dio.ResponseType.plain).post(
        EndPoint.myInboxList,
        data: jsonEncode(AaaEncryption.EncryptData(jsonEncode(payload))));
    Map<String, dynamic> myInboxList = jsonDecode(AaaEncryption.decryptAESaaa(response.data));
    return myInboxList;
  }

  @override
  Future getInboxList(Map<String, dynamic> payload, String workflowId) async {
    var response = await Api().clientWithHeader(responseType: Dio.ResponseType.plain).post(
        EndPoint.inboxList + workflowId,
        data: jsonEncode(AaaEncryption.EncryptData(jsonEncode(payload))));
    Map<String, dynamic> inboxList = jsonDecode(AaaEncryption.decryptAESaaa(response.data));
    return inboxList;
  }

  @override
  Future getFormData(String formId) async {
    var response = await Api()
        .clientWithHeader(responseType: Dio.ResponseType.plain)
        .get(EndPoint.formData + formId);
    String data = response.data;
    Map<String, dynamic> formData = jsonDecode(AaaEncryption.decryptAESaaa(data));
    return formData;
  }

  @override
  Future<Map<String, dynamic>> getWorkflowData(int workflowId) async {
    try {
      var response = await Api()
          .clientWithHeader(responseType: Dio.ResponseType.plain)
          .get("${EndPoint.workflowData}$workflowId");

      // Log the raw response to verify
      print("Raw Response: ${response.data}");

      // Decrypt the response and parse it into a map
      Map<String, dynamic> workflowData = jsonDecode(AaaEncryption.decryptAESaaa(response.data));

      return workflowData;
    } catch (e) {
      print("Error fetching workflow data: $e");
      rethrow;
    }
  }

  @override
  Future getInboxItem(int workflowId, String processId, String transactionId) async {
    var response = await Api()
        .clientWithHeader(responseType: Dio.ResponseType.plain)
        .post("${EndPoint.inboxItem}$workflowId/$processId/$transactionId");
    Map<String, dynamic> workflowData = jsonDecode(AaaEncryption.decryptAESaaa(response.data));
    return workflowData;
  }

  @override
  Future submitWorkflowForm(Map<String, dynamic> payload) async {
    try {
      var response = await Api().clientWithHeader(responseType: Dio.ResponseType.plain).post(
          EndPoint.workflowTransaction,
          data: jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payload))));
      Map<String, dynamic> workflowData = jsonDecode(AaaEncryption.decryptAESaaa(response.data));
      return workflowData;
    } catch (e) {
      return null;
    }
  }

  @override
  Future workflowAttachments(int workflowId, int formId) async {
    var response = await Api()
        .clientWithHeader()
        .get<dynamic>('${EndPoint.workflowAttachments}$workflowId/$formId');
    String dec = AaaEncryption.decryptAESaaa(response.data.toString());
    List<dynamic> json = jsonDecode(dec);
    List<AttachmentData> files = json.map((tagJson) => AttachmentData.fromJson(tagJson)).toList();
    return files;
  }

  @override
  Future workflowComments(int workflowId, int formEntryId) async {
    var response =
        await Api().clientWithHeader().get<dynamic>('workflow/comments/$workflowId/$formEntryId');
    String dec = AaaEncryption.decryptAESaaa(response.data.toString());
    List<dynamic> json = jsonDecode(dec);

    List<WorkflowCommentsData> workflowCommentsList =
        json.map((tagJson) => WorkflowCommentsData.fromJson(tagJson)).toList();
    return workflowCommentsList;
  }

  @override
  Future postWorkflowComment(
      int workflowId, int processId, int transactionId, Map<String, dynamic> payload) async {
    var response = await Api().clientWithHeader().post<dynamic>(
        'workflow/comments/$workflowId/$processId/$transactionId',
        data: jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payload))));

    String dec = AaaEncryption.decryptAESaaa(response.data.toString());

    return dec;
  }

  @override
  Future getFileSettings(int workflowId, int transactionId) async {
    try {
      var response = await Api()
          .clientWithHeader(responseType: Dio.ResponseType.plain)
          .post<dynamic>("${EndPoint.workflowFileSettings}$workflowId/$transactionId");

      String dec = AaaEncryption.decryptAESaaa(response.data.toString());
      List<dynamic> json = jsonDecode(jsonDecode(dec));
      return json;
    } catch (e) {
      if (e is Dio.DioException) {
        return [];
      }
    }

    return [];
  }

  @override
  Future uploadAttachments(List<Map<String, dynamic>> payloads) async {
    var responses = [];
    for (var payload in payloads) {
      var response = await Api()
          .clientWithHeaderFile()
          .post<dynamic>(EndPoint.workflowUploadAttachment, data: Dio.FormData.fromMap(payload));
      responses.add(response);
    }
    return responses;
  }

  @override
  Future deleteAttachments(int repositoryId, int deletionType, Map<String, dynamic> payload) async {
    String pay = jsonEncode(payload);
    var response = await Api().clientWithHeader().post(
        "${EndPoint.deleteWorkflowAttachment}$repositoryId/$deletionType",
        data: jsonEncode(AaaEncryption.EncryptData(pay)));
    return response;
  }

  @override
  Future getProcessHistory(int workflowId, int processId) async {
    try {
      var response = await Api()
          .clientWithHeader()
          .get<dynamic>("${EndPoint.processHistory}$workflowId/$processId");

      String dec = AaaEncryption.decryptAESaaa(response.data.toString());
      List<dynamic> json = jsonDecode(dec);
      return json;
    } catch (e) {
      if (e is Dio.DioException) {
        return [];
      }
    }

    return [];
  }

  @override
  Future getAllForms(Map<String, dynamic> payload) async {
    try {
      var response = await Api()
          .clientWithHeader(responseType: Dio.ResponseType.plain)
          .post<dynamic>(EndPoint.allForms,
              data: jsonEncode(AaaEncryption.EncryptData(jsonEncode(payload))));

      String dec = AaaEncryption.decryptAESaaa(response.data.toString());
      Map<String, dynamic> json = jsonDecode(dec);
      return json;
    } catch (e) {
      if (e is Dio.DioException) {
        return [];
      }
    }

    return [];
  }

  @override
  Future getDynamicTaskForm(int formId) async {
    try {
      var response =
          await Api().clientWithHeader().get<dynamic>("${EndPoint.dynamicTaskForm}$formId");

      String dec = AaaEncryption.decryptAESaaa(response.data.toString());
      Map<String, dynamic> json = jsonDecode(dec);
      return json;
    } catch (e) {
      if (e is Dio.DioException) {
        return null;
      }
    }

    return null;
  }

  @override
  Future getTaskList(int workflowId, int processId, Map<String, dynamic> payload) async {
    try {
      var response = await Api().clientWithHeader().post<dynamic>(
          "${EndPoint.taskList}$workflowId/$processId",
          data: jsonEncode(AaaEncryption.EncryptData(jsonEncode(payload))));
      String dec = AaaEncryption.decryptAESaaa(response.data.toString());
      List<dynamic> json = jsonDecode(dec);
      return json;
    } catch (e) {
      e.printError();
      if (e is Dio.DioException) {
        return [];
      }
    }

    return [];
  }

  @override
  Future getTaskListtask(int iFormID, Map<String, dynamic> payload) async {
    try {
      var response = await Api().clientWithHeadertask().post<dynamic>(
          "${EndPoint.taskList_task}$iFormID/entry/all",
          data: jsonEncode(AaaEncryption.EncryptData(jsonEncode(payload))));
      String dec = AaaEncryption.decryptAESaaa(response.data.toString());
      Map<String, dynamic> jsonmap = jsonDecode(dec);
      var tagsJson = jsonmap['data'][0]['value'];
      List<dynamic> tags = List.from(tagsJson);
      return tags;
    } catch (e) {
      e.printError();
      if (e is Dio.DioException) {
        return [];
      }
    }
    return [];
  }

  @override
  Future getTaskComments(int formId, int entryId) async {
    try {
      var response = await Api()
          .clientWithHeader(responseType: Dio.ResponseType.plain)
          .get<dynamic>("${EndPoint.taskComments}$formId/$entryId");

      String dec = AaaEncryption.decryptAESaaa(response.data.toString());
      List<dynamic> json = jsonDecode(dec);
      return json;
    } catch (e) {
      if (e is Dio.DioException) {
        return [];
      }
    }

    return [];
  }

  @override
  Future getTaskAttachments(int formId, int entryId) async {
    try {
      var response = await Api()
          .clientWithHeader(responseType: Dio.ResponseType.plain)
          .get<dynamic>("${EndPoint.taskAttachments}$formId/$entryId");

      String dec = AaaEncryption.decryptAESaaa(response.data.toString());
      List<dynamic> json = jsonDecode(dec);
      return json;
    } catch (e) {
      if (e is Dio.DioException) {
        return [];
      }
    }

    return [];
  }

  @override
  Future uploadTaskAttachments(List<Map<String, dynamic>> payloads) async {
    var responses = [];
    for (var payload in payloads) {
      var response = await Api().clientWithHeaderFile().post<dynamic>(
          EndPoint.uploadTaskAttachmentWithEntryId,
          data: Dio.FormData.fromMap(payload));
      responses.add(response);
    }
    return responses;
  }

  @override
  Future postTaskComments(int formId, int entryId, Map<String, dynamic> payload) async {
    var response = await Api().clientWithHeader().post<dynamic>(
        'form/taskComments/$formId/$entryId',
        data: jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payload))));

    String dec = AaaEncryption.decryptAESaaa(response.data.toString());

    return dec;
  }

  @override
  Future taskComments(int formId, int formEntryId) async {
    var response = await Api()
        .clientWithHeader(responseType: Dio.ResponseType.plain)
        .get<dynamic>('form/taskComments/$formId/$formEntryId');
    String dec = AaaEncryption.decryptAESaaa(response.data.toString());
    List<dynamic> json = jsonDecode(dec);
    return json;
  }

  @override
  Future deleteTaskAttachment(int repositoryId, Map<String, dynamic> payload) async {
    var response = await Api().clientWithHeader().post<dynamic>(
        'menu/file/delete/$repositoryId/1/1',
        data: jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payload))));

    String dec = AaaEncryption.decryptAESaaa(response.data.toString());
    return dec;
  }

  @override
  Future uploadAndIndex(List<Map<String, dynamic>> payloads) async {
    var responses = [];
    for (var payload in payloads) {
      try {
        var response = await Api()
            .clientWithHeaderFile()
            .post<dynamic>(EndPoint.uploadAndIndex, data: Dio.FormData.fromMap(payload));

        // Print the response for debugging
        print("Response for payload: $payload\n$response");

        responses.add(response);
      } catch (error) {
        // Handle and print errors if any
        print("Error uploading payload: $payload\n$error");
      }
    }
    return responses;
  }

  @override
  Future<dynamic> shareMailWithAttachments(Map<String, dynamic> payload) async {
    var response = await Api().clientWithHeader().post<dynamic>(EndPoint.shareMailWithAttachments,
        data: jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payload))));

    String dec = AaaEncryption.decryptAESaaa(response.data.toString());
    return dec;
  }

  @override
  Future<dynamic> mergeFiles(
      int wId, int pId, int tId, int rId, Map<String, dynamic> payload) async {
    var response = await Api().clientWithHeader().post<dynamic>(
        '${EndPoint.mergeFiles}$wId/$pId/$tId/$rId',
        data: jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payload))));

    String dec = AaaEncryption.decryptAESaaa(response.data.toString());
    return dec;
  }

  @override
  Future<dynamic> uploadForStaticMetadata(int rId, file, List<String> formFields) async {
    var request = {
      "repositoryId": rId.toString(),
      "file": file,
      "formFields": jsonEncode(formFields)
    };
    print("Request object: $request");
    var response = await Api()
        .clientWithHeaderFile(responseType: Dio.ResponseType.plain)
        .post<dynamic>(EndPoint.uploadForStaticMetadata, data: Dio.FormData.fromMap(request));

    String dec = AaaEncryption.decryptAESaaa(response.data.toString());
    print('Decrypted data: $dec');

    try {
      dynamic outerJson = jsonDecode(dec);

      // If outerJson is a string, try parsing it again
      if (outerJson is String) {
        outerJson = jsonDecode(outerJson);
      }

      // Ensure we have a Map with 'ocrResult'
      if (outerJson is Map<String, dynamic> && outerJson.containsKey('ocrResult')) {
        return List<dynamic>.from(outerJson['ocrResult']);
      }

      print('Unexpected JSON format: ${outerJson.runtimeType}');
      return [];
    } catch (e) {
      print("Error parsing decrypted data: $e");
      print("Decoded data type: ${dec.runtimeType}");
      print("Decoded data: $dec");
      return [];
    }
  }

  @override
  Future<dynamic> signWithProcessId(int wId, int pId, int tId, Map<String, dynamic> payload) async {
    var response = await Api().clientWithHeader(responseType: Dio.ResponseType.plain).post<dynamic>(
        '${EndPoint.signWithProcessId}$wId/$pId/$tId',
        data: jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payload))));

    String dec = AaaEncryption.decryptAESaaa(response.data.toString());
  }

  @override
  Future<dynamic> signWithProcessIdList(int wId, int pId) async {
    var response = await Api()
        .clientWithHeader(responseType: Dio.ResponseType.plain)
        .get("${EndPoint.signWithProcessIdList}$wId/$pId");

    String responseStr = AaaEncryption.decryptAESaaa(response.data);
    List<dynamic> signatureList = (json.decode(responseStr) as List<dynamic>);

    return signatureList;
  }

  @override
  Future<dynamic> workflowAuditWithSlaFields(int wId, Map<String, dynamic> payload) async {
    var response = await Api().clientWithHeader(responseType: Dio.ResponseType.plain).post(
        "${EndPoint.workflowAuditWithSlaFields}$wId",
        data: jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payload))));

    String responseStr = AaaEncryption.decryptAESaaa(response.data);
    Map<String, dynamic> data = json.decode(responseStr);

    return data;
  }

  @override
  Future<dynamic> getRepositoryDetails(int repositoryId) async {
    var response = await Api().clientWithHeader().get("${EndPoint.repositoryDetails}$repositoryId");

    String responseStr = AaaEncryption.decryptAESaaa(response.data);
    Map<String, dynamic> data = json.decode(responseStr);

    return data;
  }
}
