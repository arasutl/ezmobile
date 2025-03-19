import 'dart:async';

import 'package:ez/core/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ez/Const/CustomColors.dart';
import 'package:ez/screens/Homepage.dart';
import 'package:ez/screens/WelcomePage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class Phonelogin extends StatefulWidget {
  const Phonelogin({super.key, required this.title});

  final String title;

  @override
  State<Phonelogin> createState() => _PhoneloginState();
}

class _PhoneloginState extends State<Phonelogin> {
  TextEditingController phoneOtpedt = TextEditingController();
  TextEditingController phoneedt = TextEditingController();
  // ..text = "123456";

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";

  String staticPhone = "";
  bool showError = false;
  bool showOtp = false;
  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
    staticPhone = "9025335721";
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  Widget buildInstructionText() {
    return Text(
      "Enter your Phonenumber and authenticate to receive your OTP (One Time Password)"
      "to securely access your portal.",
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );
  }

  Widget buildOtp() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Enter the code (OTP) you just received in your Phonenumber",
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
          child: PinCodeTextField(
            length: 6,
            obscureText: false,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(5),
              fieldHeight: 35,
              fieldWidth: 35,
              activeFillColor: Colors.transparent,
              inactiveFillColor: Colors.transparent,
              selectedFillColor: Colors.transparent,
              activeColor: Colors.grey,
              inactiveColor: Colors.grey,
              selectedColor: CustomColors.ezpurple,
            ),
            animationDuration: Duration(milliseconds: 300),
            backgroundColor: Colors.white,
            enableActiveFill: true,
            errorAnimationController: errorController,
            controller: phoneOtpedt,
            onCompleted: (v) {
              print("Completed");
            },
            onChanged: (value) {
              print(value);
              setState(() {
                currentText = value;
              });
            },
            beforeTextPaste: (text) {
              print("Allowing to paste $text");
              return true;
            },
            appContext: context,
          ),
        ),

        const SizedBox(height: 20), // Add spacing

        ElevatedButton(
          onPressed: () {
            Get.to(Welcomepage(
              title: 'Continue',
            ));
            print("Button Pressed!");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.ezpurple,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Continue",
            style: TextStyle(
              color: CustomColors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 15), // Add spacing

        Text(
          "04:29",
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),

        const SizedBox(height: 10), // Add spacing

        Text.rich(
          TextSpan(
            text: "Didn't receive the code? ",
            style: const TextStyle(color: Colors.black, fontSize: 16),
            children: [
              TextSpan(
                text: 'Resend',
                style: const TextStyle(
                  color: CustomColors.ezpurple,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 1),
      child: Container(
        decoration: BoxDecoration(
          // Background color
          border: Border.all(
            color: CustomColors.red, // Border color
            width: 1.5, // Border width
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                MdiIcons.alertCircleOutline, // Icon to display
                color: Colors.red, // Icon color
              ),
              SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: "The phone number you have entered is not in our system. If you are "
                        "new user, please register your phonenumber ", // Normal text
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'here', // The "resend" word
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CustomColors.red, // Custom color for "resend"
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                          decorationColor: CustomColors.red, // Color of the underline
                          decorationThickness: 2.0, // Underline the text
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
                        // color: Colors.purple,
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: const ImageIcon(
                          AssetImage('assets/images/logo/ezofis/mark.png'),
                          color: CustomColors.ezpurple,
                          size: 30,
                          //color: Colors.white,
                        )),
                    Text(
                      Strings.TitleName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
                    ),
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
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(children: [
                            Text(
                              "Please enter a valid phone number to access your portal",
                              style: const TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: phoneedt,
                              decoration: InputDecoration(
                                hintText: '9876543210',
                                fillColor: CustomColors.ezpurple
                                    .withOpacity(0.1), // Purple background with reduced opacity
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: CustomColors.ezpurple
                                        .withOpacity(0.1), // Outline color when not focused
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: CustomColors.ezpurple, // Outline color when focused
                                    width: 2.0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 7.0, // Adjust height
                                  horizontal: 12.0, // Adjust horizontal spacing
                                ),
                              ),
                              onChanged: (value) {
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
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (phoneedt.text.trim().isEmpty) {
                                    showError = false;
                                    showOtp = false;
                                  } else if (phoneedt.text.trim() != staticPhone) {
                                    showError = true;
                                    showOtp = false;
                                  } else {
                                    showError = false;
                                    showOtp = true;
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.ezpurple, // Background color
                                elevation: 5, // Elevation
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8), // Rounded corners
                                ),
                              ),
                              child: Text(
                                "Authenticate",
                                style: TextStyle(
                                  color: CustomColors.white, // Set text color to white
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (phoneedt.text.isEmpty ||
                                (showError == false && showOtp == false)) ...[
                              SizedBox(height: 80),
                              buildInstructionText(),
                            ] else if (showError) ...[
                              buildErrorMessage(),
                              buildInstructionText(),
                            ] else if (showOtp) ...[
                              buildOtp(),
                            ],
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
}
