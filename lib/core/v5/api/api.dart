import 'package:dio/dio.dart';
import 'package:ez/core/ApiClient/endpoint.dart';
import 'package:ez/core/v5/api/apiurls.dart';

import 'package:get/get.dart';

import '../utils/helper/aes_encryption.dart';

class Api extends GetxController {
  // String baseUrl = 'https://edmsuat.sobhaapps.com/SANDBOXAPI';
  String baseUrl = EndPoint.BaseUrl;
  String basePortalUrl = EndPoint.MainPortalURL; //'http://52.172.32.88/eZenterpriseAPI';
  Dio client() {
    return Dio(
      BaseOptions(baseUrl: baseUrl, headers: {"Accept": "application/json;text/html"}),
    );
  }

  clientLogin(String sUserEmail) {
    return Dio(
      BaseOptions(baseUrl: basePortalUrl, headers: {
        "Accept": "application/json;text/html",
        "Token": 'email $sUserEmail',
        "Content-Type": "application/json"
      }),
    );
  }

  Dio clientWithHeader({responseType = ResponseType.json, accept = "*/*"}) {
    var dtemp = Dio(BaseOptions(baseUrl: baseUrl, responseType: responseType, headers: {
      //"Accept": "application/json;text/plain",
      "Accept": accept,
      "Token": AaaEncryption.sToken,
      // "Token":
      //     "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IkVVXzkiLCJ0ZW5hbnRJZCI6MjMsImxvZ2dlZEZyb20iOiJQT1JUQUwifQ.nSLBrFBFlEsEsfNBb8ZHdt-OHOT8B1dI-5kIH4w5EvA",
      "Content-Type": "application/json;text/html",
    }));
    print("Debug - Token Value: ${AaaEncryption.sToken}");
    return dtemp;
  }

  Dio clientWithHeadertask({responseType = ResponseType.json, accept = "*/*"}) {
    try {
      print(baseUrl);
      var dtemps = Dio(BaseOptions(baseUrl: baseUrl, responseType: responseType, headers: {
        //"Accept": "application/json;text/plain",
        "Accept": accept,
        "Token": AaaEncryption.sToken,
        "Content-Type": "application/json;text/html",
      }));
      print('fffffff');
      print(dtemps.toString());
    } catch (Ex) {
      print('eeeeeeee');
      print(Ex.toString());
    }
    var dtemp = Dio(BaseOptions(baseUrl: baseUrl, responseType: responseType, headers: {
      //"Accept": "application/json;text/plain",
      "Accept": accept,
      "Token": AaaEncryption.sToken,
      "Content-Type": "application/json;text/html",
    }));

    return dtemp;
  }
  //Dio clientWithHeader() {
  // Dio clientWithHeader() {
  //   var dtemp = Dio(BaseOptions(
  //       // baseUrl: 'http://52.172.32.88/eZenterpriseAPI/api/',
  //       baseUrl: 'https://demo.ezofis.com/CoreAPI/api/',
  //       headers: {
  //         //"Accept": "application/json;text/plain",
  //         "Accept": "*/*",
  //         "Token": AaaEncryption.sToken,
  //         "Content-Type": "application/json;text/html",
  //       }));
  //
  //   return dtemp;
  // }

  Dio clientWithHeaderOne() {
    var dtemp = Dio(BaseOptions(
        // baseUrl: 'http://52.172.32.88/eZenterpriseAPI/api/',
        baseUrl: ' https://demo.ezofis.com/CoreAPI/api/authentication/userSession',
        headers: {
          //"Accept": "application/json;text/plain",
          "Accept": "*/*",
          "Token": AaaEncryption.sToken,
          "Content-Type": "application/json;text/html",
        }));

    return dtemp;
  }

  Dio clientWithHeaderFile({responseType = ResponseType.json, accept = "*/*"}) {
    var dtemp = Dio(BaseOptions(baseUrl: baseUrl, responseType: responseType, headers: {
      "Accept": accept,
      "Token": AaaEncryption.sToken,
      "Content-Type": "multipart/form-data",
    }));

    return dtemp;
  }

  Dio clientWithHeadePlaain({responseType = ResponseType.plain}) {
    var dtemp = Dio(BaseOptions(baseUrl: ApiUrls.MainAPIUrl, responseType: responseType, headers: {
      //"Accept": "application/json;text/plain",
      "Accept": "*/*",
      "Token": AaaEncryption.sToken,
      "Content-Type": "application/json;text/html",
    }));
    return dtemp;
  }
}
