import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';


abstract class Service {
  Future<dynamic> getData(String path);
}

class FileManager implements Service {
  final Dio _dio; // Dio instance to perform HTTP requests.
  FileManager(Dio dio) : _dio = dio;

  @override
  Future<dynamic> getData(String path) async {
    try {
      final String response = await rootBundle.loadString(path);
      final jsonData = await json.decode(response);
      return jsonData;
    } catch (e) {
      // If any exception occurs during the API call, throw an exception with the error message.
      SVProgressHUD.dismiss();
      throw Exception('An error occurred: $e');
    }
  }
}

class ApiManager implements Service {
  final Dio _dio; // Dio instance to perform HTTP requests.
  ApiManager(Dio dio) : _dio = dio;

  //:- Get Request
  @override
  Future<dynamic> getData(String path) async {
    try {
      // Make a GET request to the API endpoint to fetch user data.
      final response = await _dio.get(path);

      // Check if the response status code is 200 (OK).
      if (response.statusCode == 200) {
        return response
            .data; // If successful, return the response data (List of dynamic).
      } else {
        // If the response status code is not 200, throw an exception with an error message.
        throw Exception('API failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // If any exception occurs during the API call, throw an exception with the error message.
      throw Exception('An error occurred: $e');
    }
  }

  //:- Post Request

  Future<dynamic> postdata(String path, var data) async {
    try {
      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers["Token"] = "email " + data['email'];
      final response = await _dio.post(
        path,
        data: data,
      );

      // Check if the response status code is 200 (OK).
      if (response.statusCode == 200) {
        return response
            .data; // If successful, return the response data (List of dynamic).
      } else {
        // If the response status code is not 200, throw an exception with an error message.
        throw Exception('API failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      if(e is DioException) {
        if((e).response?.statusCode == 300) {
          return e.response?.data;
        }
      }
      throw Exception('An error occurred: $e');
    }
  }

  //:- Get Request - user datas

  Future<dynamic> getDataWithHeader(String path, var token) async {
    debugPrint(token);
    try {
      _dio.options.headers['content-Type'] = 'application/json;text/html';
      _dio.options.headers["Token"] = token;
      _dio.options.responseType = ResponseType.json;
      final response = await _dio.get(path);
      // Check if the response status code is 200 (OK).
      if (response.statusCode == 200) {
        return response
            .data; // If successful, return the response data (List of dynamic).
      } else {
        // If the response status code is not 200, throw an exception with an error message.
        throw Exception('API failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
