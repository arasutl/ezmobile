import 'dart:convert';

import 'package:ez/core/ApiClient/ApiHandler.dart';
import 'package:ez/core/v5/controllers/session_controller.dart';
import 'package:ez/screens/TrackList.dart';
import 'package:ez/screens/UsernameLogin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ez/Const/CustomColors.dart';
import 'package:ez/screens/EmailLogin.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../features/dynamic_form/dynamic_form.dart';

class Welcomepage extends StatefulWidget {
  const Welcomepage({super.key, required this.title});

  final String title;

  @override
  State<Welcomepage> createState() => _WelcomepageState();
}

class _WelcomepageState extends State<Welcomepage> {
  final apiHandler = ApiHandler();
  final sessionController = Get.put(SessionController());
  String workflow = '';
  int workflowId = 0;
  Map<String, dynamic> settings = {};

  late int formId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PortalWhichLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          //  color: CustomColors.ezpurpleLite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
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
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: GestureDetector(
                      onTap: () {
                        // Call your method here
                        showAlert(context);
                      },
                      child: Icon(
                        MdiIcons.logout, // Icon to display
                        color: Colors.black, // Icon color
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                color: CustomColors.ezpurple,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 40, right: 8, left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello ,",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35),
                      ),
                      SizedBox(
                        height: 65,
                      ),
                      Text(
                        "Welcome back.,\n How can we help you today?",
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    // Background color
                    border: Border.all(
                      color: CustomColors.ezpurple, // Border color
                      width: 1.5, // Border width
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                        child: Text(
                          "Start and Submit your App",
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 5, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(),
                            SizedBox(
                              width: 190, // Fixed width
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.to(DynamicForm(formId: 2, repositoryId: 1, workflowId: 1));
                                  print("Button Pressed!");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColors.ezpurple, // Background color
                                  elevation: 5, // Elevation
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Rounded corners
                                  ),
                                  textStyle: TextStyle(
                                      // Text size
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.white),
                                ),
                                child: Text(
                                  "Start your application",
                                  style: TextStyle(
                                    color: CustomColors.white, // Set text color to white
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    // Background color
                    border: Border.all(
                      color: CustomColors.ezpurple, // Border color
                      width: 1.5, // Border width
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(
                          "Track your receipts and claim",
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 5, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(),
                            SizedBox(
                              width: 190, // Fixed width
                              height: 45, // Fixed height
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.to(WorkflowList(
                                    sWorkflowId: 1,
                                    sType: 1,
                                  ));
                                  print("Button Pressed!");
                                  print("Button Pressed!");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColors.ezpurple, // Background color
                                  elevation: 5, // Elevation
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Rounded corners
                                  ),
                                ),
                                child: Text(
                                  "Track",
                                  style: TextStyle(
                                    color: CustomColors.white, // Set text color to white
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void showAlert(BuildContext context) {
    print('showalert.....');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("LOGOUT"),
        content: const Text("Do You Want To Logout?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => {Navigator.of(context).pop()},
            style: TextButton.styleFrom(
              backgroundColor: CustomColors.ezpurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: const BorderSide(width: 2, color: CustomColors.ezpurple)),
            ),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
            ),
          ),
          TextButton(
            onPressed: () => {
              clear(),
              Navigator.of(context).pop(),
              Get.offAll(() => Usernamelogin(
                    title: "Username",
                    workflowId: workflowId,
                    settings: settings,
                  ))
            },
            style: TextButton.styleFrom(
              backgroundColor: CustomColors.ezpurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: const BorderSide(width: 2, color: CustomColors.ezpurple)),
            ),
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
            ),
          ),
          /* TextButton(
            onPressed: () {
              sessionController.userdata = '';
              sessionController.token = ''.obs;
              sessionController.iv = ''.obs;
              sessionController.userid = ''.obs;

              sessionController.deleteSession();
              Navigator.of(context).pop();
              Get.offAndToNamed("/loginscreen");
            },
            child: Container(
              color: Colors.green,
              padding: const EdgeInsets.all(14),
              child: const Text("ok"),
            ),
          ),*/
        ],
      ),
    );
    /* AlertDialog(
      title: Text(''),
      content: Text('botitledy'),
      actions: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: CustomColors.green),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No')),
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: CustomColors.red),
            onPressed: () {},
            child: const Text(
              'Yes',
            )),
      ],
    );*/
  }

  void clear() {
    sessionController.userdata = '';
    sessionController.token = ''.obs;
    sessionController.iv = ''.obs;
    sessionController.userid = ''.obs;

    sessionController.deleteSession();
  }

  void PortalWhichLogin(BuildContext context) async {
    try {
      // Fetch data from the API
      final data = await apiHandler.fetchDetails();

      // Extract required fields
      workflow = data['workflow'] ?? '';
      workflowId = data['workflowId'] ?? 0;
      final settingsJson = data['settingsJson'] ?? '{}';

      // Decode settingsJson
      settings = jsonDecode(settingsJson);
      final loginType = settings['authentication']?['loginType'] ?? '';
      formId = settings['formId'] ?? 0;
      // Navigate to the next page with extracted data
      // if (loginType == 'MASTER_LOGIN') {
      //   // Navigate to the Username Page
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => Usernamelogin(
      //         title: "Username",
      //         workflow: workflow,
      //         workflowId: workflowId,
      //         settings: settings,
      //       ),
      //     ),
      //   );
      // } else {
      //   // Navigate to the OTP Page
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => Phonelogin(
      //         title: 'PhoneLogin',
      //         // workflow: workflow,
      //         // workflowId: workflowId,
      //         // settings: settings,
      //       ),
      //     ),
      //   );
      // }
    } catch (e) {
      print('Error: $e');
      // Optionally show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data. Please try again.')),
      );
    }
  }
}
