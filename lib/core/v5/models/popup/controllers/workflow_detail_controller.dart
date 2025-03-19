import 'dart:convert';

import 'package:ez/core/v5/utils/InboxDetails.dart';
import 'package:ez/core/v5/utils/helper/aes_encryption.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../../features/workflow/view/onBoardScreen.dart';
import '../../../../../routes.dart';
import '../../../../CustomColors.dart';
import '../../../api/auth_repo.dart';
import '../../../utils/helper/alert.dart';
import '../../option.dart';
import '../form/components/MultiSelectMain.dart';
import '../form/components/labels.dart';
import 'gridviewhomecontroller.dart';

class WorkflowDetailController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  //late RxList<InboxDetails> idSelected;
  int iSelectedIndex = 0;
  String sRaisedAt = '';
  String transaction_createdAt = '';
  String srequesno = '';
  String sFormId = '';
  String repositoryId = '';
  String sFormEntryId = '';
  String sProcessId = '';
  String sWorkFlowId = '';
  String sActivityId = '';
  InboxDetails? inboxDetails;
  bool bIsFormBaseWorkFlow = true;
  String sItemId = '';
  static String sRequestNo = '';
  //String sFormJSon = '';
  String sSelectedFormID = '';
  String sTransactionId = '';
  Map<String, dynamic> mFormJSon = {};
  Map<String, dynamic> sFormJSon = {};
  // Map<String, dynamic> sFullJSon = {};
  List<Widget> wButtons = [];
  List<Widget> wButtonsFilled = [];
  List<Widget> wButtonsGroup = [];
  List<dynamic> sLActionButtons = [];

  RxInt iFilecount = 0.obs;
  RxInt iMsgCount = 0.obs;
  RxInt iTaskCount = 0.obs; //

  String sSelectedButtonOperation = '';

  bool bFab = false;
  List<Map<String, dynamic>> folderDatas = [];

  List<Map<String, dynamic>> InboxDataewew = [];

  List<Map<String, dynamic>> InboxDataNew = [];
  final formFieldsValues = <String, dynamic>{}.obs;
  late bool bFilledButton = false;

  //Action Button as List
  Widget setupAlertDialoadContainer() {
    return SizedBox(
        height: 200,
        width: 200,
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: wButtons.length,
            itemBuilder: (context, index) {
              //filedatas item = controllerpopup.wButtons.elementAt(index);
              return wButtons.elementAt(index);
            }));
  }

  getButtonlist() {
    wButtons = [];
    wButtonsFilled = [];

    for (int i = 0; i < mFormJSon['rules'].length; i++) {
      if (mFormJSon['rules'][i]['fromBlockId'] == sActivityId) {
        wButtons.add(createIcons(mFormJSon['rules'][i]['proceedAction'].toString(), false));
        wButtonsFilled.add(createIcons(mFormJSon['rules'][i]['proceedAction'].toString(), true));
      }
    }

    //Add Save Button
    wButtonsFilled.add(createIcons('Save', true));

//Forward Button
    for (int i = 0; i < mFormJSon['blocks'].length; i++) {
      if (mFormJSon['blocks'][i]['id'] == sActivityId) {
        if (mFormJSon['blocks'][i]['settings']['internalForward'] != null) {
          if (mFormJSon['blocks'][i]['settings']['internalForward']) {
            Widget wMultiselect = const MultiSelectMain();
            print('wMultiselect().toString()');
            if (wMultiselect.key != null) {
              wButtons.add(wMultiselect);
              wButtonsFilled.add(wMultiselect);
            } /*else
              wButtons.add(Labels(sLabel: 'wMultiselect - sss', bRequired: false));*/
          }
        }
      }
    }
  }

  getButtonlistMyInbox() {
    wButtons = [];
    wButtonsFilled = [];
    for (int i = 0; i < sLActionButtons.length; i++) {
      wButtons.add(createIcons(sLActionButtons[i].toString(), false));
      wButtonsFilled.add(createIcons(sLActionButtons[i].toString(), true));
    }

    //Add Save Button
    wButtonsFilled.add(createIcons('Save', true));

    if (wButtons.isEmpty) {
      wButtons.add(createIcons('Submit', false));
      wButtonsFilled.add(createIcons('Submit', true));
    }

    //Interal forward
    if (mFormJSon['blocks'] != null) {
      for (int i = 0; i < mFormJSon['blocks'].length; i++) {
        print('${mFormJSon['blocks'][i]['id']}    $sActivityId');
        if (mFormJSon['blocks'][i]['id'] == sActivityId) {
          if (mFormJSon['blocks'][i]['settings']['internalForward'] != null) {
            if (mFormJSon['blocks'][i]['settings']['internalForward']) {
              Widget wMultiselect = const MultiSelectMain();
              print('wMultiselect().toString()');
              if (wMultiselect.key != null) {
                wButtons.add(const MultiSelectMain());
                wButtonsFilled.add(const MultiSelectMain());
              } else {
                wButtons.add(const Labels(sLabel: 'Forward', bRequired: false));
              }
            }
          }
        }
      }
    }
  }

  Widget createIcons(String sButtintext, bool bFilled) {
    switch (sButtintext) {
      case 'Submit':
      case 'Ignore':
        return buttonGenerate(
            sButtintext,
            CustomColors.navyblue,
            Icon(
              MdiIcons.arrowRight,
              color: CustomColors.navyblue,
            ),
            bFilled);
      case 'Forward':
        return buttonGenerate(
            sButtintext,
            Colors.orange,
            Icon(
              MdiIcons.arrowRight,
              color: Colors.orange,
            ),
            bFilled);
      case 'Rightsize':
      case 'Complete':
      case 'Approve':
        return buttonGenerate(
            sButtintext,
            Colors.green,
            Icon(
              MdiIcons.check,
              color: Colors.green,
            ),
            bFilled);
      case 'Terminate':
      case 'Close':
        return buttonGenerate(
            sButtintext,
            Colors.redAccent,
            Icon(
              MdiIcons.close,
              color: Colors.redAccent,
            ),
            bFilled);
      case 'Reject':
        return buttonGenerate(
            sButtintext,
            Colors.deepOrange,
            Icon(
              MdiIcons.close,
              color: Colors.deepOrange,
            ),
            bFilled);
      case 'Save':
        return buttonGenerate(
            sButtintext,
            Colors.lightBlue,
            Icon(
              MdiIcons.contentSave,
              color: Colors.lightBlue,
            ),
            bFilled);
      default:
        return buttonGenerate(
            sButtintext,
            Colors.purple,
            Icon(
              MdiIcons.arrowRight,
              color: Colors.purple,
            ),
            bFilled);
    }
  }

  buttonGenerate(String sname, Color clr, Icon icn, bool bFilled) {
    ///////////////////fffffffff
    return !bFilled
        ? Container(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                textStyle: TextStyle(color: clr),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0),
                    side: BorderSide(width: 2, color: clr)),
              ),
              onPressed: () => {sSelectedButtonOperation = sname, buttonAction()},
              icon: icn,
              label: Text(
                sname,
                style: TextStyle(color: clr),
              ),
            ))
        : Container(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
            margin: const EdgeInsets.all(5),
            child: TextButton(
              onPressed: () => {sSelectedButtonOperation = sname, buttonAction()},
              style: TextButton.styleFrom(
                backgroundColor: clr,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(width: 2, color: clr)),
              ),
              child: Text(
                sname.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
              ),
            ));
  }

  Future buttonAction() async {
    String responsedata = '';
    final controllerGV = Get.put(GridViewHomeController());

    Map<String, dynamic> newMap = {};
    controllerGV.filedsIDwithLabel.forEach((key, value) {
      newMap[key.toString()] = value;
    });

    // for 'Save' button click
    if (sSelectedButtonOperation == 'Save') sSelectedButtonOperation = '';

    String sForData = '{"formId":$sFormId,"formEntryId":$sFormEntryId,"fields":${jsonEncode(newMap)}}';

    String sSubmitPost = '{"workflowId":$sWorkFlowId,"transactionId":$sTransactionId,"review":"$sSelectedButtonOperation","formData":$sForData,"userIds":[],"groupIds":[]}';

    isLoading.value = true;

    if (sSelectedButtonOperation.toLowerCase() == 'forward') {
    } else {
      String jsonString = jsonEncode(AaaEncryption.EncryptData(sSubmitPost.replaceAll(r"/", "")));
      print(sSubmitPost.replaceAll(r"/", ""));
      final responses = await AuthRepo.postWorkflow(jsonString);
      if (responses.statusCode == 201) {
/*        Map<String, dynamic> valueMap =
            jsonDecode(AaaEncryption.decryptAESaaa(responses.toString()));*/
        /*       MotionToastWidget().displaySuccessMotionToast(
            sRequestNo + ' Reqsuest Process ', Get.context as BuildContext);*/
        alert(title: 'Success', subtitle: '$sRequestNo Reqsuest Process', type: 'Positive');
      } else {
        alert(title: 'Error', subtitle: '$sRequestNo Request Not Process', type: 'Negative');
/*        MotionToastWidget().displayErrorMotionToast(
            sRequestNo + 'Request Not Process', Get.context as BuildContext);*/
      }

      await Future.delayed(const Duration(seconds: 4), () {
        print('Navigation... to be do with reload');
        AppRoutes.initialRouteForIndex(0); //navigation sangili 16-2-24

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
              Get.context as BuildContext, MaterialPageRoute(builder: (_) => const OnBoardScreen()));
        });
      });
      // MotionToastWidget().displayErrorMotionToast('Request Not Process', ctx);
    }
    return responsedata;
  }

  // for new update  -arun
  Future buttonActionGroup() async {
    String responsedata = '';
    final controllerGV = Get.put(GridViewHomeController());

    Map<String, dynamic> newMap = {};
    controllerGV.filedsIDwithLabel.forEach((key, value) {
      newMap[key.toString()] = value;
    });

    // for 'Save' button click
    if (sSelectedButtonOperation == 'Save') {
      sSelectedButtonOperation = '';

      String sForData = '{"formId":$sFormId,"formEntryId":$sFormEntryId,"fields":${jsonEncode(newMap)}}';

      String sSubmitPost = '{"workflowId":$sWorkFlowId,"transactionId":$sTransactionId,"review":"$sSelectedButtonOperation","formData":$sForData,"userIds":[],"groupIds":[]}';

      isLoading.value = true;

      if (sSelectedButtonOperation.toLowerCase() == 'forward') {
      } else {
        String jsonString = jsonEncode(AaaEncryption.EncryptData(sSubmitPost.replaceAll(r"/", "")));
        print(sSubmitPost.replaceAll(r"/", ""));
        final responses = await AuthRepo.postWorkflow(jsonString);
        if (responses.statusCode == 201) {
/*        Map<String, dynamic> valueMap =
            jsonDecode(AaaEncryption.decryptAESaaa(responses.toString()));*/
          /*       MotionToastWidget().displaySuccessMotionToast(
            sRequestNo + ' Reqsuest Process ', Get.context as BuildContext);*/
          alert(title: 'Success', subtitle: '$sRequestNo Reqsuest Process', type: 'Positive');
        } else {
          alert(title: 'Error', subtitle: '$sRequestNo Request Not Process', type: 'Negative');
/*        MotionToastWidget().displayErrorMotionToast(
            sRequestNo + 'Request Not Process', Get.context as BuildContext);*/
        }

        await Future.delayed(const Duration(seconds: 4), () {
          print('Navigation... to be do with reload');
          AppRoutes.initialRouteForIndex(0); //navigation sangili 16-2-24

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
                Get.context as BuildContext, MaterialPageRoute(builder: (_) => const OnBoardScreen()));
          });
        });
        // MotionToastWidget().displayErrorMotionToast('Request Not Process', ctx);
      }
      return responsedata;
    } else if (sSelectedButtonOperation == 'Forward') {
      print('Forward..');
    } else if (sSelectedButtonOperation == 'Others') {
      print('others..');
      showpopup();
    }
  }

  void showpopup() {
    Get.dialog(
      AlertDialog(
        title: const Text('Action List'),
        content: setupAlertDialoadContainer(),
      ),
    );
  }

  buttonGenerateGroup(String sname, Color clr, Icon icn, bool bFilled) {
    ///////////////////fffffffff
    return !bFilled
        ? Container(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                textStyle: TextStyle(color: clr),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0),
                    side: BorderSide(width: 2, color: clr)),
              ),
              onPressed: () => {sSelectedButtonOperation = sname, buttonActionGroup()},
              icon: icn,
              label: Text(
                sname,
                style: TextStyle(color: clr),
              ),
            ))
        : Container(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
            margin: const EdgeInsets.all(5),
            child: TextButton(
              onPressed: () => {sSelectedButtonOperation = sname, buttonActionGroup()},
              style: TextButton.styleFrom(
                backgroundColor: clr,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(width: 2, color: clr)),
              ),
              child: Text(
                sname.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
              ),
            ));
  }

  Widget createIconsGroup(String sButtintext, bool bFilled) {
    switch (sButtintext) {
      case 'Others':
        return buttonGenerateGroup(
            sButtintext,
            CustomColors.navyblue,
            Icon(
              MdiIcons.arrowRight,
              color: CustomColors.navyblue,
            ),
            bFilled);
      case 'Forward':
        return buttonGenerateGroup(
            sButtintext,
            Colors.orange,
            Icon(
              MdiIcons.shareOutline,
              color: Colors.orange,
            ),
            bFilled);
      case 'Save':
        return buttonGenerateGroup(
            sButtintext,
            Colors.lightBlue,
            Icon(
              MdiIcons.contentSave,
              color: Colors.lightBlue,
            ),
            bFilled);
      default:
        return buttonGenerate(
            sButtintext,
            Colors.purple,
            Icon(
              MdiIcons.arrowRight,
              color: Colors.purple,
            ),
            bFilled);
    }
  }

  getButtonlistMyInboxGroup() {
    wButtonsGroup = [];
    wButtonsGroup.add(createIconsGroup('Save', false));
    wButtonsGroup.add(createIconsGroup('Forward', false)); //to be update
    wButtonsGroup.add(createIconsGroup('Others', false));
  }

  void assignDefaultValuesFields() {
    //436
    try {
      for (int i = 0; i < sFormJSon['panels'].length; i++) {
        for (int j = 0; j < sFormJSon['panels'][i]['fields'].length; j++) {
          formFieldsValues[sFormJSon['panels'][i]['fields'][j]['id']] = fieldValue(
              sFormJSon['panels'][i]['fields'][j]['type'].toString(), null); // aes decrypt pananum
        }
      }
    } catch (e) {
      print('Error$e');
    }
  }
}

// form field's model initial value
dynamic fieldValue(String type, dynamic value) {
  switch (type) {
    case 'dropdown':
      return value == null
          ? const Option(label: '', value: '')
          : Option(label: value, value: value);
    default:
      return value ?? '';
  }
}
