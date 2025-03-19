import 'package:dio/dio.dart';

import 'api.dart';

class WorkflowRepo {
  const WorkflowRepo();

  static Future<Response> getlistByUserId() {
    //print(' getlistByUserId');

    return Api().clientWithHeader().get<dynamic>('workflow/listByUserId'); //7  or 6
  }

/*  static Future<Response<List>> getWorkflows(Map<String, String> payload) {
    return Api().client().post<List>('/Mobile/getWorkflows', data: payload);
  }

  static Future<Response<Map>> getTickets(Map<String, dynamic> payload) {
    return Api().client().post<Map>('/Mobile/getTickets', data: payload);
  }

  static Future<Response<List>> getTicketHistory(Map<String, dynamic> payload) {
    return Api().client().post<List>('/Mobile/getTicketHistory', data: payload);
  }

  static Future<Response<Map>> getTicket(Map<String, dynamic> payload) {
    return Api().client().post<Map>('/Mobile/getTicket', data: payload);
  }

  static Future<Response<List>> getTicketFormFields(
      Map<String, dynamic> payload) {
    return Api()
        .client()
        .post<List>('/Mobile/getTicketFormFields', data: payload);
  }

  static Future<Response<List>> getTicketAttachments(
      Map<String, dynamic> payload) {
    return Api()
        .client()
        .post<List>('/Mobile/getTicketAttachments', data: payload);
  }

  static Future<Response<List>> getTicketComments(
      Map<String, dynamic> payload) {
    return Api()
        .client()
        .post<List>('/Mobile/getTicketComments', data: payload);
  }

  static Future<Response<List>> getUsers(Map<String, String> payload) {
    return Api().client().post<List>('/Mobile/getUsers', data: payload);
  }

  static Future<Response<String>> uploadAttachment(FormData payload) {
    return Api()
        .client()
        .post<String>('/Mobile/uploadAttachment', data: payload);
  }

  static Future<Response<String>> uploadComment(Map<String, dynamic> payload) {
    return Api().client().post<String>('/Mobile/makeComments', data: payload);
  }

  static Future<Response<Map>> processTicket(Map<String, dynamic> payload) {
    return Api().client().post<Map>('/Mobile/processTicket', data: payload);
  }*/
}
