import 'package:dio/dio.dart';
import 'package:ez/core/ApiClient/endpoint.dart';

class ApiHandler {
  final Dio _dio;

  ApiHandler() : _dio = Dio(BaseOptions(baseUrl: EndPoint.MainPortalURL));

  // Fetch details from the first API
  Future<Map<String, dynamic>> fetchDetails() async {
    try {
      final response = await _dio.get('withoutToken/23/1');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching details: $e');
      throw e;
    }
  }
}
