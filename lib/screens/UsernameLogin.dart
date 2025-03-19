import 'dart:async';
import 'dart:convert';

import 'package:ez/core/ApiClient/endpoint.dart';
import 'package:ez/core/snack_bar.dart';
import 'package:ez/core/v5/controllers/login_controller.dart';
import 'package:ez/core/v5/controllers/session_controller.dart';
import 'package:ez/features/dynamic_form/dynamic_form.dart';
import 'package:ez/features/login/model/login_request.dart';
import 'package:ez/features/login/model/login_response.dart';
import 'package:ez/screens/TrackList.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ez/Const/CustomColors.dart';
import 'package:ez/core/utils/strings.dart';
import 'package:ez/screens/Homepage.dart';
import 'package:ez/screens/WelcomePage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/v5/api/api.dart';
import '../core/v5/api/apiurls.dart';
import '../core/v5/utils/helper/aes_encryption.dart';

class Usernamelogin extends StatefulWidget {
  const Usernamelogin({
    super.key,
    this.title,
    this.workflowId,
    this.settings,
  });

  final String? title;
  final int? workflowId;
  final Map<String, dynamic>? settings;

  @override
  State<Usernamelogin> createState() => _UsernameloginState();
}

class _UsernameloginState extends State<Usernamelogin> {
  TextEditingController phoneOtpedt = TextEditingController();
  TextEditingController useretdedt = TextEditingController();
  TextEditingController passetdedt = TextEditingController();
  bool isPasswordVisible = false;
  bool isChecked = true;
  bool isLoginProgress = false;
  final sessionController = Get.put(SessionController());
  final email = ''.obs;
  final password = ''.obs;
  // ..text = "123456";

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";

  String staticPhone = "";
  bool showError = false;
  bool showOtp = false;
  final controller = Get.put(LoginController());

  int? tenantId1 = 23;

  late Map<String, dynamic> authentication;
  late int formId;
  late List<String> emailColumn;
  late String passwordColumn;
  late String nameColumn;
  final String loggedFrom = "MOBILE";

  String? savedValue;

  int workflowId = 0;

  @override
  void initState() {
    super.initState();
    readSavedValue();
    // Extract values from settings
    authentication = widget.settings!['authentication'] ?? {};
    formId = authentication['formId'] ?? 0;
    emailColumn = List<String>.from(authentication['usernameField'] ?? []);
    passwordColumn = authentication['passwordField'] ?? '';
    nameColumn = authentication['firstnameField'] ?? '';
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
    staticPhone = "9025335721";
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: SafeArea(
          child: Stack(
        children: [
          Container(
            color: CustomColors.ezpurpleLite1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(5, 10, 15, 10),
                      child: Image.asset(
                        'assets/images/logo/belltemple/belllogo.png',
                        width: 150, // Set the desired width
                        height: 40, // Set the desired height
                        fit: BoxFit.contain, // Adjust how the image fits within the given size
                      ),
                    ),
                    // Text(
                    //   Strings.TitleName,
                    //   style: const TextStyle(
                    //       fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
                    // ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      // Background color
                      color: CustomColors.ezpurple,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // Shadow color
                          blurRadius: 10.0, // Spread of the shadow
                          offset: Offset(0, 4), // Shadow offset
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        // color: CustomColors.white,
                        decoration: BoxDecoration(
                          // Background color
                          color: CustomColors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                              blurRadius: 10, // Spread of the shadow
                              offset: Offset(
                                  0, 5), // Offset in x and y direction (horizontal, vertical)
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              "Hii,\nWelcome!",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.ezpurple,
                                  fontSize: 30),
                            ),
                            Text(
                              "Sign in to Your Account",
                              style: const TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: CustomColors.grey.withOpacity(0.2),
                                  border: Border.all(
                                    color: CustomColors.grey.withOpacity(0.2), // Border color
                                    width: 1.5, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   "Username",
                                      //   style: const TextStyle(
                                      //     fontSize: 15,
                                      //     color: Colors.black,
                                      //   ),
                                      // ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      TextFormField(
                                        controller: useretdedt,
                                        decoration: InputDecoration(
                                          labelText:
                                              'Username', // Label that floats when focused or typing
                                          labelStyle: TextStyle(
                                            color: CustomColors.ezpurple, // Label text color
                                            fontSize: 16, // Optional: Adjust font size
                                          ),
                                          hintText: 'Username',
                                          fillColor: CustomColors.white.withOpacity(
                                              0.1), // Purple background with reduced opacity
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0), // Rounded corners
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: CustomColors
                                                  .ezpurple, // Outline color when not focused
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: CustomColors
                                                  .ezpurple, // Outline color when focused
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 7.0, // Adjust height
                                            horizontal: 12.0, // Adjust horizontal spacing
                                          ),
                                          suffixIcon: Icon(
                                            Icons.person, // User icon
                                            color: CustomColors.ezpurple,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          onEmailChanged(value);
                                          if (showError) {
                                            setState(() {
                                              showError = false;
                                            });
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      TextFormField(
                                        controller: passetdedt,
                                        obscureText: !isPasswordVisible,
                                        decoration: InputDecoration(
                                          labelText:
                                              'Password', // Label that floats when focused or typing
                                          labelStyle: TextStyle(
                                            color: CustomColors.ezpurple, // Label text color
                                            fontSize: 16, // Optional: Adjust font size
                                          ),
                                          hintText: 'Password',
                                          fillColor: CustomColors.white.withOpacity(
                                              0.1), // Purple background with reduced opacity
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0), // Rounded corners
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: CustomColors
                                                  .ezpurple, // Outline color when not focused
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: CustomColors
                                                  .ezpurple, // Outline color when focused
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 7.0, // Adjust height
                                            horizontal: 12.0, // Adjust horizontal spacing
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              isPasswordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: CustomColors.ezpurple,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isPasswordVisible =
                                                    !isPasswordVisible; // Toggle visibility
                                              });
                                            },
                                          ),
                                        ),
                                        onChanged: (value) {
                                          onPasswordChanged(value);
                                          if (showError) {
                                            setState(() {
                                              showError = false;
                                            });
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // "Remind Me" with Checkbox
                                          Row(
                                            children: [
                                              Checkbox(
                                                value: isChecked, // Bind to the state variable
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    isChecked = value ??
                                                        false; // Update the state on change
                                                  });
                                                },
                                                activeColor:
                                                    CustomColors.ezpurple, // Checkbox active color
                                              ),
                                              Text(
                                                "Remind Me",
                                                style: TextStyle(
                                                  color: Colors.black, // Text color
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // "Forgot Password?" with underline
                                          GestureDetector(
                                            onTap: () {
                                              // Handle "Forgot Password?" click
                                              print("Forgot Password clicked");
                                            },
                                            child: Text(
                                              "Forgot Password?",
                                              style: TextStyle(
                                                color: CustomColors.ezpurple, // Text color
                                                fontSize: 14,
                                                decoration:
                                                    TextDecoration.underline, // Underline text
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (!isLoginProgress)
                                        Center(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                LoginPortal();
                                                // Get.to(Welcomepage(
                                                //   title: 'Continue',
                                                // ));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    CustomColors.ezpurple, // Background color
                                                elevation: 5, // Elevation
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8), // Rounded corners
                                                ),
                                              ),
                                              child: Text(
                                                "Login",
                                                style: TextStyle(
                                                  color:
                                                      CustomColors.white, // Set text color to white
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (isLoginProgress)
                                        const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(CustomColors
                                              .ezpurple), // Red color for the progress indicator
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // Background color
                      border: Border.all(
                        color: CustomColors.ezpurple, // Border color
                        width: 1.5, // Border width
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Not ready yet?",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(HomePage(
                                  title: 'HomePage',
                                ));
                                print("Button Pressed!");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.ezpurple, // Background color
                                elevation: 5, // Elevation
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9), // Rounded corners
                                ),
                              ),
                              child: Text(
                                "Back to Home",
                                style: TextStyle(
                                  color: CustomColors.white, // Set text color to white
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> LoginPortal({tenantId}) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final loginRequest = LoginRequest(
      email: email.value,
      password: password.value,
      tenantId: '23',
      portalId: '1',
      formId: formId,
      emailColumn: emailColumn,
      passwordColumn: passwordColumn,
      nameColumn: nameColumn,
      loggedFrom: "MOBILE",
    );

    bool isValidLogin = await loginRequest.usernamefieldsValidation();

    if (!isValidLogin) {
      controller.hasEmailError.value = true;
      return Snack.errorSnack(context, Strings.alert_error_invalidUser);
    } else {
      controller.hasEmailError.value = false;
    }

    bool isValidPass = await loginRequest.passwordfieldsValidation();

    if (!isValidPass) {
      controller.hasPasswordError.value = true;
      return Snack.errorSnack(context, Strings.alert_error_invalidPasswor);
    } else {
      controller.hasPasswordError.value = false;
    }

    setState(() {
      isLoginProgress = true;
    });

    final requestBody = {
      "tenantId": "23",
      "portalId": "1",
      "email": loginRequest.email,
      "password": loginRequest.password,
      "formId": formId,
      "emailColumn": emailColumn,
      "passwordColumn": passwordColumn,
      "nameColumn": nameColumn

      // "tenantId": 23,
      // "portalId": 1,
      // "email": loginRequest.email,
      // "otp": 0000,
      // "password": loginRequest.password,
      // "formId": formId,
      // "emailColumn": emailColumn,
      // "passwordColumn": passwordColumn,
      // "nameColumn": nameColumn,
      // "loggedFrom": loginRequest.loggedFrom
    };
    printRequestBody(requestBody);
    var headers = {"Accept": "application/json;text/html"};

    if (tenantId1 != null) {
      headers["Token"] = "tenantId $tenantId1"; // Adding space after 'tenantId'
    }

    print("Headers: $headers");

    try {
      var response = await Dio.Dio(
        Dio.BaseOptions(baseUrl: ApiUrls.MainPortalURL, headers: headers),
      ).post("validateMaster", data: requestBody);

      String decryptedData = AaaEncryption.dec_base64(response.data);
      final decryptedJson = json.decode(decryptedData);
      var data = LoginResponse.fromJson(decryptedJson);

      AaaEncryption.sToken = data.token.toString();
      AaaEncryption.IvVal = enc.IV.fromBase64(data.iv.toString());
      AaaEncryption.KeyVal = enc.Key.fromBase64(data.key.toString());
      sessionController.setSession(decryptedJson);

      var userEncryptedResponse = await Api()
          .clientWithHeader(responseType: Dio.ResponseType.plain)
          .get(EndPoint.getuserDetails);
      var encryptedData = userEncryptedResponse.data;

      Map<String, dynamic> userData = jsonDecode(AaaEncryption.decryptAESaaa(encryptedData));
      sessionController.userData = userData;
      storeLoginDetails(userData, encryptedData);
      await readSavedValue();
      redirectBasedOnSavedValue();
      // if (widget.title == "Start") {
      //   Get.offAll(DynamicForm(formId: 2, repositoryId: 1, workflowId: 1));
      // } else {
      //   Get.offAll(WorkflowList(
      //     sWorkflowId: 1,
      //     sType: 1,
      //   ));
      // }

      // Get.offAll(() => const Welcomepage(title: 'Welcomepage'));
    } catch (e) {
      e.printError();

      // print((e as DioException).response?.statusCode);
      if (((e as Dio.DioException).response?.statusCode ?? 0) == 300) {
        List<dynamic> data = (e).response?.data;
        if (data.length == 1) {
          LoginPortal(tenantId: "23");
        } else if (data.isNotEmpty) {
          // selectTenet(data);
        }
      } else {
        Snack.errorSnack(context, Strings.alert_error_invalidUserorPassword);
      }
    }

    setState(() {
      isLoginProgress = false;
    });
  }

  Future<void> storeLoginDetails(Map<String, dynamic> data, dynamic encryptedData) async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    pre.setString('Userdata', encryptedData.toString());
    pre.setString('userid', data['id'].toString());
    pre.commit();
    sessionController.setSessionUser(data);

    pre.setString('userid', data['id']);
    pre.setString('username', data['firstName'] + " " + data['lastName']);
    pre.setString('email', data['email']);
    pre.setString('avatar', data['avatar']);
    pre.commit();
  }

  void onEmailChanged(String value) {
    email.value = value;
  }

  void onPasswordChanged(String value) {
    password.value = value;
  }

  void printRequestBody(Map<String, dynamic> requestBody) {
    // Pretty print the request body
    String prettyRequestBody = JsonEncoder.withIndent('  ').convert(requestBody);
    print("Request Body: $prettyRequestBody");
  }

  Future<void> readSavedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedValue = prefs.getString('button_status') ?? 'Default Value';
    // formId = prefs.getInt('formId')!;
    workflowId = prefs.getInt('workflowId')!; // Provide a default value
    print("Saved Value: $savedValue");
    print("Saved Value: $formId");
    print("Saved Value: $workflowId");
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
}
