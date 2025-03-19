import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ez/core/ApiClient/endpoint.dart';
import 'package:ez/core/v5/api/api.dart';
import 'package:ez/core/v5/controllers/session_controller.dart';
import 'package:ez/core/v5/pages/lost_connection.dart';
import 'package:ez/core/v5/utils/helper/aes_encryption.dart';
import 'package:ez/features/dynamic_form/dynamic_form.dart';
import 'package:ez/screens/Homepage.dart';
import 'package:ez/screens/TrackList.dart';
import 'package:ez/screens/UsernameLogin.dart';
import 'package:ez/screens/WelcomePage.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../utils/utils.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? connectivitySubscription;

  var isConnected = true.obs;
  var token = "".obs;
  var route = "".obs;
  Map<String, dynamic>? userdata = {};
  String? savedValue;
  int workflowId = 0;
  int formId = 0;
  @override
  void onInit() {
    super.onInit();

    // connectivitySubscription = _connectivity.onConnectivityChanged
    //     .listen((ConnectivityResult result) async {
    //   await getConnectivity();
    // });
    route.value = "";
  }

  @override
  void onReady() {
    super.onReady();
    readLocalData();
    print("On Ready >>>>>>>>>>>>>>>>>>>>>>");
    // getConnectivity();
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> readSavedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedValue = prefs.getString('button_status') ?? 'Default Value';
    formId = prefs.getInt('formId') ?? 0; // Default value is 0 if null
    workflowId = prefs.getInt('workflowId') ?? 0; // Default value is 0 if null
    // Provide a default value
    print("Saved Value: $savedValue");
    print("Saved Value: $formId");
    print("Saved Value: $workflowId");
  }

  Future<void> getConnectivity() async {
    try {
      bool isConnectedResult = await Utils.checkInternetConnectivity();
      isConnected.value = isConnectedResult;
      Future.delayed(Duration.zero, () {
        getUserInfoAndRedirect();
      });
    } on PlatformException catch (e) {}
    return Future.value(null);
  }

  Future<void> getUserInfoAndRedirect() async {
    try {
      if (!isConnected.value) {
        // Get.offAndToNamed("/noConnection");
        Get.off(() => const LostConnection());
      } else {
        // check local login saved detail
        readLocalData();
      }
    } on Exception catch (e) {}
  }

  void redirectBasedOnSavedValue() {
    if (savedValue == 'Start') {
      Get.offAll(DynamicForm(formId: formId, repositoryId: 1, workflowId: workflowId));
    } else {
      Get.offAll(WorkflowList(
        sWorkflowId: workflowId,
        sType: 1,
      ));
    }
  }

  readLocalData() async {
    print("Read Local Data >>>>>>>>>>>>>>>>>>>>>>");
    await readSavedValue();
    final sessionController = Get.find<SessionController>();
    sessionController.getSession();

    if (sessionController.token != '' &&
        sessionController.iv != '' &&
        sessionController.key != '') {
      try {
        var response =
            await Api().clientWithHeader().get(EndPoint.BaseUrl + EndPoint.getuserDetails);
        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(AaaEncryption.decryptAESaaa(response.data));
          sessionController.userData = data;
        }
        print("Redirecting to Welcome Page");
        redirectBasedOnSavedValue();
        return;
      } catch (e) {
        print("Error during API call: $e");
        sessionController.userdata = '';
        sessionController.token = ''.obs;
        sessionController.iv = ''.obs;
        sessionController.userid = ''.obs;
        await sessionController.deleteSession();
        print("Redirecting to Home Page");
        Get.offAll(() => HomePage(title: 'Home'));
      }
    } else {
      print("Session data missing, redirecting to HomePage.");
      Get.offAll(() => HomePage(title: 'Home'));
    }
  }

  Future<void> logout() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    pre.clear();
    pre.commit();
    // Get.offAllNamed("/loginscreen");
    Get.offAll(() => Usernamelogin(title: 'Home'));
  }
}
