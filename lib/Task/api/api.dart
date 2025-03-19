import 'package:dio/dio.dart';
import 'package:ez/core/ApiClient/endpoint.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../utils/aes_encryption.dart';
import 'apiurls.dart';

class Api extends GetxController {
  Dio client() {
    return Dio(
      BaseOptions(baseUrl: ApiUrls.MainAPIUrl, headers: {"Accept": "application/json;text/html"}),
    );
  }

  clientLogin(String sUserEmail) {
    return Dio(
      BaseOptions(baseUrl: ApiUrls.MainAPIUrl, headers: {
        "Accept": "application/json;text/html",
        "Token": 'email $sUserEmail',
        "Content-Type": "application/json"
      }),
    );
  }

  Dio clientWithHeader({responseType = ResponseType.json}) {
    var dtemp = Dio(BaseOptions(baseUrl: ApiUrls.MainAPIUrl, responseType: responseType, headers: {
      //"Accept": "application/json;text/plain",
      "Accept": "*/*",
      "Token": AaaEncryption.sToken,
      "Content-Type": "application/json",
    }));
    return dtemp;
  }

  Dio clientWithHeaderSubRep({responseType = ResponseType.plain}) {
    var dtemp = Dio(BaseOptions(baseUrl: ApiUrls.MainAPIUrl, responseType: responseType, headers: {
      //"Accept": "application/json;text/plain",
      "Accept": "*/*",
      "Token": AaaEncryption.sToken,
      "Content-Type": "application/json",
    }));

    return dtemp;
  }

  Dio clientWithHeadePlaain({responseType = ResponseType.json}) {
    var dtemp = Dio(BaseOptions(baseUrl: ApiUrls.MainAPIUrl, responseType: responseType, headers: {
      //"Accept": "application/json;text/plain",
      "Accept": "*/*",
      "Token": AaaEncryption.sToken,
      "Content-Type": "application/json;text/html",
    }));
    return dtemp;
  }

  Dio clientWithHeaders({responseType = ResponseType.json}) {
    var dtemp = Dio(BaseOptions(baseUrl: ApiUrls.MainAPIUrl, responseType: responseType, headers: {
      "Accept": "application/json;text/plain",
      //"Accept": "*/*",
      "Token": AaaEncryption.sToken,
      "Content-Type": "application/json;text/html",
    }));
    return dtemp;
  }

  Dio clientWithHeadePlaainUpload({responseType = ResponseType.json}) {
    var dtemp = Dio(BaseOptions(baseUrl: ApiUrls.MainAPIUrl, responseType: responseType, headers: {
      //"Accept": "application/json;text/plain",
      "Accept": "*/*",
      "Token": AaaEncryption.sToken,
      "Content-Type": "multipart/form-data",
    }));
    return dtemp;
  }

  Dio clientWithHeaderOne() {
    var dtemp = Dio(
        BaseOptions(baseUrl: ' https://eztapi.ezofis.com/api/authentication/userSession', headers: {
      "Accept": "*/*",
      "Token": AaaEncryption.sToken,
      "Content-Type": "application/json;text/html",
    }));
    return dtemp;
  }

  Dio clientWithHeaderFile() {
    var dtemp = Dio(BaseOptions(baseUrl: ApiUrls.MainAPIUrl, headers: {
      "Accept": "*/*",
      "Token": AaaEncryption.sToken,
      "Content-Type": "multipart/form-data",
    }));

    return dtemp;
  }
}
