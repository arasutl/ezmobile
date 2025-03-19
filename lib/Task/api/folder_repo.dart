import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ez/Task/utils/aes_encryption.dart';
import 'api.dart';
import 'apiurls.dart';

class FolderRepo {
  const FolderRepo();

  static Future<Response> getRepositoriesList(String payload) {
    return Api().clientWithHeader().post<dynamic>(ApiUrls.sListFolders, data: jsonEncode(payload));
  }

  static Future<Response> getSubRepositoriesList(String payload) {
    Future<Response> res = Api()
        .clientWithHeaderSubRep()
        .post<dynamic>(ApiUrls.sBrowseFolders, data: jsonEncode(payload));

    return res;
  }

  static Future<Response> getUploadFileList(String payload) {
    return Api()
        .clientWithHeaders()
        .post<dynamic>(ApiUrls.sGetUploadFiles, data: jsonEncode(payload));
  }

  static Future<Response> postUploadFile(final payload) {
    return Api()
        .clientWithHeadePlaainUpload()
        .post<dynamic>(ApiUrls.sPostUploadFiles, data: payload);
  }

  static Future<Response> postUploadFileDIo(String payload) {
    return Api()
        .clientWithHeadePlaainUpload()
        .post<dynamic>(ApiUrls.sPostUploadFiles, data: jsonEncode(payload));
  }

  static Future<Response> getIndexFileList(String payload) {
    print('pppppppppp');
    print(payload);
    print(AaaEncryption.sToken);
    print(ApiUrls.sgetIndexFiles);
    print('-------------------------');
    return Api()
        .clientWithHeadePlaain()
        .post<dynamic>(ApiUrls.sgetIndexFiles, data: jsonEncode(payload));
  }

  static Future<Response> DeleteFiles(String payload) {
    return Api()
        .clientWithHeadePlaain()
        .post<dynamic>(ApiUrls.sDeleteUploadFiles, data: jsonEncode(payload));
  }

  static Future<Response> postAutoProcess(String payload) {
    print(ApiUrls.sPostAutoProcess);
    Future<Response> res =
        Api().clientWithHeader().post<dynamic>(ApiUrls.sPostAutoProcess, data: jsonEncode(payload));
    return res;
  }

  static Future<Response> getOCRData(String payload) {
    print(ApiUrls.sPostOCRforUploadedFile);
    Future<Response> res = Api()
        .clientWithHeadePlaainUpload()
        .post<dynamic>(ApiUrls.sPostOCRforUploadedFile, data: jsonEncode(payload));
    return res;
  }

/*  static Future<Response> UploadFile(List<Map<String, dynamic>> payload) {
    return Api().clientWithHeaderFile().post<dynamic>(ApiUrls.spostUploadFileinRep, data: payload);

  }*/

/*  static Future UploadFile(Map<String, dynamic> payloads) async {
    var responses = [];
    // for (var payload in payloads)
    {
      var response = await Api()
          .clientWithHeaderFile()
          .post<dynamic>(ApiUrls.sPostUploadFiles, data: FormData.fromMap(payloads));
      responses.add(response);
    }
    return responses;
  }*/
}
