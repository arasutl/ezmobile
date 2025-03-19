import 'package:dio/dio.dart';

import 'package:get/get.dart';
import '../api/auth_repo.dart';
import 'session_controller.dart';
import '../utils/helper/aes_encryption.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:encrypt/encrypt.dart' as enc;

class LoginController extends GetxController {
  final email = ''.obs;
  final hasEmailError = false.obs;

  final password = ''.obs;
  final hasPasswordError = false.obs;

  final isLoading = false.obs;
  final error = ''.obs;

  final sessionController = Get.find<SessionController>();

  late SharedPreferences pre;

  @override
  Future onInit() async {
    super.onInit();
  }

  // onEmailChanged
  void onEmailChanged(String value) {
    email.value = value;
  }

  // ...
  // onPasswordChanged
  void onPasswordChanged(String value) {
    password.value = value;
  }

  // ...
  // login

  Future login() async {
    isLoading.value = true;
    hasEmailError.value = email.value == '';
    hasPasswordError.value = password.value == '';

// dont delete by sangili
    if (hasEmailError.value || hasPasswordError.value) {
      isLoading.value = false;
      return;
    }

    error.value = '';
    final payload = {
      'email': email.value,
      'password': password.value,
      'tenantId': '23',
      'portalId': '1',
      'loggedfrom': 'MOBILE',
    };

    try {
      final response = await AuthRepo.login(payload, email.value);
      isLoading.value = false;
      Map<String, dynamic> data = jsonDecode(AaaEncryption.dec_base64(response.data.toString()));
      if (response.statusCode == 200) {
        sessionController.setSession(data);

        pre = await SharedPreferences.getInstance();
        pre.setString("ez_name", email.value);
        pre.setString("ez_pass", password.value);

        //Save Token details
        pre.setString("token", data['token'].toString());
        pre.setString("iv", data['iv'].toString());
        pre.setString("key", data['key'].toString());
        pre.setString("twoFactor", data['twoFactorAuthentication'].toString());

        pre.commit();

        getUserDetails();
      } else {
        isLoading.value = false;
        throw 'invalid status code';
      }
    } on DioError catch (e) {
      isLoading.value = false;
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        error.value = 'Unauthorized Login';
      }
      if (statusCode == 402) {
        error.value = 'license expired';
      } else if (statusCode == 404) {
        error.value = 'email not found';
      } else if (statusCode == 409) {
        error.value = 'incorrect password';
      } else {
        rethrow;
      }
    } catch (e) {
      print(e);
      error.value = 'error logging in';
    } finally {
      isLoading.value = false;
    }
  }

  Future getUserDetails() async {
    isLoading.value = true;
    error.value = '';

    try {
      AaaEncryption.KeyVal = enc.Key.fromBase64(pre.getString('key').toString());
      AaaEncryption.IvVal = enc.IV.fromBase64(pre.getString('iv').toString());
      AaaEncryption.sToken = pre.getString('token').toString();

      print(getUserDetails);
      final response = await AuthRepo.getUserDetails();

      Map<String, dynamic> data = jsonDecode(AaaEncryption.decryptAESaaa(response.data));
      isLoading.value = false;

      if (response.statusCode == 200) {
        pre.setString('Userdata', response.data.toString());
        pre.commit();
        sessionController.setSessionUser(data);
        Get.offAllNamed('/home');
      } else {
        throw 'invalid status code';
      }
    } on DioError catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        error.value = 'Unauthorized Login';
      }
      if (statusCode == 402) {
        error.value = 'license expired';
      } else if (statusCode == 404) {
        error.value = 'email not found';
      } else if (statusCode == 409) {
        error.value = 'incorrect password';
      } else {
        rethrow;
      }
    } catch (e) {
      print(e);
      error.value = 'error logging in';
    } finally {
      isLoading.value = false;
    }
  }
}
