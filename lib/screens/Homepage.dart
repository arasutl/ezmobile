import 'dart:convert';

import 'package:ez/core/ApiClient/ApiHandler.dart';
import 'package:ez/core/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ez/Const/CustomColors.dart';
import 'package:ez/screens/EmailLogin.dart';
import 'package:ez/screens/PhoneLogin.dart';
import 'package:ez/screens/UsernameLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  Color _containerColor = Colors.white;
  final apiHandler = ApiHandler();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
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
          //  color: CustomColors.ezpurpleLite,
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
              Container(
                height: 300,
                color: CustomColors.ezpurple,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                      child: Text(
                        Strings.Homesavetext,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35),
                      ),
                    ),
                    SizedBox(
                      height: 45,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(),
                          ImageIcon(
                            AssetImage('assets/images/logo/belltemple/bellicon.png'),
                            color: CustomColors.white,
                            size: 110,
                            //color: Colors.white,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  Strings.HomeMessage,
                  style: const TextStyle(color: Colors.black, fontSize: 19),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _containerColor,
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
                                onPressed: () async {
                                  await prefs.setString('button_status', 'Start');
                                  PortalWhichLogin("Start", context);
                                  setState(() {
                                    _containerColor = CustomColors
                                        .ezpurpleLite1; // Change container background color
                                  });
                                  // Get.to(Usernamelogin(
                                  //   title: 'EmailLogin',
                                  // ));
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
                                  print("Button Pressed!");
                                  PortalWhichLogin("Track", context);
                                  setState(() {
                                    _containerColor = CustomColors
                                        .ezpurpleLite1; // Change container background color
                                  });
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

  void PortalWhichLogin(String stringPage, BuildContext context) async {
    try {
      // Fetch data from the API
      final data = await apiHandler.fetchDetails();

      // Extract required fields
      final workflow = data['workflow'] ?? '';
      final workflowId = data['workflowId'] ?? 0;
      final settingsJson = data['settingsJson'] ?? '{}';

      // Decode settingsJson
      final settings = jsonDecode(settingsJson);
      final loginType = settings['authentication']?['loginType'] ?? '';
      final formId = settings['authentication']?['formId'] ?? 0;
      // Navigate to the next page with extracted data
      if (loginType == 'MASTER_LOGIN') {
        await prefs.setInt('workflowId', workflowId);
        //  await prefs.setInt('formId', formId);
        // Navigate to the Username Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Usernamelogin(
              title: stringPage,
              workflowId: workflowId,
              settings: settings,
            ),
          ),
        );
      } else {
        // Navigate to the OTP Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Phonelogin(
              title: 'PhoneLogin',
              // workflow: workflow,
              // workflowId: workflowId,
              // settings: settings,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      // Optionally show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data. Please try again.')),
      );
    }
  }
}
