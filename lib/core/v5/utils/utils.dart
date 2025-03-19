import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ez/core/CustomColors.dart';
import 'package:ez/core/v5/controllers/session_controller.dart';

import 'package:ez/core/v5/utils/file_fns.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';

mixin Utils {
  static Future<bool> checkInternetConnectivity() async {
    //bool connection = await DataConnectionChecker().hasConnection;

    final ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return false;
    }
  }

  static List<dynamic> getActionButtonList(Map<String, dynamic> flowJson) {
    List<dynamic> buttons = [
      {"proceedAction": "Clear"}
    ];

    if (flowJson.containsKey("blocks") && flowJson.containsKey("rules")) {
      List<dynamic> blocks = flowJson['blocks'];
      List<dynamic> rules = flowJson['rules'];

      for (var block in blocks) {
        if (block['type'] == "START") {
          String blockId = block['id'];
          for (var rule in rules) {
            if (rule['fromBlockId'] == blockId) {
              buttons.add(rule);
            }
          }
        }
      }
    }

    return buttons;
  }

  static Widget getActionButtons(String action, String buttonText, VoidCallback onPress) {
    switch (action) {
      case 'Submit':
      case 'Ignore':
        return ElevatedButton.icon(
          onPressed: onPress,
          icon: Icon(
            MdiIcons.arrowRight,
            color: CustomColors.ezpurple,
          ),
          label: Text(
            buttonText,
            style: const TextStyle(
              color: CustomColors.ezpurple, // Set text color to red for 'Submit'
            ),
          ),
        );
        break;
      case 'Forward':
        return ElevatedButton.icon(
          onPressed: onPress,
          icon: Icon(
            MdiIcons.arrowRight,
            color: Colors.orange,
          ),
          label: Text(buttonText),
        );
        break;
      case 'Rightsize':
      case 'Complete':
      case 'Approve':
        return ElevatedButton.icon(
          onPressed: onPress,
          icon: Icon(
            MdiIcons.check,
            color: Colors.green,
          ),
          label: Text(buttonText),
        );
        break;
      case 'Terminate':
      case 'Close':
        return ElevatedButton.icon(
          onPressed: onPress,
          icon: Icon(
            MdiIcons.close,
            color: Colors.redAccent,
          ),
          label: Text(buttonText),
        );
        break;
      case 'Reject':
        return ElevatedButton.icon(
          onPressed: onPress,
          icon: Icon(
            MdiIcons.close,
            color: Colors.deepOrange,
          ),
          label: Text(buttonText),
        );
        break;
      case 'Save':
        return ElevatedButton.icon(
          onPressed: onPress,
          icon: Icon(
            MdiIcons.contentSave,
            color: CustomColors.ezpurple,
          ),
          label: Text(
            buttonText,
            style: const TextStyle(
              color: CustomColors.ezpurple, // Set the text color to red
            ),
          ),
        );
        break;
      case 'Clear':
        return ElevatedButton.icon(
          onPressed: onPress,
          icon: Icon(
            MdiIcons.close,
            color: CustomColors.ezpurple,
          ),
          label: Text(
            buttonText,
            style: const TextStyle(
              color: CustomColors.ezpurple, // Set the text color to red
            ),
          ),
        );
        break;
      default:
        return ElevatedButton.icon(
          onPressed: onPress,
          icon: Icon(
            MdiIcons.arrowRight,
            color: Colors.purple,
          ),
          label: Text(buttonText),
        );
        break;
    }
  }

  static String getStandardDateTimeFormat(String value) {
    DateTime? parsedDate = DateTime.tryParse(value);

    if (parsedDate == null) {
      return "-";
    }

    DateFormat outputFormat = DateFormat('dd-MMM-yyyy hh:mm:ss a');
    String formattedDate = outputFormat.format(parsedDate.toLocal());

    return formattedDate;
  }

  static String getStandardDateFormat(String value) {
    DateTime? parsedDate = DateTime.tryParse(value);
    if (parsedDate != null) {
      DateFormat outputFormat = DateFormat('dd-MMM-yyyy');
      String formattedDate = outputFormat.format(parsedDate.toLocal());

      return formattedDate;
    }
    return "-";
  }

  static String fileIcon(String fileName) {
    final fileType = fileName.split('.').last.toLowerCase();
    final validTypes = validFileTypes();

    if (validTypes.contains(fileType)) {
      return '$path/$fileType.png';
    } else {
      return '$path/file.png';
    }
  }

  static dynamic isInitiatedByMatched(Map<String, dynamic> block) {
    bool status = false;
    SessionController sessionCtrl = Get.put(SessionController());

    List<dynamic> initiateBy = block["settings"]["initiateBy"];
    if (initiateBy.contains("USER")) {
      List<dynamic> users = block["settings"]["users"];
      if (users.contains("0")) {
        return true;
      }

      if (users.contains(sessionCtrl.userData["id"])) {
        return true;
      }
    }

    if (initiateBy.contains("GROUP")) {
      List<dynamic> groups = block["settings"]["groups"];
      SessionController sessionController = Get.find<SessionController>();
      Map<String, dynamic> userData = sessionController.userData;
      List<dynamic> userGroupIds =
          (userData["groups"] as List<dynamic>).map((e) => e["id"]).toList();

      for (var group in groups) {
        if (userGroupIds.contains(group)) {
          return true;
        }
      }
    }

    if (initiateBy.contains("DOMAIN_USER")) {
      List<dynamic> userDomains = block["settings"]["userDomains"];
      List<String> emailComponents = (sessionCtrl.userData["email"] as String).split("@");
      String domain = emailComponents[emailComponents.length - 1];
      if (userDomains.contains(domain)) {
        return true;
      }
    }

    return status;
  }
}
