import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:ez/Const/CustomColors.dart';
import 'package:ez/controllers/dynamic_form_controller.dart';
import 'package:ez/core/ApiClient/ApiHandler.dart';
import 'package:ez/core/ApiClient/endpoint.dart';
import 'package:ez/core/snack_bar.dart';
import 'package:ez/core/v5/api/api.dart';
import 'package:ez/core/v5/api/auth_repo.dart';
import 'package:ez/core/v5/controllers/session_controller.dart';
import 'package:ez/core/v5/models/popup/controllers/attachfilecontroller.dart';
import 'package:ez/core/v5/models/popup/widgetpopup/process_history.dart';
import 'package:ez/core/v5/models/popup/widgetpopup/workflow_attachments.dart';
import 'package:ez/core/v5/models/popup/widgetpopup/workflow_comment_list.dart';
import 'package:ez/screens/TrackList.dart';
import 'package:ez/screens/UsernameLogin.dart';
import 'package:path/path.dart' as p;

import 'package:ez/core/v5/utils/file_fns.dart';
import 'package:ez/core/v5/utils/helper/aes_encryption.dart';
import 'package:ez/core/v5/utils/utils.dart';
import 'package:ez/features/workflow/model/Panel.dart';
import 'package:ez/features/workflowinitiate/model/workflowmain.dart';
import 'package:ez/repositories/workflow_repository.dart';

import 'package:ez/screens/qr_code_scanner.dart';
import 'package:ez/widgets/editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart' as HTML;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/strings.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import "package:dio/dio.dart" as Dio;
import 'package:badges/badges.dart' as badges;

class MultiSelectDropdownItem {
  final String text;
  final dynamic value;
  bool showCheckbox = true;
  bool addNewController = false;
  // Initialize the selected property

  MultiSelectDropdownItem({
    required this.text,
    required this.value,
    this.showCheckbox = true,
    this.addNewController = false, // Default to false
  });
}

class DynamicForm extends StatefulWidget {
  dynamic rootData;
  dynamic initialDataForEdit;
  dynamic tableComponentData;
  dynamic tableComponentInitialData;
  int formId;
  int repositoryId;
  int workflowId;
  int? processId;
  int? transactionId;
  Map<String, dynamic>? existingDataFields;
  String pageTitle;
  List<dynamic> actionButtons;
  List<dynamic> formEditControls;
  List<dynamic> formSecureControls;
  String formEditAccess;
  String? activityId;
  int? formEntryId;
  Function(dynamic status)? canSubmit;
  bool? readonly = false;
  bool? forIndexing = false;
  // final File? pickedImage;
  String? paths;

  DynamicForm({
    super.key,
    required this.formId,
    required this.repositoryId,
    required this.workflowId,
    this.rootData,
    this.initialDataForEdit,
    this.tableComponentData,
    this.tableComponentInitialData,
    this.processId,
    this.transactionId,
    this.existingDataFields,
    this.actionButtons = const [],
    this.formEditControls = const [],
    this.formSecureControls = const [],
    this.formEditAccess = "FULL",
    this.pageTitle = "",
    this.activityId,
    this.formEntryId,
    this.canSubmit,
    this.readonly,
    this.forIndexing,
    this.paths,
    //this.pickedImage,
    // this.paths
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(debugLabel: "GlobalFormKey #Form");
  late WorkflowRepository workflowRepository;

  final _controller = PageController();
  String pageTitle = "";
  Map<String, dynamic> formValues = {};

  Map<String, List<Map<String, dynamic>>> tableData = {};
  Map<String, bool> tableDataLoading = {};
  Map<String, TextEditingController> textEditingController = {};
  Map<String, dynamic> defaultDropDownValues = {};
  Map<String, GlobalKey<FormFieldState>> formFieldStates = {};
  Map<String, GlobalKey<SfSignaturePadState>> signatureKeys = {};
  Map<String, bool> componentsVisibility = {};
  Map<String, List<String>> parentComponentChangeEvents = {};
  final sessionController = Get.find<SessionController>();
  final ImagePicker _imagePicker = ImagePicker();
  bool isLoading = false;
  Map<String, bool> isFileLoading = <String, bool>{};
  bool isWorkFlowLoading = false;
  String isWorkFlowError = "";
  WorkFlowMain? workFlowMain;
  List<dynamic> actionButtonList = [];
  Map<String, dynamic> textBuilderControllers = {};
  late TabController tabController = TabController(length: 3, vsync: this);
  int? taskCount = 0;
  List<int> fileIds = [];
  List<Map<String, dynamic>> comments = [];
  bool showAnswerIndicator = false;
  int totalAnswerIndicatorLevel = 0;
  int answerIndicatorLevel = 0;
  Map<String, List<AttachmentData>> workflowAttachmentData = {};
  final DynamicFormController dynamicFormController = Get.put(DynamicFormController());
  Map<String, String> formFieldErrors = {};
  final apiHandler = ApiHandler();
  bool userSignature = false;
  GlobalKey<SfSignaturePadState> signaturePadKey = GlobalKey<SfSignaturePadState>();
  String signature = "";
  List<dynamic> signatureList = [];
  String workflow = '';
  int workflowId = 0;
  Map<String, dynamic> settings = {};
  bool autoValidateWhenSwitchPage = false;
  List<dynamic> processNumberPrefix = [];
  List<dynamic> fileCheckList = [];

  Map<String, List<dynamic>> deleteFiles = {};

  String repositoryFieldsType = "DYNAMIC";
  Map<String, dynamic> formValues1 = {};
  Map<String, MultiSelectController<MultiSelectDropdownItem>> multiSelectControllers = {};
  int formId = 0;

  bool _hasCalledMethod = false;

  String loginType = '';
  int MFormId = 0;
  String usernameField = '';

  @override
  void initState() {
    workflowRepository = GetIt.instance<WorkflowRepository>();
    if (widget.pageTitle != "") {
      pageTitle = widget.pageTitle;
    }
    PortalWhichLoginforDefault();
    if (widget.tableComponentData == null) {
      getCommentsDetailsCount();
      getFileDetailsCount();
      fetchWorkflow();
    } else {
      if (widget.tableComponentInitialData != null) {
        formValues = widget.tableComponentInitialData;
      }
      bindCalculatedInputParentChangeEvents();
    }
    // readSavedValue();
    if (widget.tableComponentData == null) dynamicFormController.reset();
    super.initState();
  }

  @override
  void dispose() {
    //_scrollController.dispose();
    // Cancel any ongoing operations or listeners
    super.dispose();
  }

  // Future<void> readSavedValue() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   //savedValue = prefs.getString('button_status') ?? 'Default Value';
  //   formId1 = prefs.getInt('formId')!;
  //   workflowId1 = prefs.getInt('workflowId')!; // Provide a default value
  //  // print("Saved Value: $savedValue");
  // }
  void getCommentsDetailsCount() async {
    try {
      final responses =
          await AuthRepo.getCommentsList(widget.workflowId, widget.processId.toString());
      List lComments = jsonDecode(AaaEncryption.decryptAESaaa(responses.toString())) as List;
      dynamicFormController.commentsCount.value = lComments.length;
      setState(() {});
    } catch (e) {}
  }

  void getFileDetailsCount() async {
    try {
      final responses = await AuthRepo.getFileList(widget.workflowId, widget.processId.toString());
      List lFiles = jsonDecode(AaaEncryption.decryptAESaaa(responses.toString())) as List;
      // fileCount = lFiles.length;
      dynamicFormController.attachmentCount.value = lFiles.length;
      print("Attachment Count: ${dynamicFormController.attachmentCount.value}");

      // setState(() {});
    } catch (e) {}
  }

  Future<void> fetchWorkflow() async {
    Map<String, dynamic> workflowData = await workflowRepository.getWorkflowData(widget.workflowId);
    formId = (workflowData['wFormId'] as int?)!;

    if (formId != null) {
      print('Form ID: $formId');
    } else {
      print('Form ID not found');
    }
    Map<String, dynamic> flowJson = jsonDecode(workflowData["flowJson"]);
    if (widget.actionButtons.isEmpty) {
      actionButtonList = Utils.getActionButtonList(flowJson);
    } else {
      actionButtonList.add({"proceedAction": "Clear"});
      for (var element in widget.actionButtons) {
        actionButtonList.add(element);
      }
    }

    // print(flowJson["settings"]);
    try {
      processNumberPrefix = jsonDecode(flowJson["settings"]["general"]["processNumberPrefix"]);
    } catch (e) {}

    List<dynamic> blocks = flowJson["blocks"];
    for (var element in blocks) {
      if (element["type"] == "START" && widget.activityId == null ||
          widget.activityId != null && element["id"] == widget.activityId!) {
        if (widget.formSecureControls.isEmpty) {
          widget.formSecureControls = element["settings"]["formSecureControls"];
        }

        if (widget.formEditControls.isEmpty) {
          widget.formEditControls = element["settings"]?["formEditControls"] ?? [];
        }

        try {
          widget.formEditAccess = element["settings"]?["formEditAccess"] ?? [];
        } catch (e) {}

        if (element != null &&
            element["settings"] != null &&
            element["settings"]["userSignature"] != null) {
          userSignature = element["settings"]["userSignature"];
        }

        var block = jsonEncode(element);
        fileCheckList = element["settings"]["fileSettings"]["fileCheckList"] ?? [];
      }
    }

    // Check form secure controls structure
    if (widget.formSecureControls.isNotEmpty &&
        widget.formSecureControls[0] is Map<String, dynamic>) {
      List<String> newFormSecureControls = [];
      for (var formSecureControl in widget.formSecureControls) {
        if (formSecureControl.containsKey("user") &&
            formSecureControl["user"] == sessionController.userData["email"]) {
          newFormSecureControls = [...newFormSecureControls, ...formSecureControl["formFields"]];
        }
      }

      widget.formSecureControls = newFormSecureControls;
    }

    List<String> newFormSecureControls = [];
    for (String control in widget.formSecureControls) {
      if (control.contains(" @ ")) {
        newFormSecureControls.addAll(control.split(" @ "));
      } else {
        newFormSecureControls.add(control);
      }
    }
    widget.formSecureControls = newFormSecureControls;

    if (widget.formEditControls.isNotEmpty && widget.formEditControls[0] is Map<String, dynamic>) {
      List<String> newFormEditControls = [];
      for (var formEditControl in widget.formEditControls) {
        if (formEditControl.containsKey("user") &&
            formEditControl["user"] == sessionController.userData["email"]) {
          newFormEditControls = [...newFormEditControls, ...formEditControl["formFields"]];
        }
      }

      widget.formEditControls = newFormEditControls;
    }

    List<String> newFormEditControls = [];
    for (String control in widget.formEditControls) {
      if (control.contains(" @ ")) {
        newFormEditControls.addAll(control.split(" @ "));
      } else {
        newFormEditControls.add(control);
      }
    }
    widget.formEditControls = newFormEditControls;

    if (userSignature) {
      if (widget.processId != -1 && widget.processId != null) {
        signatureList = await workflowRepository.signWithProcessIdList(
            widget.workflowId, widget.processId ?? -1);
      }
    }

    var response = await Api()
        .clientWithHeader(responseType: Dio.ResponseType.plain)
        .get("${EndPoint.formworkflowinitiate}${formId}");

    String responseStr = AaaEncryption.decryptAESaaa(response.data);
    print("Decrypted Response: $responseStr");
    Map<String, dynamic> data = json.decode(responseStr);
    workFlowMain = WorkFlowMain.fromJson(data);

    final formJson = json.decode(workFlowMain?.formJson ?? "");
    print("Decrypted formJson: $formJson");
    try {
      var panels = formJson['panels'];
      if (panels != null && panels is List) {
        for (var panel in panels) {
          var fields = panel['fields'];
          if (fields != null && fields is List) {
            for (var field in fields) {
              var specificSettings = field['settings']?['specific'];
              if (specificSettings != null) {
                // Extract `defaultValueInSelectField`
                var defaultValue = specificSettings['defaultValueInSelectField'];
                print("defaultValueInSelectField: $defaultValue");
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error extracting defaultValueInSelectField: $e");
    }

    widget.rootData = Panel.fromJson(formJson);

    dynamic repositoryDetails = await workflowRepository.getRepositoryDetails(widget.repositoryId);
    repositoryFieldsType = repositoryDetails["fieldsType"];

    bindValuesFromInboxDetails();
    setComponentVisibilityIfPossible();
    setShowAnswerIndicator();
    updateAnswerIndicator();
    bindCalculatedInputParentChangeEvents();
    setState(() {});

    if (widget.canSubmit != null) {
      formFieldErrors.clear();

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_formKey.currentState != null &&
            _formKey.currentState!.validate() &&
            doManualValidation() &&
            _validateAllFieldsManually()) {
          widget.canSubmit!(true);
        } else {
          widget.canSubmit!(false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (widget.tableComponentData == null) {
      children = [renderWidgets(widget.rootData)];
    } else {
      List<Widget> tableWidgets = [];
      for (var i = 0; i < widget.tableComponentData.settings.specific.tableColumns.length; i++) {
        var tableColumn = widget.tableComponentData.settings.specific.tableColumns[i];
        var defaultValueemail =
            widget.tableComponentData.settings.specific.defaultValueInSelectField;
        print("defaultValueemail:$defaultValueemail");
        tableWidgets.add(Offstage(
            offstage: !(componentsVisibility.containsKey(tableColumn.id) &&
                    componentsVisibility[tableColumn.id]! ||
                !componentsVisibility.containsKey(tableColumn.id)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: loadComponents(
                  tableColumn, widget.tableComponentData.settings.specific.tableColumns),
            )));
      }
      tableWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 12.0, vertical: 10), // Add spacing from the previous widgets
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attach More Row
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Background color
                  border: Border.all(
                    color: CustomColors.ezpurpleLite1, // Border color
                    width: 1.5, // Border thickness
                  ),
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Space out the text and icon
                    children: [
                      // Attach More Text
                      Text(
                        "Attach More",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      // Attach More Icon
                      IconButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            if (workflowAttachmentData.isEmpty) {
                              print("No attachments to save.");
                              return;
                            }

                            workflowAttachmentData.forEach((key, attachments) {
                              if (attachments.isNotEmpty) {
                                for (var attachment in attachments) {
                                  dynamicFormController.workflowAttachmentDataFromForm
                                      .add(attachment);
                                }
                                dynamicFormController.attachmentCount.value += 1;
                              } else {
                                print("No attachments found for component ID: $key");
                              }
                            });
                            if (fileIds.isNotEmpty) {
                              formValues["fileIds"] = fileIds;
                            }
                            if (workflowAttachmentData.isNotEmpty) {
                              print("WorkflowNotEmpty");
                            }
                            Navigator.pop(context, formValues);
                          }
                        },
                        icon: Icon(
                          Icons.attach_file,
                          color: CustomColors.ezpurple, // Color of the icon
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16), // Add some spacing between Attach More and buttons
              // Cancel and Save Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread buttons across the row
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Any additional variables to reset can be included here
                      });
                      // if (workflowAttachmentData.isEmpty) {
                      //   print("No attachments to save.");
                      //   return;
                      // }
                      //
                      // workflowAttachmentData.forEach((key, attachments) {
                      //   if (attachments.isNotEmpty) {
                      //     for (var attachment in attachments) {
                      //       dynamicFormController.workflowAttachmentDataFromForm.add(attachment);
                      //     }
                      //   } else {
                      //     print("No attachments found for component ID: $key");
                      //   }
                      // });
                      // if (workflowAttachmentData.isNotEmpty) {
                      //   // Get the last key in the map
                      //   var lastKey = workflowAttachmentData.keys.last;
                      //
                      //   // Check if the list for this key is not empty
                      //   if (workflowAttachmentData[lastKey]!.isNotEmpty) {
                      //     // Remove the last attachment from the list
                      //     workflowAttachmentData[lastKey]!.removeLast();
                      //     print(
                      //         "Last attachment removed from workflowAttachmentData[$lastKey]: ${workflowAttachmentData[lastKey]}");
                      //   } else {
                      //     print("No attachments to remove for key: $lastKey");
                      //   }
                      // } else {
                      //   print("workflowAttachmentData is empty, nothing to remove.");
                      // }
                      //
                      // if (fileIds.isNotEmpty) {
                      //   int removedFileId = fileIds.removeLast(); // Remove the last file ID
                      //   print("Last file ID removed from fileIds: $removedFileId");
                      // } else {
                      //   print("fileIds list is empty, nothing to remove.");
                      // }
                      // Cancel button action
                      Navigator.pop(context); // Close the dialog or return to the previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 5, // Elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                        side: BorderSide(
                          color: CustomColors.ezpurple, // Border color
                          width: 1, // Border thickness
                        ), // Rounded corners
                      ),
                    ),
                    child: const Text(
                      " Cancel ",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        if (workflowAttachmentData.isEmpty) {
                          print("No attachments to save.");
                          return;
                        }

                        workflowAttachmentData.forEach((key, attachments) {
                          if (attachments.isNotEmpty) {
                            for (var attachment in attachments) {
                              dynamicFormController.workflowAttachmentDataFromForm.add(attachment);
                            }
                            dynamicFormController.attachmentCount.value += 1;
                          } else {
                            print("No attachments found for component ID: $key");
                          }
                        });
                        if (fileIds.isNotEmpty) {
                          formValues["fileIds"] = fileIds;
                        }
                        if (workflowAttachmentData.isNotEmpty) {
                          print("WorkflowNotEmpty");
                        }
                        Navigator.pop(context, formValues);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.ezpurple, // Background color
                      elevation: 5, // Elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9), // Rounded corners
                      ),
                    ),
                    child: Text(
                      "  Next  ",
                      style: TextStyle(
                        color: CustomColors.white, // Set text color to white
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      // tableWidgets.add(Center(
      //     child: ElevatedButton(
      //   onPressed: () {
      //     if (_formKey.currentState!.validate()) {
      //       _formKey.currentState!.save();
      //       Navigator.pop(context, formValues);
      //       // print("Valid Form");
      //     }
      //   },
      //   child: const Text(
      //     "Add",
      //   ),
      // )));

      children = [
        Column(children: [
          Expanded(child: LayoutBuilder(builder: (context, viewportConstraints) {
            return SingleChildScrollView(
              physics:
                  widget.tableComponentData != null ? null : const NeverScrollableScrollPhysics(),
              child: Form(
                  autovalidateMode: AutovalidateMode.disabled,
                  key: _formKey,
                  child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                      child: IntrinsicHeight(
                          child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: tableWidgets))))),
            );
          }))
        ])
      ];
    }

    SizedBox badgeLoader() {
      return const SizedBox(
          width: 8,
          height: 8,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            color: Colors.white,
          ));
    }

    Widget tabBar() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TabBar(
          labelColor: CustomColors.ezpurple,
          unselectedLabelColor: Colors.blueGrey,
          isScrollable: false,
          controller: tabController,
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: CustomColors.eztabSelectcolor),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(
                icon: badges.Badge(
              showBadge: false,
              badgeContent: const Text('',
                  style: TextStyle(
                      //fontSize: 14,
                      fontSize: 10,
                      color: Colors.white, //#00bfd6
                      fontWeight: FontWeight.w500)),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Color(0xFF00bfd6),
              ),
              child: Icon(MdiIcons.listBoxOutline),
            )),
            Tab(
                icon: Obx(() => badges.Badge(
                      badgeContent: Text(dynamicFormController.attachmentCount.value.toString(),
                          style: const TextStyle(
                              //fontSize: 14,
                              fontSize: 10,
                              color: Colors.white, //#00bfd6
                              fontWeight: FontWeight.w500)),
                      showBadge: dynamicFormController.attachmentCount.value > 0,
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: CustomColors.ezpurple,
                      ),
                      child: const Icon(Icons.attachment),
                    ))),
            Tab(
                icon: Obx(() => badges.Badge(
                      badgeContent: Text(dynamicFormController.commentsCount.value.toString(),
                          style: const TextStyle(
                              //fontSize: 14,
                              fontSize: 10,
                              color: Colors.white, //#00bfd6
                              fontWeight: FontWeight.w500)),
                      showBadge: dynamicFormController.commentsCount.value > 0,
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: CustomColors.ezpurple,
                      ),
                      child: Icon(MdiIcons.commentOutline),
                    ))),
            // Tab(
            //     icon: badges.Badge(
            //   badgeContent: const Text('',
            //       style: TextStyle(
            //           //fontSize: 14,
            //           fontSize: 10,
            //           color: Colors.white, //#00bfd6
            //           fontWeight: FontWeight.w500)),
            //   showBadge: false,
            //   badgeStyle: const badges.BadgeStyle(
            //     badgeColor: Color(0xFF00bfd6),
            //   ),
            //   child: Icon(MdiIcons.history),
            // )),
            // Tab(
            //     icon: badges.Badge(
            //   badgeContent: taskCount == null
            //       ? badgeLoader()
            //       : Text(taskCount.toString(),
            //           style: const TextStyle(
            //               fontSize: 10,
            //               color: Colors.white, //#00bfd6
            //               fontWeight: FontWeight.w500)),
            //   showBadge: taskCount == null || taskCount! > 0,
            //   badgeStyle: const badges.BadgeStyle(
            //     badgeColor: Color(0xFF00bfd6),
            //   ),
            //   child: Icon(MdiIcons.cubeOutline),
            // )),
            // Tab(
            //     icon: badges.Badge(
            //   badgeContent: const Text('',
            //       style: TextStyle(
            //           //fontSize: 14,
            //           fontSize: 10,
            //           color: Colors.white, //#00bfd6
            //           fontWeight: FontWeight.w500)),
            //   showBadge: false,
            //   badgeStyle: const badges.BadgeStyle(
            //     badgeColor: Color(0xFF00bfd6),
            //   ),
            //   child: Icon(MdiIcons.history),
            // )),
          ],
          // 9443451033
          onTap: (index) {},
        ),
      );
    }

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), // Set desired height for the app bar
          child: SafeArea(
            child: Container(
              color: Colors.white, // Background color of the app bar
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(5, 10, 15, 10),
                          child: Image.asset(
                            'assets/images/logo/belltemple/belllogo.png',
                            width: 150, // Desired width
                            height: 40, // Desired height
                            fit: BoxFit.contain, // Ensures image fits within the size
                          ),
                        ),
                        // Uncomment this Text if needed
                        // Text(
                        //   Strings.TitleName,
                        //   style: const TextStyle(
                        //       fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // SizedBox(
                        //   height: 30,
                        //   // width: 120,
                        //   // width: 100,
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       Get.to(WorkflowList(
                        //         sWorkflowId: 1,
                        //         sType: 1,
                        //       ));
                        //       print("Button Pressed!");
                        //     },
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: CustomColors.ezpurple, // Background color
                        //       elevation: 5, // Elevation
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(9), // Rounded corners
                        //       ),
                        //     ),
                        //     child: Text(
                        //       "Track Page",
                        //       style: TextStyle(
                        //         color: CustomColors.white, // Set text color to white
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        TextButton(
                            onPressed: () async {
                              Get.to(WorkflowList(
                                sWorkflowId: widget.workflowId,
                                sType: 1,
                              ));
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Set border radius
                                side: BorderSide(
                                  color: CustomColors.ezpurple, // Border color
                                  width: 1, // Border width
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5, // Decrease vertical padding to reduce height
                              ),
                              minimumSize: Size(0, 12), // Button padding
                            ),
                            child: Text(
                              "Track",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CustomColors.ezpurple,
                                fontWeight: FontWeight.w300, // Medium (use w400 for Regular)
                                //  fontSize: 16, // Optional text styling
                              ),
                            )),
                        // Padding(
                        //   padding: const EdgeInsets.all(5.0),
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       Get.to(WorkflowList(
                        //         sWorkflowId: 1,
                        //         sType: 1,
                        //       ));
                        //       // Add your logout functionality here
                        //       print("Logout tapped");
                        //     },
                        //     child: Icon(
                        //       MdiIcons.receiptOutline, // Logout icon
                        //       color: Colors.black,
                        //       size: 20, // Icon color
                        //     ),
                        //   ),
                        // ),
                        SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GestureDetector(
                            onTap: () {
                              showAlert(context, () => PortalWhichLogin("Start", context));
                              // Add your logout functionality here
                              print("Logout tapped");
                            },
                            child: Icon(
                              MdiIcons.logout, // Logout icon
                              color: Colors.black,
                              size: 20, // Icon color
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: (widget.tableComponentData == null && isWorkFlowLoading)
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(CustomColors.ezpurple),
                        ),
                      )
                    : widget.tableComponentData != null ||
                            workFlowMain?.layout == Strings.txt_layout_classic ||
                            workFlowMain?.layout == Strings.txt_layout_card
                        ? Column(
                            children: [
                              if (widget.tableComponentData == null) tabBar(),
                              Expanded(
                                child: LayoutBuilder(builder: (context, constraint) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(10.0),
                                            bottomLeft: Radius.circular(10.0))),
                                    height: constraint.maxHeight,
                                    child: widget.tableComponentData != null
                                        ? children[0]
                                        : TabBarView(
                                            controller: tabController,
                                            children: <Widget>[
                                              children[0],
                                              WorkflowAttachments(
                                                  modifyData:
                                                      widget.readonly == null || !widget.readonly!,
                                                  workflowId: widget.workflowId,
                                                  processId: widget.processId ?? -1,
                                                  transactionId: widget.transactionId ?? -1,
                                                  repositoryId: widget.repositoryId,
                                                  fileCheckList: fileCheckList,
                                                  formFields: getFields(formValues),
                                                  attachmentCount: (int count) {},
                                                  onFileRemoved: (int fileId) {
                                                    fileIds.remove(fileId);
                                                  },
                                                  onFileAdded: (int fileId) {
                                                    fileIds.add(fileId);
                                                  }),
                                              if (widget.tableComponentData == null)
                                                WorkflowCommentList(
                                                    modifyData: widget.readonly == null ||
                                                        !widget.readonly!,
                                                    workflowId: widget.workflowId,
                                                    processId: widget.processId ?? -1,
                                                    transactionId: widget.transactionId ?? -1,
                                                    onCommentsAdded: (String comment) {
                                                      DateTime now = DateTime.now().toUtc();
                                                      String formattedTime =
                                                          DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'")
                                                              .format(now);

                                                      comments.add({
                                                        "comments": comment,
                                                        "createdAt": formattedTime,
                                                        "createdBy":
                                                            sessionController.userData["id"]
                                                      });
                                                    }),
                                              // if (widget.tableComponentData == null)
                                              //   Container(
                                              //       color: Colors.white,
                                              //       child: ProcessHistory(
                                              //         workflowId: widget.workflowId,
                                              //         processId: widget.processId ?? -1,
                                              //       )),
                                            ],
                                          ),
                                  );
                                }),
                              )
                            ],
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(CustomColors.ezpurple),
                          )),
              ),
            ),
            if (isLoading)
              Positioned.fill(
                  child: Container(
                color: Colors.black.withAlpha(50),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(CustomColors.ezpurple),
                    )
                  ],
                ),
              ))
          ],
        ));
  }

  Widget renderWidgets(dynamic data) {
    if (isWorkFlowLoading) {
      return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(children: [
            Expanded(
                child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CustomColors.ezpurple),
              ),
            ))
          ]));
    }

    if (isWorkFlowError.isNotEmpty) {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Expanded(
                child: Center(
              child: Text(isWorkFlowError),
            ))
          ]));
    }

    return Column(
      children: [
        Expanded(child: LayoutBuilder(builder: (context, viewportConstraints) {
          return Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // loadStepper(data),
                    Expanded(child: loadPanels(data)),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            direction: Axis.horizontal,
                            children: [
                              for (var i = 0; i < actionButtonList.length; i++)
                                actionButton(i, context)
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        })),
      ],
    );
  }

  Future<dynamic> qrCodeScanner() async {
    String? text = await Get.to(() => const QrCodeScanner());

    if (text != null) {
      try {
        dynamic json = jsonDecode(text);
        return json;
      } catch (e) {}
    }
    return text;
  }

  Widget actionButton(int i, BuildContext context) {
    if (widget.readonly != null && widget.readonly!) {
      return Container();
    }

    String buttonText = actionButtonList[i]["proceedAction"];

    if (actionButtonList[i]["custom"] == true) {
      buttonText = actionButtonList[i]["buttonText"];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Utils.getActionButtons(
        actionButtonList[i]["proceedAction"],
        buttonText,
        () {
          if (actionButtonList[i]["proceedAction"] == "Save") {
            _formKey.currentState!.save();
            var fields = getFields(formValues);

            var formData = {
              "formId": formId,
              "fields": fields,
              "formUpload": getFormUploadFieldsForSubmit(fileIds)
            };

            if (widget.formEntryId != null) {
              formData["formEntryId"] = widget.formEntryId!;
            }

            var request = {
              "workflowId": widget.workflowId,
              "review": "",
              "comments": comments,
              "formData": formData,
              "fileIds": fileIds,
            };

            if (widget.transactionId != null) {
              request["transactionId"] = widget.transactionId!;
            }

            submitWorkflow(request);
            // }
          } else if (actionButtonList[i]["proceedAction"] == "Clear") {
            print("Clearing form data...");
            // Unfocus any focused input field
            FocusManager.instance.primaryFocus?.unfocus();

            // Reset the form
            _formKey.currentState?.reset();

            // Clear form values
            setState(() {
              formValues.clear(); // Clear main form values
              formValues1.clear(); // Clear additional form values if any
              fileIds.clear(); // Clear file IDs
              comments.clear(); // Clear comments
              formFieldErrors.clear(); // Clear form field errors
              tableData.clear(); // Clear table data
              tableDataLoading.clear(); // Clear table loading states
              textEditingController.forEach(
                  (key, controller) => controller.clear()); // Clear all TextEditingControllers
              defaultDropDownValues.clear(); // Clear default dropdown values
              signatureList.clear(); // Clear any saved signatures
              workflowAttachmentData.clear(); // Clear workflow attachment data
              deleteFiles.clear(); // Clear files marked for deletion
              multiSelectControllers.clear();
            });

            // Show feedback to the user
            Fluttertoast.showToast(
              msg: "Form has been cleared",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          } else {
            FocusManager.instance.primaryFocus?.unfocus();
            formFieldErrors.clear();

            print(_validateAllFieldsManually());
            print(doManualValidation());

            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              if (doManualValidation() && _validateAllFieldsManually()) {
                var fields = getFields(formValues);

                var formData = {
                  "formId": formId,
                  "fields": fields,
                  "formUpload": getFormUploadFieldsForSubmit(fileIds)
                };

                if (widget.formEntryId != null) {
                  formData["formEntryId"] = widget.formEntryId!;
                }

                // var request = {
                //   "workflowId": widget.workflowId,
                //   "review": actionButtonList[i]["proceedAction"],
                //   "comments": comments,
                //   "formData": formData,
                //   "fileIds": fileIds,
                //   "task": [],
                //   "hasFormPDF": 0,
                //   "prefix": "",
                //   "mlPrediction": "",
                //   "portalId": "1"
                // };

                var request = {
                  "workflowId": widget.workflowId,
                  "review": actionButtonList[i]["proceedAction"],
                  "comments": comments,
                  "formData": formData,
                  "fileIds": [],
                  "fileChecklistStatus": 0,
                  "fileInfo": [],
                  //  "task": [],
                  "hasFormPDF": 0,
                  //  "prefix": "",
                  // "mlPrediction": "",
                  "portalId": "1"
                };

                if (widget.transactionId != null) {
                  request["transactionId"] = widget.transactionId!;
                }

                submitWorkflow(request);
              } else {
                autoValidateWhenSwitchPage = true;
                Fluttertoast.showToast(
                    msg: "Required Mandatory Info",
                    backgroundColor: Colors.red,
                    textColor: Colors.white);
              }
            } else {
              Fluttertoast.showToast(
                  msg: "Required Mandatory Info",
                  backgroundColor: Colors.red,
                  textColor: Colors.white);
            }
          }
        },
      ),
    );
  }

  Widget renderTable(dynamic componentData) {
    if (!tableData.containsKey(componentData.id)) {
      tableData.putIfAbsent(componentData.id, () => []);
    }

    int nestedListMaxLevel = componentData.settings.specific.tableRowsType == "FIXED"
        ? componentData.settings.specific.tableFixedRowCount
        : 9999999;
    bool qrValue = componentData.settings.specific.qrValue;

    print("Table <><><><><><><><><><><><><><><><><>");
    print((tableData[componentData.id]?.length ?? 0) < nestedListMaxLevel);
    print(checkFormControlAccess(componentData.id));
    print(componentData.settings.general.visibility);
    print((widget.readonly == null || !widget.readonly!));

    return Visibility(
      visible: visibleFormControl(componentData.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: CustomColors.ezpurpleLite1,
              borderRadius: BorderRadius.circular(10), // Curved corners
              border: Border.all(
                color: CustomColors.ezpurple, // Border color
                width: 1, // Border width
              ),
            ),
            padding: const EdgeInsets.only(left: 5.0), // Add padding inside the border
            //  margin: const EdgeInsets.symmetric(vertical: 4.0), // Add margin outside the border
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        componentData.label == "Expense Receipt"
                            ? "Add ${componentData.label} " // Append "Add" if the label is "Expense Receipt"
                            : componentData.label,
                        style: Theme.of(Get.context!).textTheme.labelMedium,
                      ),
                    ),
                    if (isMandatoryField(componentData.id))
                      const Text(
                        " * ",
                        style: TextStyle(color: Colors.red),
                      )
                  ],
                ),
                if ((tableData[componentData.id]?.length ?? 0) < nestedListMaxLevel &&
                    (checkFormControlAccess(componentData.id) &&
                        componentData.settings.general.visibility != "READ_ONLY" &&
                        (widget.readonly == null || !widget.readonly!)))
                  Row(
                    children: [
                      IconButton(
                          onPressed: () async {
                            showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => _bottomSheetContent(context, componentData),
                            );
                            // ShowDialogforUpload(context);
                            // var result = await Get.to(
                            //     () => DynamicForm(
                            //           rootData: widget.rootData,
                            //           tableComponentData: componentData,
                            //           formId: formId,
                            //           repositoryId: widget.repositoryId,
                            //           workflowId: widget.workflowId,
                            //           formEditAccess: widget.formEditAccess,
                            //           formEditControls: widget.formEditControls,
                            //           formSecureControls: widget.formSecureControls,
                            //         ),
                            //     preventDuplicates: false);
                            // if (result != null) {
                            //   setState(() {
                            //     (tableData[componentData.id] as List<dynamic>).add(result);
                            //   });
                            // }
                          },
                          icon: const Icon(Icons.cloud_upload_outlined)),
                      if (qrValue)
                        IconButton(
                            onPressed: () async {
                              dynamic result = await qrCodeScanner();
                              if (result != null) {
                                if (result is Map<String, dynamic>) {
                                  addQrJsonResultToRow(result, componentData);
                                }
                              }
                            },
                            icon: const Icon(Icons.qr_code)),
                    ],
                  )
              ],
            ),
          ),
          if (tableDataLoading.containsKey(componentData.id) && tableDataLoading[componentData.id]!)
            const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomColors.ezpurple),
            )),
          const SizedBox(
            height: 8,
          ),
          renderTableRows(componentData)
        ],
      ),
    );
  }

  Widget renderTableRows(dynamic componentData) {
    List<Map<String, dynamic>> data = [];
    List<Widget> customWidget = [];

    if (tableData.containsKey(componentData.id)) {
      data = tableData[componentData.id] ?? [];
    }

    for (var element in data) {
      customWidget.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: !checkFormControlAccess(componentData.id) ||
                      componentData.settings.general.visibility == "READ_ONLY" ||
                      widget.readonly != null && widget.readonly!
                  ? null
                  : () async {
                      var result = await Get.to(
                          () => DynamicForm(
                                rootData: widget.rootData,
                                tableComponentData: componentData,
                                tableComponentInitialData: jsonDecode(jsonEncode(element)),
                                formId: formId,
                                repositoryId: widget.repositoryId,
                                workflowId: widget.workflowId,
                                formEditAccess: widget.formEditAccess,
                                formEditControls: widget.formEditControls,
                                formSecureControls: widget.formSecureControls,
                              ),
                          preventDuplicates: false);

                      if (result != null) {
                        setState(() {
                          data[data.indexOf(element)] = result;
                          tableData[componentData.id] = data;
                        });
                      }
                    },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for (var key in (element as Map).keys.take(4))
                              renderTableRowWidget(element, key, data, componentData.id)
                          ]),
                    ),
                    if (checkFormControlAccess(componentData.id) &&
                        componentData.settings.general.visibility != "READ_ONLY" &&
                        (widget.readonly == null || !widget.readonly!))
                      IconButton(
                        onPressed: () async {
                          // if (element.containsKey("attachmentId")) {
                          //   String attachmentId = element["attachmentId"];
                          //   print("Attachment ID: $attachmentId");
                          // } else {
                          //   print("No attachmentId found. Available keys: ${element.keys}");
                          //   print("Full element data: $element");
                          // }

                          setState(() {
                            (tableData[componentData.id] as List<dynamic>).remove(element);
                          });
                          // if (element.containsKey("attachmentId")) {
                          //   String attachmentId = element["attachmentId"];
                          //   print("Attachment ID from element: $attachmentId");
                          //   var fileToDelete = workflowAttachmentData[componentData.id]?.firstWhere(
                          //       (attachment) =>
                          //           attachment.id == attachmentId // Returning null if not found
                          //       );
                          //
                          //   if (fileToDelete != null) {
                          //     // 3. Delete attachment from server (if needed)
                          //     deleteAttachment(fileToDelete);
                          //
                          //     // 4. Remove the file from local storage/attachment list
                          //     setState(() {
                          //       workflowAttachmentData[componentData.id]?.remove(fileToDelete);
                          //     });
                          //
                          //     // 5. Optionally trigger an update on another page or component
                          //     // if (widget.onFileRemoved != null) {
                          //     //   widget.onFileRemoved!(fileToDelete.id);
                          //     // }
                          //   }
                          // }
                        },
                        icon: const Icon(EvaIcons.trash),
                        color: Colors.red,
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
    }

    if (customWidget.isNotEmpty) {
      // Render total columns
      customWidget.add(renderTotalColumns(componentData, data));
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: customWidget,
      );
    }

    return Container();
  }

  Padding renderTableRowWidget(
      Map<dynamic, dynamic> element, key, List<dynamic> data, String tableComponentId) {
    Widget rightSideValue = Container();
    Widget leftsideValue = Container();
    dynamic tableComponent = getTableComponentById(tableComponentId, key);
    // if(tableComponent == null) return ;
    String colCompType = getTableComponentById(tableComponentId, key).type;

    if (element[key]["text"] == "Item") {}

    if (element[key] != null && element[key]['value'] != null) {
      String? type = element[key]['type'];
      dynamic value = element[key]?["value"];

      if (type == "MultiSelectDropDown") {
        rightSideValue = getMultiSelectDropDownDisplayValues(element[key]);
      } else if (type == Strings.image) {
        if (element[key]["format"] == "base64") {
          rightSideValue = SizedBox(
            width: 50,
            child: Image.memory(
              const Base64Decoder().convert(
                  element[key]!["value"].toString().replaceAll("data:image/png;base64,", "")),
              fit: BoxFit.contain,
            ),
          );
        }
      } else if (colCompType == Strings.fileUpload) {
        List<dynamic> files = [];
        var value = element[key]?["value"];

        if (value != null) {
          try {
            var dataList = jsonDecode(value);
            if (dataList.length > 0) {
              files += dataList;
            }
          } catch (e) {
            String escapedInput = value
                .replaceAllMapped(RegExp(r'(\w+):'), (match) => '"${match[1]}":')
                .replaceAllMapped(RegExp(r': ([^,\]}]+)'), (match) => ': "${match[1]}"');

            try {
              var dataList = jsonDecode(escapedInput);
              if (dataList.length > 0) {
                files += dataList;
              }
            } catch (_) {}
          }
        }

        leftsideValue = Expanded(
          child: Column(
            children: [
              for (var workflowAttachment in files)
                Row(
                  children: [
                    Image.asset(fileIcon(workflowAttachment["fileName"]), width: 20, height: 20),
                    Expanded(
                      child: TextButton(
                          onPressed: () async {
                            Uri fileUrl = Uri.parse(
                                '${EndPoint.BaseUrl}file/view/${sessionController.userDetails.value.tenantId}/${sessionController.userDetails.value.id}/${widget.repositoryId}/${workflowAttachment["itemId"]}/2');
                            if (await canLaunchUrl(fileUrl)) {
                              await launchUrl(fileUrl);
                            }
                          },
                          child: Text(
                            workflowAttachment["fileName"],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ),
                  ],
                ),
            ],
          ),
        );
      } else if (value is List<String>) {
        rightSideValue = Column(
          children: [
            for (var i = 0; i < (element[key]?["value"] as List<String>).take(4).length; i++)
              Text((element[key]?["value"] as List<String>)[i]),
          ],
        );
      } else if (colCompType == Strings.serialNumber) {
        rightSideValue = Flexible(child: Text((data.indexOf(element) + 1).toString()));
      } else if (value is List<dynamic>) {
        rightSideValue = Wrap(
          direction: Axis.vertical,
          children: [
            for (var i = 0; i < (element[key]?["value"] as List<dynamic>).take(4).length; i++)
              Text(
                (element[key]?["value"] as List<dynamic>)[i],
                overflow: TextOverflow.ellipsis,
              ),
          ],
        );
      } else if (value is CroppedFile) {
        rightSideValue = SizedBox(
          width: 50,
          child: Image.file(
            File(element[key]!["value"].path),
            fit: BoxFit.contain,
          ),
        );
      } else {
        rightSideValue = Flexible(child: Text(element[key]?["value"]));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // leftsideValue,
          rightSideValue, // Only show rightSideValue, no text
        ],
        // children: [
        //   if (element[key] != null && element[key]['text'] != null)
        //     Flexible(child: Text(element[key]?["text"])),
        //   rightSideValue,
        // ],
      ),
    );
  }
  // Padding renderTableRowWidget(
  //     Map<dynamic, dynamic> element, key, List<dynamic> data, String tableComponentId) {
  //   Widget rightSideValue = Container();
  //   dynamic tableComponent = getTableComponentById(tableComponentId, key);
  //   // if(tableComponent == null) return ;
  //   String colCompType = getTableComponentById(tableComponentId, key).type;
  //
  //   if (element[key]["text"] == "Item") {}
  //
  //   if (element[key] != null && element[key]['value'] != null) {
  //     String? type = element[key]['type'];
  //     dynamic value = element[key]?["value"];
  //
  //     if (type == "MultiSelectDropDown") {
  //       rightSideValue = getMultiSelectDropDownDisplayValues(element[key]);
  //     } else if (type == Strings.image) {
  //       if (element[key]["format"] == "base64") {
  //         rightSideValue = SizedBox(
  //           width: 50,
  //           child: Image.memory(
  //             const Base64Decoder().convert(
  //                 element[key]!["value"].toString().replaceAll("data:image/png;base64,", "")),
  //             fit: BoxFit.contain,
  //           ),
  //         );
  //       }
  //     } else if (value is List<String>) {
  //       rightSideValue = Column(
  //         children: [
  //           for (var i = 0; i < (element[key]?["value"] as List<String>).take(4).length; i++)
  //             Text((element[key]?["value"] as List<String>)[i]),
  //         ],
  //       );
  //     } else if (colCompType == Strings.serialNumber) {
  //       rightSideValue = Flexible(child: Text((data.indexOf(element) + 1).toString()));
  //     } else if (value is List<dynamic>) {
  //       rightSideValue = Wrap(
  //         direction: Axis.vertical,
  //         children: [
  //           for (var i = 0; i < (element[key]?["value"] as List<dynamic>).take(4).length; i++)
  //             Text(
  //               (element[key]?["value"] as List<dynamic>)[i],
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //         ],
  //       );
  //     } else if (value is CroppedFile) {
  //       rightSideValue = SizedBox(
  //         width: 50,
  //         child: Image.file(
  //           File(element[key]!["value"].path),
  //           fit: BoxFit.contain,
  //         ),
  //       );
  //     } else {
  //       rightSideValue = Flexible(child: Text(element[key]?["value"]));
  //     }
  //   }
  //
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.max,
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         if (element[key] != null && element[key]['text'] != null)
  //           Flexible(child: Text(element[key]?["text"])),
  //         rightSideValue,
  //       ],
  //     ),
  //   );
  // }

  Widget renderTotalColumns(componentData, List<dynamic> datas) {
    List<Widget> widgets = [];
    for (var column in componentData.settings.specific.tableColumns) {
      if (column.settings.specific.showColumnTotal) {
        double total = 0;
        for (var dataItem in datas) {
          for (var dataItemKey in dataItem.keys) {
            if (dataItemKey == column.id) {
              if (dataItem[column.id]["value"] != null &&
                  dataItem[column.id]["value"] != "" &&
                  double.tryParse(dataItem[column.id]["value"]) != null) {
                total += double.parse(dataItem[column.id]["value"]);
              }
            }
          }
        }

        widgets.add(Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            column.label,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(total.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ]),
            ),
          ],
        ));
      }
    }

    if (widgets.isNotEmpty) {
      return Card(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          ...widgets
                        ]))
                  ])));
    }

    return Container();
  }

  Widget renderCheckBox(dynamic componentData) {
    List<String> options = componentData.settings.specific.customOptions.split(",");
    if (options.length == 1) {
      options = options[0].split("\n");
    }

    if (componentData.settings.specific.customDefaultValue != null) {
      if (!formValues.containsKey(componentData.id)) {
        formValues[componentData.id] = {
          "text": componentData.label,
          "value": componentData.settings.specific.customDefaultValue
        };
      }
    }

    return Visibility(
      visible: visibleFormControl(componentData.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  componentData.label,
                  style: Theme.of(Get.context!).textTheme.labelMedium,
                ),
              ),
              if (isMandatoryField(componentData.id))
                const Text(
                  " * ",
                  style: TextStyle(color: Colors.red),
                )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          for (var i = 0; i < options.length; i++)
            CheckboxListTile(
              value: formValues.containsKey(componentData.id) &&
                  formValues[componentData.id]["value"].contains(options[i]),
              onChanged: componentData.settings.general.visibility != "READ_ONLY" &&
                      checkFormControlAccess(componentData.id) &&
                      (widget.readonly == null || !widget.readonly!)
                  ? (value) {
                      List<dynamic> values = [];

                      if (formValues.containsKey(componentData.id) &&
                          formValues[componentData.id]["value"] != "") {
                        print(formValues[componentData.id]["value"]);
                        values = formValues[componentData.id]["value"];
                      }

                      if (value ?? false) {
                        values.add(options[i]);
                      } else {
                        values.remove(options[i]);
                      }

                      setState(() {
                        formValues[componentData.id] = {
                          "text": componentData.label,
                          "value": values
                        };
                      });
                    }
                  : null,
              title: Text(options[i]),
            )
        ],
      ),
    );
  }

  Widget loadComponents(dynamic componentData, dynamic components) {
    String widgetType = componentData.type;
    Widget child;

    setInitialComponentVisibility(componentData.id, components);
    bindParentChangeEvents(componentData);
    switch (widgetType) {
      case Strings.serialNumber:
        child = Container();
        formValues[componentData.id] = {
          "text": componentData.label,
          "value": "",
          "type": Strings.serialNumber
        };
        break;
      case Strings.label:
        child = Text(
          componentData.label,
          style: Theme.of(Get.context!).textTheme.labelMedium,
        );
        break;
      case Strings.divider:
        child = Divider(
          height: 1,
          color: Colors.grey.withAlpha(100),
        );
        break;
      case Strings.shortText:
      case Strings.longText:
      case Strings.number:
      case Strings.password:
      case Strings.calculated:
        child = renderTextInput(componentData);
        break;
      case Strings.counter:
        addInputDefaultValues(componentData);
        if (!formValues.containsKey(componentData.id)) {
          formValues[componentData.id] = {
            "text": componentData.label,
            "value": getTextEditingController(componentData.id).text
          };
        }
        child = Visibility(
          visible: visibleFormControl(componentData.id),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Flexible(
                    child: Text(
                      componentData.label,
                      style: Theme.of(Get.context!).textTheme.labelMedium,
                    ),
                  ),
                  if (isMandatoryField(componentData.id))
                    const Text(
                      " * ",
                      style: TextStyle(color: Colors.red),
                    )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              NumberInputWithIncrementDecrement(
                textAlign: TextAlign.left,
                numberFieldDecoration: InputDecoration(
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: CustomColors.red, width: 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  isCollapsed: true,
                ),
                incDecBgColor: Colors.white,
                decIconColor: const Color(0xFF64748b),
                incIconColor: const Color(0xFF64748b),
                incIcon: Icons.keyboard_arrow_up_rounded,
                decIcon: Icons.keyboard_arrow_down_rounded,
                separateIcons: true,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  color: Color(0xFF1e293b),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                widgetContainerDecoration: const BoxDecoration(),
                enabled: isEnabled(
                    componentData.id,
                    componentData.settings.general.visibility != "READ_ONLY" &&
                        checkFormControlAccess(componentData.id)),
                onDecrement: (value) {
                  formValues[componentData.id] = {
                    "text": componentData.label,
                    "value": value.toString()
                  };
                },
                onIncrement: (value) {
                  formValues[componentData.id] = {
                    "text": componentData.label,
                    "value": value.toString()
                  };
                },
                onChanged: (value) {
                  formValues[componentData.id] = {
                    "text": componentData.label,
                    "value": value.toString()
                  };
                },
                initialValue: int.parse(formValues.containsKey(componentData.id) &&
                        formValues[componentData.id]["value"] != ""
                    ? formValues[componentData.id]["value"]
                    : "0"),
                controller: getTextEditingController(componentData.id),
              )
            ],
          ),
        );
        break;

      //Date Time Components
      case Strings.dateTime:
        addInputDefaultValues(componentData);
        if (!formValues.containsKey(componentData.id)) {
          formValues[componentData.id] = {
            "text": componentData.label,
            "value": getTextEditingController(componentData.id).text
          };
        }
        child = Visibility(
          visible: visibleFormControl(componentData.id),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Flexible(
                    child: Text(
                      componentData.label,
                      style: Theme.of(Get.context!).textTheme.labelMedium,
                    ),
                  ),
                  if (isMandatoryField(componentData.id))
                    const Text(
                      " * ",
                      style: TextStyle(color: Colors.red),
                    )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                maxLines: 1,
                autovalidateMode: AutovalidateMode.disabled,
                readOnly: true,
                enabled: isEnabled(
                    componentData.id,
                    componentData.settings.general.visibility != "READ_ONLY" &&
                        checkFormControlAccess(componentData.id)),
                controller: getTextEditingController(componentData.id),
                decoration: InputDecoration(
                    hintText: componentData.settings.general.placeholder,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.red, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    isCollapsed: true,
                    suffixIcon: IconButton(
                      onPressed: componentData.settings.general.visibility != "READ_ONLY" &&
                              checkFormControlAccess(componentData.id) &&
                              (widget.readonly == null || !widget.readonly!)
                          ? () {
                              String? dateRange = componentData.settings.validation.dateRange;

                              var initialDateTime = DateTime.now();
                              var minimumDateTime = DateTime(0);
                              var maxDateTime = DateTime(2200);
                              if (dateRange != null && dateRange == "MINI_CURRENT_DATE") {
                                minimumDateTime = DateTime.now();
                              }

                              if (dateRange != null && dateRange == "MAX_CURRENT_DATE") {
                                maxDateTime = DateTime.now();
                              }

                              if (componentData.settings.validation.maxiDays != null &&
                                  componentData.settings.validation.maxiDays != 0) {
                                maxDateTime = DateTime.now().add(
                                    Duration(days: componentData.settings.validation.maxiDays));
                              }

                              _showDatePicker(
                                  context, initialDateTime, minimumDateTime, maxDateTime, (date) {
                                _showTimePicker(context, (time) {
                                  String value = DateFormat("yyyy-MM-dd").format(date);
                                  value += " ${time.format(context)}";
                                  setState(() {
                                    formValues[componentData.id] = {
                                      "text": componentData.label,
                                      "value": value
                                    };
                                    getTextEditingController(componentData.id).text = value;
                                  });
                                },
                                    timeFormat:
                                        componentData.settings.validation.timeFormat ?? "12");
                              });
                            }
                          : null,
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (formValues.containsKey(componentData.id) &&
                                  formValues[componentData.id]["value"] != null &&
                                  formValues[componentData.id]["value"] != "" ||
                              getTextEditingController(componentData.id).text != "")
                            IconButton(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                style: const ButtonStyle(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  formValues[componentData.id]["value"] = "";
                                  getTextEditingController(componentData.id).text = "";
                                  updateAnswerIndicator();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close)),
                          const Icon(EvaIcons.calendarOutline),
                        ],
                      ),
                    )),
                keyboardType: getInputType(componentData.settings.validation.contentRule),
                onSaved: ((value) {
                  formValues[componentData.id] = {"text": componentData.label, "value": value};
                }),
                validator: (value) {
                  return getValidation(componentData, value);
                },
              ),
            ],
          ),
        );
        break;
      case Strings.date:
        addInputDefaultValues(componentData);
        if (!formValues.containsKey(componentData.id)) {
          formValues[componentData.id] = {
            "text": componentData.label,
            "value": getTextEditingController(componentData.id).text
          };
        }
        child = Visibility(
          visible: visibleFormControl(componentData.id),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Flexible(
                    child: Text(
                      componentData.label,
                      style: Theme.of(Get.context!).textTheme.labelMedium,
                    ),
                  ),
                  if (isMandatoryField(componentData.id))
                    const Text(
                      " * ",
                      style: TextStyle(color: Colors.red),
                    )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                maxLines: 1,
                readOnly: true,
                autovalidateMode: AutovalidateMode.disabled,
                enabled: checkFormControlAccess(componentData.id) &&
                    isEnabled(
                        componentData.id, componentData.settings.general.visibility != "READ_ONLY"),
                controller: getTextEditingController(componentData.id),
                decoration: InputDecoration(
                    hintText: componentData.settings.general.placeholder,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.red, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    isCollapsed: true,
                    suffixIcon: IconButton(
                      onPressed: isEnabled(
                              componentData.id,
                              componentData.settings.general.visibility != "READ_ONLY" &&
                                  checkFormControlAccess(componentData.id))
                          ? () {
                              String? dateRange = componentData.settings.validation.dateRange;

                              var initialDateTime = DateTime.now();
                              var minimumDateTime = DateTime(0);
                              var maxDateTime = DateTime(2200);
                              if (dateRange != null && dateRange == "MINI_CURRENT_DATE") {
                                minimumDateTime = DateTime.now();
                              }

                              if (dateRange != null && dateRange == "MAX_CURRENT_DATE") {
                                maxDateTime = DateTime.now();
                              }

                              if (componentData.settings.validation.maxiDays != null &&
                                  componentData.settings.validation.maxiDays != 0) {
                                maxDateTime = DateTime.now().add(
                                    Duration(days: componentData.settings.validation.maxiDays));
                              }

                              _showDatePicker(
                                  context, initialDateTime, minimumDateTime, maxDateTime, (value) {
                                setState(() {
                                  formValues[componentData.id] = {
                                    "text": componentData.label,
                                    "value": DateFormat("yyyy-MM-dd").format(value)
                                  };
                                  getTextEditingController(componentData.id).text =
                                      DateFormat("yyyy-MM-dd").format(value);
                                  updateAnswerIndicator();
                                  doParentChangeEvent(componentData);
                                });
                              });
                            }
                          : null,
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (formValues.containsKey(componentData.id) &&
                                  formValues[componentData.id]["value"] != null &&
                                  formValues[componentData.id]["value"] != "" ||
                              getTextEditingController(componentData.id).text != "")
                            IconButton(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                style: const ButtonStyle(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  formValues[componentData.id]["value"] = "";
                                  getTextEditingController(componentData.id).text = "";
                                  updateAnswerIndicator();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                )),
                          const Icon(EvaIcons.calendarOutline),
                        ],
                      ),
                    )),
                keyboardType: getInputType(componentData.settings.validation.contentRule),
                onSaved: ((value) {
                  formValues[componentData.id] = {"text": componentData.label, "value": value};
                }),
                validator: (value) {
                  return getValidation(componentData, value);
                },
              ),
            ],
          ),
        );
        break;

      case Strings.time:
        addInputDefaultValues(componentData);
        if (!formValues.containsKey(componentData.id)) {
          formValues[componentData.id] = {
            "text": componentData.label,
            "value": getTextEditingController(componentData.id).text
          };
        }
        child = Visibility(
          visible: visibleFormControl(componentData.id),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Flexible(
                    child: Text(
                      componentData.label,
                      style: Theme.of(Get.context!).textTheme.labelMedium,
                    ),
                  ),
                  if (isMandatoryField(componentData.id))
                    const Text(
                      " * ",
                      style: TextStyle(color: Colors.red),
                    )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                maxLines: 1,
                readOnly: true,
                autovalidateMode: AutovalidateMode.disabled,
                controller: getTextEditingController(componentData.id),
                decoration: InputDecoration(
                    hintText: componentData.settings.general.placeholder,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.red, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    isCollapsed: true,
                    suffixIcon: IconButton(
                      onPressed: isEnabled(
                              componentData.id,
                              componentData.settings.general.visibility != "READ_ONLY" &&
                                  checkFormControlAccess(componentData.id))
                          ? () {
                              _showTimePicker(context, (TimeOfDay value) {
                                setState(() {
                                  formValues[componentData.id] = {
                                    "text": componentData.label,
                                    "value": value.format(context)
                                  };
                                  getTextEditingController(componentData.id).text =
                                      value.format(context);
                                  bindCalculatedInputParentChangeEvents();
                                });
                              }, timeFormat: componentData.settings.validation.timeFormat ?? "12");
                            }
                          : null,
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (formValues.containsKey(componentData.id) &&
                                  formValues[componentData.id]["value"] != null &&
                                  formValues[componentData.id]["value"] != "" ||
                              getTextEditingController(componentData.id).text != "")
                            IconButton(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                style: const ButtonStyle(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  formValues[componentData.id]["value"] = "";
                                  getTextEditingController(componentData.id).text = "";
                                  updateAnswerIndicator();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                )),
                          const Icon(EvaIcons.clockOutline),
                        ],
                      ),
                    )),
                keyboardType: getInputType(componentData.settings.validation.contentRule),
                onSaved: ((value) {
                  formValues[componentData.id] = {"text": componentData.label, "value": value};
                }),
                validator: (value) {
                  return getValidation(componentData, value);
                },
              ),
            ],
          ),
        );
        break;
      // Option - DropDown
      case Strings.singleSelect:
        print("Component Data (Raw): $componentData");
        child = renderDropDownMenu(componentData, null, null);
        break;
      case Strings.multiSelect:
        child = renderMultiSelectDropDownMenu(componentData);
        break;
      case Strings.multiChoice:
        child = renderCheckBox(componentData);
        break;
      case Strings.table:
        child = renderTable(componentData);
        break;
      case Strings.signature:
        if (!signatureKeys.containsKey(componentData.id)) {
          signatureKeys[componentData.id] = GlobalKey<SfSignaturePadState>();
        }

        GlobalKey<SfSignaturePadState> signatureKey = signatureKeys[componentData.id]!;
        child = signatureDrawer(signatureKey, componentData, (String sign) {
          formValues[componentData.id] = {"text": componentData.label, "value": sign};
        });

        break;
      case Strings.singleChoice:
        if (componentData.settings.specific.customDefaultValue != null) {
          if (!formValues.containsKey(componentData.id)) {
            formValues[componentData.id] = {
              "text": componentData.label,
              "value": componentData.settings.specific.customDefaultValue
            };
          }
        }
        var options = [];
        if (componentData.settings.specific.separateOptionsUsing == "COMMA") {
          options = componentData.settings.specific.customOptions.split(", ");
          if (options.length <= 1) {
            options = componentData.settings.specific.customOptions.split(",");
          }
        } else if (componentData.settings.specific.separateOptionsUsing == "NEWLINE") {
          options = componentData.settings.specific.customOptions.split("\n");
        }

        child = Visibility(
          visible: visibleFormControl(componentData.id),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Flexible(
                    child: Text(
                      componentData.label,
                      style: Theme.of(Get.context!).textTheme.labelMedium,
                    ),
                  ),
                  if (isMandatoryField(componentData.id))
                    const Text(
                      " * ",
                      style: TextStyle(color: Colors.red),
                    )
                ],
              ),
              for (var i = 0; i < options.length; i++)
                RadioTheme(
                  data: RadioThemeData(
                    fillColor: MaterialStateProperty.all(Colors.red), // Set the color to red
                  ),
                  child: RadioListTile<String>(
                    value: options[i],
                    groupValue: formValues.containsKey(componentData.id)
                        ? formValues[componentData.id]["value"]
                        : null,
                    onChanged: componentData.settings.general.visibility == "READ_ONLY" ||
                            !checkFormControlAccess(componentData.id) ||
                            widget.readonly != null && widget.readonly!
                        ? null
                        : (value) {
                            formValues[componentData.id] = {
                              "text": componentData.label,
                              "value": value,
                            };
                            setComponentVisibilityIfPossible();
                            resetValueWhenReadOnly(componentData.id);
                            setState(() {});
                          },
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Text(options[i]),
                  ),
                ),
              if (formFieldErrors.containsKey(componentData.id))
                Text(
                  formFieldErrors[componentData.id]!,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        );
        break;
      case Strings.url:
        child = Visibility(
          visible: visibleFormControl(componentData.id),
          child: RichText(
              text: TextSpan(
            children: [
              TextSpan(
                text: componentData.label,
                style: const TextStyle(color: Colors.red),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse(componentData.settings.general.url));
                  },
              ),
            ],
          )),
        );
        break;
      case Strings.rating:
        if (!formValues.containsKey(componentData.id)) {
          formValues[componentData.id] = {"text": componentData.label, "value": 0};
        }
        child = Visibility(
          visible: visibleFormControl(componentData.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      componentData.label,
                      style: Theme.of(Get.context!).textTheme.labelMedium,
                    ),
                  ),
                  if (isMandatoryField(componentData.id))
                    const Text(
                      " * ",
                      style: TextStyle(color: Colors.red),
                    )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: RatingBar.builder(
                  initialRating:
                      double.parse((formValues[componentData.id]["value"] ?? "0").toString()),
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: componentData.settings.specific.ratingIconCount,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    getRatingIcon(componentData.settings.specific.ratingIcon),
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    formValues[componentData.id] = {"text": componentData.label, "value": rating};
                  },
                ),
              ),
              if (formFieldErrors.containsKey(componentData.id))
                Text(
                  formFieldErrors[componentData.id]!,
                  style: const TextStyle(color: Colors.red),
                )
            ],
          ),
        );
        break;
      case Strings.matrix:
        child = Visibility(
          visible: visibleFormControl(componentData.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      componentData.label,
                      style: Theme.of(Get.context!).textTheme.labelMedium,
                    ),
                  ),
                  if (isMandatoryField(componentData.id))
                    const Text(
                      " * ",
                      style: TextStyle(color: Colors.red),
                    )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              renderMatrix(componentData)
            ],
          ),
        );
        break;
      case Strings.chips:
        child = renderChipsComponent(componentData);
        break;
      case Strings.image:
        child = renderImageComponent(componentData);
        break;
      case Strings.textBuilder:
        child = Visibility(
          visible: visibleFormControl(componentData.id),
          child: SizedBox(
            height: 350,
            child: Editor(
                readOnly: componentData.settings.general.visibility == "READ_ONLY" ||
                    !checkFormControlAccess(componentData.id) ||
                    widget.readonly != null && widget.readonly!,
                onChange: (html) {
                  formValues[componentData.id] = {"text": componentData.label, "value": html};
                },
                initialValue: formValues[componentData.id]?["value"] ?? ""),
          ),
        );

        break;
      case Strings.fileUpload:
        child = Visibility(
          visible: visibleFormControl(componentData.id),
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          componentData.label,
                          style: Theme.of(Get.context!).textTheme.labelMedium,
                        ),
                      ),
                      if (isMandatoryField(componentData.id))
                        const Text(
                          " * ",
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Builder(
                  //   builder: (context) {
                  //     if (!formValues.containsKey(componentData.id)) {
                  //       formValues[componentData.id] = {
                  //         "text": componentData.label,
                  //         "value": ""
                  //       };
                  //     }
                  //     return const SizedBox.shrink();
                  //   },
                  // ),
                  if (widget.paths != null && widget.paths!.isNotEmpty && !_hasCalledMethod)
                    // Automatically call the method when the path is not empty
                    Builder(
                      builder: (context) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _hasCalledMethod = true; // Set the flag to true
                          });
                          addFormFileforanother(componentData, widget.paths);
                        });
                        return SizedBox.shrink(); // Hide the widget when path is not empty
                      },
                    ),
                  if (formFieldErrors.containsKey(componentData.id))
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            formFieldErrors[componentData.id] ?? "",
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  if ((workflowAttachmentData[componentData.id]?.length ?? 0) > 0 ||
                      getAttachmentsForField(componentData.id).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Attachments"),
                                for (AttachmentData workflowAttachment
                                    in workflowAttachmentData[componentData.id] ?? [])
                                  formFieldUploadFileComponent(workflowAttachment, componentData),
                                for (var workflowAttachment
                                    in getAttachmentsForField(componentData.id))
                                  Row(
                                    children: [
                                      Image.asset(fileIcon(workflowAttachment["fileName"]),
                                          width: 20, height: 20),
                                      TextButton(
                                        onPressed: () async {
                                          Uri fileUrl = Uri.parse(
                                            '${EndPoint.BaseUrl}uploadAndIndex/view/${sessionController.userDetails.value.tenantId}/${workflowAttachment["itemId"]}/2',
                                          );
                                          if (await canLaunchUrl(fileUrl)) {
                                            await launchUrl(fileUrl);
                                          }
                                        },
                                        child: Text(
                                          workflowAttachment["fileName"],
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (!(!checkFormControlAccess(componentData.id) ||
                                          componentData.settings.general.visibility ==
                                              "READ_ONLY" ||
                                          widget.readonly != null && widget.readonly!))
                                        IconButton(
                                          onPressed: () {
                                            deleteAttachmentsForField(
                                                componentData.id, workflowAttachment);
                                            setState(() {});
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (isFileLoading[componentData.id] ?? false)
                Positioned.fill(
                  child: Container(
                    child: const Center(
                      child: SizedBox(
                        width: 20, // Adjust size as needed
                        height: 20, // Adjust size as needed
                        child: CircularProgressIndicator(
                          strokeWidth: 2, // Reduce thickness of the loader
                          valueColor:
                              AlwaysStoppedAnimation<Color>(CustomColors.ezpurple), // Red color
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
        break;

      case Strings.paragraph:
        child = HTML.HtmlWidget(componentData.settings.specific.textContent);
        break;
      default:
        child = Visibility(
          visible: visibleFormControl(componentData.id),
          child: Text(
            componentData.label,
            style: Theme.of(Get.context!).textTheme.labelMedium,
          ),
        );
        break;
    }
    return child;
  }

  Stack formFieldUploadFileComponent(AttachmentData workflowAttachment, componentData) {
    final imageUri = Uri.parse(
        '${EndPoint.BaseUrl}uploadAndIndex/view/${sessionController.userDetails.value.tenantId}/${workflowAttachment.id}/1');

    print("Image URI: $imageUri");
    return Stack(
      children: [
        // https://eztapi.ezofis.com/api/file/view/23/EU_9/1/104/1
        GestureDetector(
          onTap: () async {
            if (await canLaunchUrl(Uri.parse(
                '${EndPoint.BaseUrl}uploadAndIndex/view/${sessionController.userDetails.value.tenantId}/${workflowAttachment.id}/1'))) {
              await launchUrl(Uri.parse(
                  '${EndPoint.BaseUrl}uploadAndIndex/view/${sessionController.userDetails.value.tenantId}/${workflowAttachment.id}/1'));
            } // Call your method here
          },
          child: Image.network(
            imageUri.toString(),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: 250,
                child: Image.asset(
                  'assets/images/files/pdf.png', // Make sure this path is correct
                  width: 40, // Set size as needed
                  height: 40,
                ),
              );
            },
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return SizedBox(
                height: 350,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: CircularProgressIndicator(
                    color: CustomColors.ezpurple,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                ),
              );
            },
          ),
        ),

        // Positioned widget inside Stack (not inside Padding)
        Positioned(
          left: 0.0,
          top: 1.0,
          right: 0.0,
          child: Container(
            width: MediaQuery.of(context).size.width, // Full width
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread items evenly
              children: [
                Container(
                  width: 150, // Set the desired width
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      // print('Button clicked. URL: $fileUrl');
                      if (await canLaunchUrl(Uri.parse(
                          '${EndPoint.BaseUrl}uploadAndIndex/view/${sessionController.userDetails.value.tenantId}/${workflowAttachment.id}/1'))) {
                        await launchUrl(Uri.parse(
                            '${EndPoint.BaseUrl}uploadAndIndex/view/${sessionController.userDetails.value.tenantId}/${workflowAttachment.id}/1'));
                      }
                    },
                    child: Text(
                      workflowAttachment.name,
                      style: TextStyle(fontSize: 17, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 3), // Adjust padding as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30), // Curved corners
                    border: Border.all(
                      color: _getBorderColor("Extracted"), // Dynamically set border color
                      width: 2.0,
                    ),
                  ),
                  child: Text(
                    "Extracted", // Replace with dynamic text if needed
                    style: TextStyle(
                      fontSize: 16,
                      color: _getTextColor("Extracted"), // Dynamically set text color
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    //   Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     Row(
    //       mainAxisSize: MainAxisSize.max,
    //       children: [
    //         Image.asset(fileIcon(workflowAttachment.name), width: 20, height: 20),
    //         Container(
    //           width: 200,
    //           child: TextButton(
    //               onPressed: () async {
    //                 Uri fileUrl = Uri.parse(
    //                     '${EndPoint.BaseUrl}file/view/${sessionController.userDetails.value.tenantId}/${sessionController.userDetails.value.id}/${widget.repositoryId}/${workflowAttachment.id}/2');
    //                 if (await canLaunchUrl(fileUrl)) {
    //                   await launchUrl(fileUrl);
    //                 }
    //               },
    //               child: Text(
    //                 workflowAttachment.name,
    //                 overflow: TextOverflow.ellipsis,
    //                 softWrap: false,
    //               )),
    //         )
    //       ],
    //     ),
    //     IconButton(
    //         onPressed: () {
    //           workflowAttachmentData[componentData.id]?.remove(workflowAttachment);
    //           setState(() {});
    //         },
    //         icon: const Icon(
    //           Icons.delete,
    //           color: Colors.red,
    //         ))
    //   ],
    // );
  }

  Widget renderImageComponent(dynamic componentData) {
    return Visibility(
      visible: visibleFormControl(componentData.id),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Flexible(
                child: Text(
                  componentData.label,
                  style: Theme.of(Get.context!).textTheme.labelMedium,
                ),
              ),
              if (isMandatoryField(componentData.id))
                const Text(
                  " * ",
                  style: TextStyle(color: Colors.red),
                )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                showImageSelectionSourceDialog1((String action) async {
                  XFile? file;
                  if (action == "Gallery") {
                    file = await _imagePicker.pickImage(source: ImageSource.gallery);
                  } else {
                    file = await _imagePicker.pickImage(source: ImageSource.camera);
                  }
                  formValues[componentData.id] = {"text": componentData.label, "value": file};

                  final croppedFile = await ImageCropper().cropImage(
                    sourcePath: file!.path,
                    compressFormat: ImageCompressFormat.jpg,
                    compressQuality: 100,
                    uiSettings: [
                      AndroidUiSettings(
                          toolbarTitle: 'Cropper',
                          toolbarColor: Colors.deepOrange,
                          toolbarWidgetColor: Colors.white,
                          initAspectRatio: CropAspectRatioPreset.original,
                          lockAspectRatio: false),
                      IOSUiSettings(
                        title: 'Cropper',
                      ),
                    ],
                  );

                  if (croppedFile != null) {
                    formValues[componentData.id] = {
                      "text": componentData.label,
                      "value": croppedFile
                    };
                  }
                  setState(() {});
                });
              },
              child: formValues.containsKey(componentData.id)
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: formValues[componentData.id]["value"] is String
                              ? Image.memory(const Base64Decoder().convert(
                                  formValues[componentData.id]!["value"]
                                      .toString()
                                      .replaceAll("data:image/png;base64,", "")))
                              : Image.file(
                                  File(formValues[componentData.id]["value"].path),
                                  fit: BoxFit.contain,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () async {
                                  String path = "";
                                  if (formValues[componentData.id]["value"] is String) {
                                    Uint8List bytes = base64.decode(formValues[componentData.id]
                                            ["value"]
                                        .replaceAll("data:image/png;base64,", ""));
                                    String dir = (await getApplicationDocumentsDirectory()).path;
                                    File file =
                                        File("$dir/${DateTime.now().millisecondsSinceEpoch}.png");
                                    await file.writeAsBytes(bytes);
                                    path = file.path;
                                  } else {
                                    path = formValues[componentData.id]["value"]!.path;
                                  }

                                  final croppedFile = await ImageCropper().cropImage(
                                    sourcePath: path,
                                    compressFormat: ImageCompressFormat.jpg,
                                    compressQuality: 100,
                                    uiSettings: [
                                      AndroidUiSettings(
                                          toolbarTitle: 'Cropper',
                                          toolbarColor: Colors.deepOrange,
                                          toolbarWidgetColor: Colors.white,
                                          initAspectRatio: CropAspectRatioPreset.original,
                                          lockAspectRatio: false),
                                      IOSUiSettings(
                                        title: 'Cropper',
                                      ),
                                    ],
                                  );

                                  if (croppedFile != null) {
                                    formValues[componentData.id] = {
                                      "text": componentData.label,
                                      "value": croppedFile
                                    };
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                      border: Border.fromBorderSide(
                                          BorderSide(width: 1, color: Colors.grey.withAlpha(100))),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(EvaIcons.editOutline),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () {
                                  formValues.remove(componentData.id);
                                  setState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.fromBorderSide(
                                          BorderSide(width: 1, color: Colors.grey.withAlpha(100))),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(EvaIcons.trashOutline),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  : const Row(
                      children: [
                        Icon(
                          EvaIcons.imageOutline,
                          color: Colors.grey,
                          size: 100,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Browse your image",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "We accept PNG, JPG & JPEG",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget renderChipsComponent(dynamic componentData) {
    if (!formValues.containsKey(componentData.id)) {
      formValues[componentData.id] = {"text": componentData.label, "value": []};
    }

    return Visibility(
      visible: visibleFormControl(componentData.id),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Flexible(
                child: Text(
                  componentData.label,
                  style: Theme.of(Get.context!).textTheme.labelMedium,
                ),
              ),
              if (isMandatoryField(componentData.id))
                const Text(
                  " * ",
                  style: TextStyle(color: Colors.red),
                )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          TextFieldTags(
            initialTags: List<String>.from(formValues[componentData.id]["value"] ?? []),
            textSeparators: const [' ', ','],
            letterCase: LetterCase.normal,
            validator: (String tag) {
              return null;
            },
            inputFieldBuilder: (context, inputFieldValues) {
              // return ((context, sc, tags, onTagDelete) {
              formValues[componentData.id] = {
                "text": componentData.label,
                "value": inputFieldValues.tags
              };

              return TextField(
                cursorColor: CustomColors.ezpurple,
                controller: inputFieldValues.textEditingController,
                focusNode: inputFieldValues.focusNode,
                enabled: isEnabled(
                    componentData.id,
                    componentData.settings.general.visibility != "READ_ONLY" &&
                        checkFormControlAccess(componentData.id)),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: componentData.settings.general.placeholder,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: CustomColors.red, width: 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  isCollapsed: true,
                  helperStyle: const TextStyle(
                    color: CustomColors.ezpurple,
                  ),
                  errorText: inputFieldValues.error,
                  prefixIconConstraints:
                      BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
                  prefixIcon: inputFieldValues.tags.isNotEmpty
                      ? SingleChildScrollView(
                          controller: inputFieldValues.tagScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              children: inputFieldValues.tags.map((String tag) {
                            return Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                color: CustomColors.ezpurple,
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    child: Text(
                                      tag,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    onTap: () {},
                                  ),
                                  const SizedBox(width: 4.0),
                                  InkWell(
                                    child: const Icon(
                                      Icons.cancel,
                                      size: 14.0,
                                      color: Color.fromARGB(255, 233, 233, 233),
                                    ),
                                    onTap: () {
                                      inputFieldValues.onTagRemoved(tag);
                                    },
                                  )
                                ],
                              ),
                            );
                          }).toList()),
                        )
                      : null,
                ),
                onChanged: inputFieldValues.onTagChanged,
                onSubmitted: inputFieldValues.onTagSubmitted,
              );
              // });
            },
            textfieldTagsController: StringTagController(),
          ),
        ],
      ),
    );
  }

  Widget renderMatrix(dynamic componentData) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < componentData.settings.specific.matrixRows.length; i++)
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((componentData.settings.specific.matrixRows[i].label as String)
                    .capitalizeFirst!),
                for (var c = 0; c < componentData.settings.specific.matrixColumns.length; c++)
                  renderMatrixChildComponents(
                      componentData.id,
                      componentData.settings.specific.matrixRows[i].id,
                      componentData.settings.specific.matrixColumns[c],
                      componentData,
                      c),
              ],
            )
        ]);
  }

  Widget renderMatrixChildComponents(
      String matrixId, String rowId, dynamic column, dynamic componentData, int columnIndex) {
    if (componentData?.settings?.specific?.matrixTypeSettings?.type == "CHECKBOX") {
      if (!formValues.containsKey(matrixId)) {
        formValues[matrixId] = {};
      }

      if (!formValues[matrixId].containsKey(rowId)) {
        formValues[matrixId][rowId] = [];
      }

      if (formValues[matrixId][rowId].length <= columnIndex) {
        formValues[matrixId][rowId].add({});
      }

      if (!((formValues[matrixId][rowId] as List<dynamic>)[columnIndex] as Map)
          .containsKey(column.id)) {
        formValues[matrixId][rowId][columnIndex][column.id] = false;
      }

      var selectedColumn = false;
      for (var key in formValues[matrixId][rowId][columnIndex].keys) {
        if (key == column.id) {
          selectedColumn = formValues[matrixId][rowId][columnIndex][key];
        }
      }

      return CheckboxListTile(
        value: selectedColumn,
        onChanged: (value) {
          // List<dynamic> values = [];
          //
          // if (formValues.containsKey(rowId)) {
          //   values = formValues[rowId]["value"];
          // }
          //
          // if (value ?? false) {
          //   values.add(column.id);
          // } else {
          //   values.remove(column.id);
          // }
          //
          // setState(() {
          //   formValues[rowId] = {"text": componentData.label, "value": values};
          // });
          formValues[matrixId][rowId][columnIndex][column.id] = value;
          setState(() {});
        },
        title: Text((column.label as String).capitalizeFirst!),
      );
    } else if (componentData?.settings?.specific?.matrixTypeSettings?.type == "RADIO") {
      if (!formValues.containsKey(matrixId)) {
        formValues[matrixId] = {};
      }

      if (!formValues[matrixId].containsKey(rowId)) {
        formValues[matrixId][rowId] = [];
      }

      if (formValues[matrixId][rowId].length <= columnIndex) {
        formValues[matrixId][rowId].add({});
      }

      if (!((formValues[matrixId][rowId] as List<dynamic>)[columnIndex] as Map)
          .containsKey(column.id)) {
        formValues[matrixId][rowId][columnIndex][column.id] = false;
      }

      var selectedColumn = "";
      for (var key in formValues[matrixId][rowId][columnIndex].keys) {
        if (selectedColumn == "") {
          if (formValues[matrixId][rowId][columnIndex][key]) {
            selectedColumn = key;
          }
        }
      }

      return RadioListTile<dynamic>(
        value: column.id,
        groupValue: selectedColumn,
        onChanged: componentData.settings.general.visibility == "READ_ONLY" ||
                widget.readonly != null && widget.readonly!
            ? null
            : (value) {
                for (var c in formValues[matrixId][rowId]) {
                  for (var key in c.keys) {
                    c[key] = false;
                  }
                }

                formValues[matrixId][rowId][columnIndex][column.id] = true;
                setState(() {});
              },
        title: Text((column.label as String).capitalizeFirst!),
        controlAffinity: ListTileControlAffinity.trailing,
      );
    } else if (componentData?.settings?.specific.matrixTypeSettings?.type == "SINGLE_SELECT") {
      if (!formValues.containsKey(matrixId)) {
        formValues[matrixId] = {};
      }

      if (!formValues[matrixId].containsKey(rowId)) {
        formValues[matrixId][rowId] = [];
      }

      if (formValues[matrixId][rowId].length <= columnIndex) {
        formValues[matrixId][rowId].add({});
      }

      if (!((formValues[matrixId][rowId] as List<dynamic>)[columnIndex] as Map)
          .containsKey(column.id)) {
        formValues[matrixId][rowId][columnIndex][column.id] = "";
      }

      return renderDropDownMenu(componentData?.settings?.specific.matrixTypeSettings,
          (String? value) {
        formValues[matrixId][rowId][columnIndex][column.id] = value ?? "";
      }, formValues[matrixId][rowId][columnIndex][column.id]);
    }
    return Container();
  }

  bool visibleFormControl(String id) {
    var componentData = getComponentById(id);
    if (componentData != null) {
      if (componentData.settings.general.visibility == "DISABLE") {
        return false;
      }
    }

    if (widget.formSecureControls.contains(id)) {
      return false;
    }

    if (componentsVisibility.containsKey(id) && componentsVisibility[id] == false) {
      return false;
    }

    return true;
  }

  bool checkFormControlAccess(String id) {
    if (widget.formEditAccess == "") {
      return false;
    }

    if (widget.formEditAccess == "PARTIAL" && widget.formEditControls.isNotEmpty) {
      return widget.formEditControls.contains(id);
    }

    return true;
  }

  Widget renderTextInput1(dynamic componentData) {
    String widgetType = componentData.type;

    addInputDefaultValues(componentData);

    return Visibility(
      visible: visibleFormControl(componentData.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  componentData.label,
                  style: Theme.of(Get.context!).textTheme.labelMedium,
                ),
              ),
              if (isMandatoryField(componentData.id))
                const Text(
                  " * ",
                  style: TextStyle(color: Colors.red),
                ),
              if (componentData.settings.general.tooltip != "")
                Tooltip(
                  message: componentData.settings.general.tooltip,
                  triggerMode: TooltipTriggerMode.tap,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      EvaIcons.questionMarkCircle,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            maxLines: widgetType == Strings.longText ? 2 : 1,
            obscureText: widgetType == Strings.password,
            controller: getTextEditingController(componentData.id),
            enabled: isEnabled(
              componentData.id,
              widgetType != Strings.calculated &&
                  componentData.settings.general.visibility != "READ_ONLY" &&
                  widgetType != Strings.serialNumber &&
                  checkFormControlAccess(componentData.id),
            ),
            decoration: InputDecoration(
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColors.red, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColors.red, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              isCollapsed: true,
              hintText: componentData.settings.general.placeholder ?? "",
              hintStyle: TextStyle(color: Colors.grey.withAlpha(100)),
              // Show error text directly from the specific field error.
              errorText: formValues[componentData.id]?["error"] ?? null,
            ),
            keyboardType: getInputType(componentData.settings.validation.contentRule),
            inputFormatters: [
              if (widgetType == Strings.decimal || widgetType == Strings.number)
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onSaved: ((value) {
              formValues[componentData.id] = {
                "text": componentData.label,
                "value": value,
                "error": null, // Clear error on save
              };
            }),
            onChanged: (value) {
              setState(() {
                double fieldValue = double.tryParse(value) ?? 0.0;
                formValues[componentData.id] = {
                  "text": componentData.label,
                  "value": fieldValue,
                  "error": null, // Clear previous error on change
                };
                bindCalculatedInputParentChangeEvents();

                // Check if this component has a "maximumNumberField" setting
                String? maximumNumberFieldId = componentData.settings.validation.maximumNumberField;

                if (maximumNumberFieldId != null && formValues.containsKey(maximumNumberFieldId)) {
                  // Get the value of the maximum number field
                  double? maxValue = formValues[maximumNumberFieldId]?["value"];

                  // Validate if the current field's value exceeds the maximum number field's value
                  if (maxValue != null && fieldValue >= maxValue) {
                    // Get the label of the maximum number field to include in the error message
                    String? maxFieldLabel = formValues[maximumNumberFieldId]?["text"];
                    formValues[componentData.id]?["error"] =
                        "${componentData.label} value should not be greater than $maxFieldLabel.";
                  } else {
                    formValues[componentData.id]?["error"] = null; // Clear error for this field
                  }
                }
              });
            },
            validator: (value) {
              double fieldValue = double.tryParse(value ?? '') ?? 0.0;

              // Check if this component has a "maximumNumberField" setting
              String? maximumNumberFieldId = componentData.settings.validation.maximumNumberField;

              if (maximumNumberFieldId != null && formValues.containsKey(maximumNumberFieldId)) {
                // Get the value of the maximum number field
                double? maxValue = formValues[maximumNumberFieldId]?["value"];

                if (maxValue != null && fieldValue >= maxValue) {
                  // Get the label of the maximum number field to include in the error message
                  String? maxFieldLabel = formValues[maximumNumberFieldId]?["text"];
                  return "${componentData.label} value should not be greater than $maxFieldLabel.";
                }
              }

              return getValidation(componentData, value); // Default validation
            },
          )
        ],
      ),
    );
  }

  Widget renderTextInput(dynamic componentData) {
    String widgetType = componentData.type;

    addInputDefaultValues(componentData);

    return Visibility(
      visible: visibleFormControl(componentData.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  componentData.label,
                  style: Theme.of(Get.context!).textTheme.labelMedium,
                ),
              ),
              if (isMandatoryField(componentData.id))
                const Text(
                  " * ",
                  style: TextStyle(color: Colors.red),
                ),
              if (componentData.settings.general.tooltip != "")
                Tooltip(
                  message: componentData.settings.general.tooltip,
                  triggerMode: TooltipTriggerMode.tap,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      EvaIcons.questionMarkCircle,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            maxLines: widgetType == Strings.longText ? 2 : 1,
            obscureText: widgetType == Strings.password,
            controller: getTextEditingController(componentData.id),
            enabled: isEnabled(
                componentData.id,
                widgetType != Strings.calculated &&
                    componentData.settings.general.visibility != "READ_ONLY" &&
                    widgetType != Strings.serialNumber &&
                    checkFormControlAccess(componentData.id)),
            decoration: InputDecoration(
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: CustomColors.red, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                isCollapsed: true,
                hintText: componentData.settings.general.placeholder ?? "",
                hintStyle: TextStyle(color: Colors.grey.withAlpha(100))),
            keyboardType: getInputType(componentData.settings.validation.contentRule),
            inputFormatters: [
              if (widgetType == Strings.decimal || widgetType == Strings.number)
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onSaved: ((value) {
              formValues[componentData.id] = {"text": componentData.label, "value": value};
              getValidation(componentData, value);
            }),
            onChanged: (value) {
              formValues[componentData.id] = {"text": componentData.label, "value": value};
              bindCalculatedInputParentChangeEvents();
              getValidation(componentData, value);
              // _formKey.currentState?.validate();
            },
            validator: (value) {
              return getValidation(componentData, value);
            },
          ),
        ],
      ),
    );
  }

  Widget renderDropDownMenu(
      dynamic componentData, Function(String? value)? callback, String? selectedValue) {
    bool qrValue = componentData.settings.specific.qrValue;

    formFieldStates[componentData.id] =
        GlobalObjectKey<FormFieldState>("DropDown_${componentData.id}");

    List<DropdownMenuItem<dynamic>> options = [];

    if (componentData.settings.specific.optionsType == "EXISTING" ||
        componentData.settings.specific.optionsType == "REPOSITORY") {
      if (!defaultDropDownValues.containsKey(componentData.id)) {
        defaultDropDownValues.putIfAbsent(componentData.id, () => "Loading");
        if (componentData.settings.specific.optionsType == "EXISTING") {
          loadDefaultUniqueColumns(componentData.id, formId, componentData.id);
        } else if (componentData.settings.specific.optionsType == "REPOSITORY") {
          if (componentData.settings.specific.repositoryFieldParent == "") {
            loadDefaultUniqueColumnsRepository(componentData.settings.specific.repositoryField,
                componentData.settings.specific.repositoryId, componentData.id);
          } else {
            loadDefaultUniqueColumnsValuesFromParentRepositoryField(componentData.id);
          }
        }
      }
      if (defaultDropDownValues[componentData.id] != "Loading" &&
          defaultDropDownValues[componentData.id] != "Error") {
        options.clear();
        print("Before populating1: ${options.length} items");
        for (var element in (defaultDropDownValues[componentData.id] as List<dynamic>)) {
          options.add(DropdownMenuItem(
            value: element,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              child: Text(element),
            ),
          ));
        }
        print("After populating1: ${options.length} items");
      }
    } else if (componentData.settings.specific.optionsType == "MASTER") {
      if (!defaultDropDownValues.containsKey(componentData.id)) {
        defaultDropDownValues.putIfAbsent(componentData.id, () => "Loading");
        loadDefaultUniqueColumns(componentData.settings.specific.masterFormColumn,
            componentData.settings.specific.masterFormId, componentData.id);
      }
      final prettyJson = JsonEncoder.withIndent('  ').convert(componentData.settings.specific);
      print(prettyJson);

      // final defaultValue = componentData.settings.specific?.defaultValueInSelectField;
      // if (defaultValue == "USER_EMAIL") {
      //   // Set the dropdown default value to the logged-in user's email
      //   final userEmail = sessionController.userData["email"];
      //   print("DefaultEmail:$userEmail");
      //   // Use userEmail in your logic
      // }
      // print("Specific JSON: ${jsonEncode(componentData.settings.specific)}");

      if (defaultDropDownValues[componentData.id] != "Loading" &&
          defaultDropDownValues[componentData.id] != "Error") {
        options.clear();
        print("Before populating2: ${options.length} items");
        print("Dropdown data being used: ${defaultDropDownValues[componentData.id]}");
        for (var element in (defaultDropDownValues[componentData.id] as List<dynamic>)) {
          //  print("Adding item: ${element['value']}");
          options.add(DropdownMenuItem(
            value: element,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              child: Text(
                element,
              ),
            ),
          ));
        }
        print("After populating2: ${options.length} items");
      }
    } else if (componentData.settings.specific.optionsType == "PREDEFINED" &&
        componentData.settings.specific.predefinedTable == "User") {
      if (!defaultDropDownValues.containsKey(componentData.id)) {
        defaultDropDownValues.putIfAbsent(componentData.id, () => "Loading");
        loadDefaultUserList(componentData.id);
      }
      if (defaultDropDownValues[componentData.id] != "Loading" &&
          defaultDropDownValues[componentData.id] != "Error") {
        options.clear();

        print("Before populating3: ${options.length} items");
        for (var element in (defaultDropDownValues[componentData.id] as List<dynamic>)) {
          options.add(DropdownMenuItem(
            value: element['value'],
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              child: Text(
                element['value'],
              ),
            ),
          ));
        }
        print("After populating3: ${options.length} items");
      }
    } else if (componentData.settings.specific.customOptions != null &&
        componentData.settings.specific.customOptions != "") {
      String separator = ",";

      if (componentData.settings.specific.separateOptionsUsing == "NEWLINE") {
        separator = "\n";
      }
      options.clear();
      print("Before populating4: ${options.length} items");

      for (var element
          in componentData.settings.specific.customOptions.toString().split(separator)) {
        print("elementdata:${element}");
        options.add(DropdownMenuItem(
          value: element,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.70,
            child: Text(
              element,
            ),
          ),
        ));
      }
      print("After populating4: ${options.length} items");

      if (!formValues.containsKey(componentData.id) &&
          componentData.settings.specific.customDefaultValue != null &&
          componentData.settings.specific.customDefaultValue != "") {
        formValues[componentData.id] = {
          "text": componentData.label,
          "value": componentData.settings.specific.customDefaultValue
        };
      }
    }

    if (componentData.settings.specific.allowToAddNewOptions) {
      options.clear();
      options.add(DropdownMenuItem(
        value: -1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add New",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                Icon(
                  EvaIcons.plus,
                  size: 22,
                  color: Colors.green,
                )
              ],
            ),
            if (options.isNotEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(
                    height: 1,
                  ))
          ],
        ),
      ));
    }

    // Check Selected value has dropdown options
    if (formValues.containsKey(componentData.id) && formValues[componentData.id]["value"] != "" ||
        selectedValue != null && selectedValue != "") {
      var value = formValues[componentData.id]["value"] ?? selectedValue!;
      bool found = false;
      for (var elm in options) {
        if (elm.value == value) {
          found = true;
        }
      }

      if (!found) {
        options.clear();

        print("Before populating5: ${options.length} items");
        options.add(DropdownMenuItem(
          value: value,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.70,
            child: Text(
              value,
            ),
          ),
        ));
      }

      print("After populating5: ${options.length} items");
    }

    return Visibility(
      visible: visibleFormControl(componentData.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        componentData.label,
                        style: Theme.of(Get.context!).textTheme.labelMedium,
                      ),
                    ),
                    if (isMandatoryField(componentData.id))
                      const Text(
                        " * ",
                        style: TextStyle(color: Colors.red),
                      )
                  ],
                ),
              ),
              if (qrValue)
                IconButton(
                    onPressed: () async {
                      dynamic result = await qrCodeScanner();
                      print("VALUE");
                      print(result);
                      if (result != null) {
                        if (result is Map<String, dynamic>) {
                          if (result.containsKey(componentData.label)) {
                            formValues[componentData.id] = {
                              "text": componentData.label,
                              "value": result[componentData.label]
                            };
                            setValuesFromQR(result);
                            setState(() {});
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.qr_code)),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Listener(
            onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            child: DropdownButtonFormField<dynamic>(
              items: options,
              key: formFieldStates[componentData.id],
              value: formValues.containsKey(componentData.id) &&
                      formValues[componentData.id]["value"] != ""
                  ? formValues[componentData.id]["value"]
                  : (componentData.settings.specific != null &&
                          componentData.settings.specific.defaultValueInSelectField == "USER_EMAIL")
                      ? sessionController.userData["email"] // Set to the logged-in user's email
                      : selectedValue == ""
                          ? null
                          : selectedValue,
              hint: Text(
                "Select",
                style: TextStyle(color: Theme.of(Get.context!).hintColor),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: checkFormControlAccess(componentData.id) &&
                        componentData.settings.general.visibility != "READ_ONLY" &&
                        (widget.readonly == null || !widget.readonly!)
                    ? Colors.white
                    : Colors.grey.withAlpha(20),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: CustomColors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: CustomColors.red, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                //   borderRadius: BorderRadius.circular(8.0),
                // ),
                focusedBorder: new UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                isCollapsed: true,
              ),
              onChanged: !checkFormControlAccess(componentData.id) ||
                      componentData.settings.general.visibility == "READ_ONLY" ||
                      widget.readonly != null && widget.readonly!
                  ? null
                  : (value) {
                      if (value == -1) {
                        formValues.remove(componentData.id);
                        formFieldStates[componentData.id]?.currentState?.reset();
                        singleInputAdaptiveDialog((value) {
                          if (value != null && value.isNotEmpty) {
                            if (componentData.settings.specific.optionsType == "CUSTOM") {
                              String values = componentData.settings.specific.customOptions;

                              if (values.isNotEmpty) {
                                if (componentData.settings.specific.separateOptionsUsing ==
                                    "NEWLINE") {
                                  values += "\n";
                                } else {
                                  values += ",";
                                }
                              }
                              values += value[0];
                              componentData.settings.specific.customOptions = values;
                            } else {
                              if (defaultDropDownValues[componentData.id] is! List<dynamic>) {
                                defaultDropDownValues[componentData.id] = [];
                              }
                              (defaultDropDownValues[componentData.id] as List<dynamic>)
                                  .add(value[0]);
                            }
                            if (callback != null) {
                              callback(value[0]);
                            } else {
                              formValues[componentData.id] = {
                                "text": componentData.label,
                                "value": value[0]
                              };
                            }
                            setState(() {});
                          }
                        }, title: "Add new Item (${componentData.label})");
                        return;
                      }

                      if (callback != null) {
                        callback(value as String?);
                        setState(() {});
                      } else {
                        formValues[componentData.id] = {
                          "text": componentData.label,
                          "value": value ?? ""
                        };
                        setState(() {});
                      }

                      setComponentVisibilityIfPossible();
                      doParentChangeEvent(componentData);
                    },
              onSaved: (value) {
                if (callback != null) {
                  callback(value);
                } else {
                  formValues[componentData.id] = {
                    "text": componentData.label,
                    "value": value ?? ""
                  };
                }
              },
              validator: ((value) {
                if (componentData.settings.validation.fieldRule == Strings.required) {
                  if (value == null || value.trim() == '') {
                    return 'Field is required!';
                  }
                }
                return null;
              }),
            ),
          ),
          if (defaultDropDownValues[componentData.id] == "Loading")
            const LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomColors.ezpurple),
            ),
          if (defaultDropDownValues[componentData.id] == "Error")
            Row(
              children: [
                const Text("Error fetching data."),
                TextButton(
                    onPressed: () {
                      setState(() {
                        print(componentData);
                        defaultDropDownValues.remove(componentData.id);
                        renderDropDownMenu(componentData, callback, selectedValue);
                      });
                    },
                    child: const Text("Retry"))
              ],
            ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget renderMultiSelectDropDownMenu(dynamic componentData) {
    if (!formFieldStates.containsKey(componentData.id)) {
      formFieldStates[componentData.id] = GlobalKey<FormFieldState>();
    }

    if (!multiSelectControllers.containsKey(componentData.id)) {
      multiSelectControllers[componentData.id] = MultiSelectController<MultiSelectDropdownItem>();
    }

    List<MultiSelectItem<dynamic>> options = [];
    List<DropdownItem<MultiSelectDropdownItem>> dropDownOptions = [];

    if (componentData.settings.specific.optionsType == "EXISTING" ||
        componentData.settings.specific.optionsType == "REPOSITORY") {
      if (!defaultDropDownValues.containsKey(componentData.id)) {
        defaultDropDownValues.putIfAbsent(componentData.id, () => "Loading");
        if (componentData.settings.specific.optionsType == "EXISTING") {
          loadDefaultUniqueColumns(componentData.id, formId, componentData.id);
        } else if (componentData.settings.specific.optionsType == "REPOSITORY") {
          if (componentData.settings.specific.repositoryFieldParent == "") {
            loadDefaultUniqueColumnsRepository(componentData.settings.specific.repositoryField,
                componentData.settings.specific.repositoryId, componentData.id);
          } else {
            loadDefaultUniqueColumnsValuesFromParentRepositoryField(componentData.id);
          }
        }
      }
      if (defaultDropDownValues[componentData.id] != "Loading" &&
          defaultDropDownValues[componentData.id] != "Error") {
        for (var element in (defaultDropDownValues[componentData.id] as List<dynamic>)) {
          options.add(MultiSelectItem(element, element));
          dropDownOptions.add(DropdownItem(
              label: element, value: MultiSelectDropdownItem(text: element, value: element)));
        }
      }
    }
    // if (componentData.settings.specific.optionsType == "EXISTING") {
    //   if (!defaultDropDownValues.containsKey(componentData.id)) {
    //     defaultDropDownValues.putIfAbsent(componentData.id, () => "Loading");
    //     loadDefaultUniqueColumns(
    //         componentData.id, widget.formId, componentData.id);
    //   }
    //   if (defaultDropDownValues[componentData.id] != "Loading") {
    //     for (var element
    //         in (defaultDropDownValues[componentData.id] as List<dynamic>)) {
    //       options.add(MultiSelectItem(element, element));
    //     }
    //   }
    // }
    else if (componentData.settings.specific.optionsType == "MASTER") {
      if (!defaultDropDownValues.containsKey(componentData.id)) {
        defaultDropDownValues.putIfAbsent(componentData.id, () => "Loading");
        loadDefaultUniqueColumns(componentData.settings.specific.masterFormColumn,
            componentData.settings.specific.masterFormId, componentData.id);
      }
      if (defaultDropDownValues[componentData.id] != "Loading" &&
          defaultDropDownValues[componentData.id] != "Error") {
        for (var element in (defaultDropDownValues[componentData.id] as List<dynamic>)) {
          options.add(MultiSelectItem(element, element));
          dropDownOptions.add(DropdownItem(
              label: element, value: MultiSelectDropdownItem(text: element, value: element)));
        }
      }
    } else if (componentData.settings.specific.optionsType == "PREDEFINED" &&
        componentData.settings.specific.predefinedTable == "User") {
      if (!defaultDropDownValues.containsKey(componentData.id)) {
        defaultDropDownValues.putIfAbsent(componentData.id, () => "Loading");
        loadDefaultUserList(componentData.id);
      }
      if (defaultDropDownValues[componentData.id] != "Loading" &&
          defaultDropDownValues[componentData.id] != "Error") {
        for (var element in (defaultDropDownValues[componentData.id] as List<dynamic>)) {
          options.add(MultiSelectItem(element['value'], element["value"]));
          dropDownOptions.add(DropdownItem(
              label: element['value'],
              value: MultiSelectDropdownItem(text: element['value'], value: element['value'])));
        }
      }
    } else {
      for (var element in componentData.settings.specific.customOptions.toString().split(',')) {
        options.add(MultiSelectItem(element, element));
        dropDownOptions.add(DropdownItem(
            label: element, value: MultiSelectDropdownItem(text: element, value: element)));
      }
    }

    if (formValues.containsKey(componentData.id)) {
      for (var elm in dropDownOptions) {
        if ((formValues[componentData.id]["value"] as List<dynamic>).contains(elm.value)) {
          elm.selected = true;
        }
      }
    }

    // If selected values not contain then add manually
    List<DropdownItem<MultiSelectDropdownItem>> missedItems = [];
    if (formValues.containsKey(componentData.id)) {
      for (var elm in (formValues[componentData.id]["value"] is List<dynamic>
          ? formValues[componentData.id]["value"] as List<dynamic>
          : formValues[componentData.id]["value"] as List<String>)) {
        var found = false;

        for (var dropdown in dropDownOptions) {
          if (dropdown.value == elm) {
            dropdown.selected = true;
            found = true;
          }
        }

        if (!found) {
          var item =
              DropdownItem(label: elm, value: MultiSelectDropdownItem(text: elm, value: elm));
          item.selected = true;
          missedItems.add(item);
        }
      }
    }

    if (componentData.settings.specific.allowToAddNewOptions) {
      options.add(
        MultiSelectItem(-1, "Add New"),
      );
      missedItems.add(DropdownItem(
          label: "Add New",
          value: MultiSelectDropdownItem(
              text: "Add New", value: -1, showCheckbox: false, addNewController: true)));
    }

    dropDownOptions = [...dropDownOptions, ...missedItems];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        multiSelectControllers[componentData.id]?.setItems(dropDownOptions);
      } catch (e) {
        print("Error setting items: $e");
      }
    });

    return Visibility(
      visible: visibleFormControl(componentData.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  componentData.label,
                  style: Theme.of(Get.context!).textTheme.labelMedium,
                ),
              ),
              if (isMandatoryField(componentData.id))
                const Text(
                  " * ",
                  style: TextStyle(color: Colors.red),
                )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          // Listener(
          //   onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          //   child: MultiSelectDialogField(
          //     key: formFieldStates[componentData.id],
          //     items: options,
          //     onConfirm: (value) {
          //       formValues[componentData.id] = {
          //         "text": componentData.label,
          //         "displayValue": defaultDropDownValues[componentData.id],
          //         "type": "MultiSelectDropDown",
          //         "value": value
          //       };
          //     },
          //     validator: ((value) {
          //       return null;
          //     }),
          //     buttonIcon: const Icon(
          //       EvaIcons.arrowDown,
          //       size: 14,
          //     ),
          //     initialValue: formValues.containsKey(componentData.id)
          //         ? formValues[componentData.id]["value"]
          //         : [],
          //     backgroundColor: Colors.white,
          //     decoration: BoxDecoration(
          //         border: Border.all(color: const Color(0xffeeeeee)),
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(10.0)),
          //     onSaved: (value) {
          //       formValues[componentData.id] = {
          //         "text": componentData.label,
          //         "displayValue": defaultDropDownValues[componentData.id],
          //         "type": "MultiSelectDropDown",
          //         "value": value
          //       };
          //     },
          //   ),
          // ),

          MultiDropdown<MultiSelectDropdownItem>(
            key: formFieldStates[componentData.id],
            controller: multiSelectControllers[componentData.id],
            items: dropDownOptions,
            // controller: controller,
            enabled: true,
            searchEnabled: false,

            // chipDecoration: const ChipDecoration(
            //   backgroundColor: Colors.yellow,
            //   wrap: true,
            //   runSpacing: 2,
            //   spacing: 10,
            // ),

            itemBuilder: (item, index, onTap) {
              var showCheckBox = item.value.showCheckbox;
              return Ink(
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStateLocal) {
                    return ListTile(
                      // Added return statement here
                      title: Text(item.label),
                      trailing: showCheckBox
                          ? Checkbox(
                              value: item.selected,
                              checkColor: Colors.green,
                              onChanged: (bool? value) {
                                setStateLocal(() {
                                  // Changed setState to setStateLocal
                                  item.selected = value ?? false;
                                  print("Item ${item.label} selected: ${item.selected}");
                                });
                                onTap();
                              },
                            )
                          : null,
                      dense: true,
                      autofocus: true,
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      onTap: () {
                        if (item.value.addNewController) {
                          singleInputAdaptiveDialog((value) {
                            if (value != null && value.isNotEmpty) {
                              if (componentData.settings.specific.optionsType == "CUSTOM") {
                                String values = componentData.settings.specific.customOptions;

                                if (values.isNotEmpty) {
                                  if (componentData.settings.specific.separateOptionsUsing ==
                                      "NEWLINE") {
                                    values += "\n";
                                  } else {
                                    values += ",";
                                  }
                                }
                                values += value[0];
                                componentData.settings.specific.customOptions = values;
                              } else {
                                if (defaultDropDownValues[componentData.id] is! List<dynamic>) {
                                  defaultDropDownValues[componentData.id] = [];
                                }
                                (defaultDropDownValues[componentData.id] as List<dynamic>)
                                    .add(value[0]);
                              }

                              var dropdownItem = DropdownItem(
                                  label: value[0],
                                  value: MultiSelectDropdownItem(value: value[0], text: value[0]));

                              multiSelectControllers[componentData.id]?.addItem(dropdownItem,
                                  index:
                                      multiSelectControllers[componentData.id]!.items.length - 1);
                            }
                          }, title: "Add new Item (${componentData.label})");
                        } else {
                          onTap();
                        }
                      },
                    );
                  },
                ),
              );
            },
            fieldDecoration: FieldDecoration(
              // hintText: 'Countries',
              // hintStyle: const TextStyle(color: Colors.black87),
              // prefixIcon: const Icon(CupertinoIcons.flag),
              showClearIcon: false,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColors.ezpurple, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            dropdownDecoration: DropdownDecoration(
              marginTop: 2,
              maxHeight: 500,
              header: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Select ${componentData.label} from the list',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            dropdownItemDecoration: DropdownItemDecoration(
              selectedIcon: const Icon(Icons.check_box, color: Colors.green),
              disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
            ),
            validator: (value) {
              return getValidation(componentData, value);
            },
            onSelectionChange: (selectedItems) {
              var values = [];
              for (var elm in selectedItems) {
                values.add(elm.value);
              }
              formValues[componentData.id] = {
                "text": componentData.label,
                "displayValue": defaultDropDownValues[componentData.id],
                "type": "MultiSelectDropDown",
                "value": values
              };
            },
          ),
          if (defaultDropDownValues[componentData.id] == "Loading")
            const LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CustomColors.ezpurple)),

          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  // Widget renderMultiSelectDropDownMenu(dynamic componentData) {
  //   if (!formFieldStates.containsKey(componentData.id)) {
  //     formFieldStates[componentData.id] = GlobalKey<FormFieldState>();
  //   }
  //
  //   if (!multiSelectControllers.containsKey(componentData.id)) {
  //     multiSelectControllers[componentData.id] = MultiSelectController<MultiSelectDropdownItem>();
  //   }
  //
  //   List<MultiSelectItem<dynamic>> options = [];
  //   List<DropdownItem<MultiSelectDropdownItem>> dropDownOptions = [];
  //
  //   if (componentData.settings.specific.optionsType == "EXISTING" ||
  //       componentData.settings.specific.optionsType == "REPOSITORY") {
  //     if (!defaultDropDownValues.containsKey(componentData.id)) {
  //       defaultDropDownValues.putIfAbsent(componentData.id, () => "Loading");
  //       if (componentData.settings.specific.optionsType == "EXISTING") {
  //         loadDefaultUniqueColumns(componentData.id, widget.formId, componentData.id);
  //       } else if (componentData.settings.specific.optionsType == "REPOSITORY") {
  //         if (componentData.settings.specific.repositoryFieldParent == "") {
  //           loadDefaultUniqueColumnsRepository(componentData.settings.specific.repositoryField,
  //               componentData.settings.specific.repositoryId, componentData.id);
  //         } else {
  //           loadDefaultUniqueColumnsValuesFromParentRepositoryField(componentData.id);
  //         }
  //       }
  //     }
  //     if (defaultDropDownValues[componentData.id] != "Loading" &&
  //         defaultDropDownValues[componentData.id] != "Error") {
  //       for (var element in (defaultDropDownValues[componentData.id] as List<dynamic>)) {
  //         options.add(MultiSelectItem(element, element));
  //         dropDownOptions.add(DropdownItem(
  //             label: element, value: MultiSelectDropdownItem(text: element, value: element)));
  //       }
  //     }
  //   }
  //   // if (componentData.settings.specific.optionsType == "EXISTING") {
  //   //   if (!defaultDropDownValues.containsKey(componentData.id)) {
  //   //     defaultDropDownValues.putIfAbsent(componentData.id, () => "Loading");
  //   //     loadDefaultUniqueColumns(
  //   //         componentData.id, widget.formId, componentData.id);
  //   //   }
  //   //   if (defaultDropDownValues[componentData.id] != "Loading") {
  //   //     for (var element
  //   //         in (defaultDropDownValues[componentData.id] as List<dynamic>)) {
  //   //       options.add(MultiSelectItem(element, element));
  //   //     }
  //   //   }
  //   // }
  //   else if (componentData.settings.specific.optionsType == "MASTER") {
  //     if (!defaultDropDownValues.containsKey(componentData.id)) {
  //       defaultDropDownValues.putIfAbsent(componentData.id, () => "Loading");
  //       loadDefaultUniqueColumns(componentData.settings.specific.masterFormColumn,
  //           componentData.settings.specific.masterFormId, componentData.id);
  //     }
  //     if (defaultDropDownValues[componentData.id] != "Loading" &&
  //         defaultDropDownValues[componentData.id] != "Error") {
  //       for (var element in (defaultDropDownValues[componentData.id] as List<dynamic>)) {
  //         options.add(MultiSelectItem(element, element));
  //         dropDownOptions.add(DropdownItem(
  //             label: element, value: MultiSelectDropdownItem(text: element, value: element)));
  //       }
  //     }
  //   } else if (componentData.settings.specific.optionsType == "PREDEFINED" &&
  //       componentData.settings.specific.predefinedTable == "User") {
  //     if (!defaultDropDownValues.containsKey(componentData.id)) {
  //       defaultDropDownValues.putIfAbsent(componentData.id, () => "Loading");
  //       loadDefaultUserList(componentData.id);
  //     }
  //     if (defaultDropDownValues[componentData.id] != "Loading" &&
  //         defaultDropDownValues[componentData.id] != "Error") {
  //       for (var element in (defaultDropDownValues[componentData.id] as List<dynamic>)) {
  //         options.add(MultiSelectItem(element['value'], element["value"]));
  //         dropDownOptions.add(DropdownItem(
  //             label: element['value'],
  //             value: MultiSelectDropdownItem(text: element['value'], value: element['value'])));
  //       }
  //     }
  //   } else {
  //     for (var element in componentData.settings.specific.customOptions.toString().split(',')) {
  //       options.add(MultiSelectItem(element, element));
  //       dropDownOptions.add(DropdownItem(
  //           label: element, value: MultiSelectDropdownItem(text: element, value: element)));
  //     }
  //   }
  //
  //   if (formValues.containsKey(componentData.id)) {
  //     for (var elm in dropDownOptions) {
  //       if ((formValues[componentData.id]["value"] as List<dynamic>).contains(elm.value)) {
  //         elm.selected = true;
  //       }
  //     }
  //   }
  //
  //   // If selected values not contain then add manually
  //   List<DropdownItem<MultiSelectDropdownItem>> missedItems = [];
  //   if (formValues.containsKey(componentData.id)) {
  //     for (var elm in (formValues[componentData.id]["value"] is List<dynamic>
  //         ? formValues[componentData.id]["value"] as List<dynamic>
  //         : formValues[componentData.id]["value"] as List<String>)) {
  //       var found = false;
  //
  //       for (var dropdown in dropDownOptions) {
  //         if (dropdown.value == elm) {
  //           dropdown.selected = true;
  //           found = true;
  //         }
  //       }
  //
  //       if (!found) {
  //         var item =
  //             DropdownItem(label: elm, value: MultiSelectDropdownItem(text: elm, value: elm));
  //         item.selected = true;
  //         missedItems.add(item);
  //       }
  //     }
  //   }
  //
  //   if (componentData.settings.specific.allowToAddNewOptions) {
  //     options.add(
  //       MultiSelectItem(-1, "Add New"),
  //     );
  //     missedItems.add(DropdownItem(
  //         label: "Add New",
  //         value: MultiSelectDropdownItem(
  //             text: "Add New", value: -1, showCheckbox: false, addNewController: true)));
  //   }
  //
  //   dropDownOptions = [...dropDownOptions, ...missedItems];
  //
  //   try {
  //     multiSelectControllers[componentData.id]?.setItems(dropDownOptions);
  //   } catch (e) {}
  //
  //   return Visibility(
  //     visible: visibleFormControl(componentData.id),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Row(
  //           children: [
  //             Flexible(
  //               child: Text(
  //                 componentData.label,
  //                 style: Theme.of(Get.context!).textTheme.labelMedium,
  //               ),
  //             ),
  //             if (isMandatoryField(componentData.id))
  //               const Text(
  //                 " * ",
  //                 style: TextStyle(color: Colors.red),
  //               )
  //           ],
  //         ),
  //         const SizedBox(
  //           height: 8,
  //         ),
  //         // Listener(
  //         //   onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
  //         //   child: MultiSelectDialogField(
  //         //     key: formFieldStates[componentData.id],
  //         //     items: options,
  //         //     onConfirm: (value) {
  //         //       formValues[componentData.id] = {
  //         //         "text": componentData.label,
  //         //         "displayValue": defaultDropDownValues[componentData.id],
  //         //         "type": "MultiSelectDropDown",
  //         //         "value": value
  //         //       };
  //         //     },
  //         //     validator: ((value) {
  //         //       return null;
  //         //     }),
  //         //     buttonIcon: const Icon(
  //         //       EvaIcons.arrowDown,
  //         //       size: 14,
  //         //     ),
  //         //     initialValue: formValues.containsKey(componentData.id)
  //         //         ? formValues[componentData.id]["value"]
  //         //         : [],
  //         //     backgroundColor: Colors.white,
  //         //     decoration: BoxDecoration(
  //         //         border: Border.all(color: const Color(0xffeeeeee)),
  //         //         color: Colors.white,
  //         //         borderRadius: BorderRadius.circular(10.0)),
  //         //     onSaved: (value) {
  //         //       formValues[componentData.id] = {
  //         //         "text": componentData.label,
  //         //         "displayValue": defaultDropDownValues[componentData.id],
  //         //         "type": "MultiSelectDropDown",
  //         //         "value": value
  //         //       };
  //         //     },
  //         //   ),
  //         // ),
  //
  //         MultiDropdown<MultiSelectDropdownItem>(
  //           key: formFieldStates[componentData.id],
  //           controller: multiSelectControllers[componentData.id],
  //           items: dropDownOptions,
  //           // controller: controller,
  //           enabled: true,
  //           searchEnabled: false,
  //
  //           // chipDecoration: const ChipDecoration(
  //           //   backgroundColor: Colors.yellow,
  //           //   wrap: true,
  //           //   runSpacing: 2,
  //           //   spacing: 10,
  //           // ),
  //
  //           itemBuilder: (item, index, onTap) {
  //             var showCheckBox = item.value.showCheckbox;
  //             return Ink(
  //               // color: Colors.red,
  //               child: ListTile(
  //                 title: Text(item.label),
  //                 trailing: showCheckBox
  //                     ? Checkbox(
  //                         value: item.selected,
  //                         activeColor: Colors.green,
  //                         // fillColor: MaterialStateProperty.all(Colors.green),
  //                         onChanged: (bool? value) {
  //                           setState(() {
  //                             item.selected = value ?? false;
  //                             print("Item ${item.label} selected: ${item.selected}");
  //                           });
  //                         },
  //                       )
  //                     : null,
  //                 dense: true,
  //                 autofocus: true,
  //                 // enabled: !option.disabled,
  //                 // selected: option.selected,
  //                 visualDensity: VisualDensity.adaptivePlatformDensity,
  //                 // focusColor: dropdownItemDecoration.backgroundColor?.withAlpha(100),
  //                 // selectedColor: dropdownItemDecoration.selectedTextColor ??
  //                 //     theme.colorScheme.onSurface,
  //                 // textColor:
  //                 // dropdownItemDecoration.textColor ?? theme.colorScheme.onSurface,
  //                 // tileColor: tileColor ?? Colors.transparent,
  //                 // selectedTileColor: dropdownItemDecoration.selectedBackgroundColor ??
  //                 //     Colors.grey.shade200,
  //                 onTap: () {
  //                   if (item.value.addNewController) {
  //                     singleInputAdaptiveDialog((value) {
  //                       if (value != null && value.isNotEmpty) {
  //                         if (componentData.settings.specific.optionsType == "CUSTOM") {
  //                           String values = componentData.settings.specific.customOptions;
  //
  //                           if (values.isNotEmpty) {
  //                             if (componentData.settings.specific.separateOptionsUsing ==
  //                                 "NEWLINE") {
  //                               values += "\n";
  //                             } else {
  //                               values += ",";
  //                             }
  //                           }
  //                           values += value[0];
  //                           componentData.settings.specific.customOptions = values;
  //                         } else {
  //                           if (defaultDropDownValues[componentData.id] is! List<dynamic>) {
  //                             defaultDropDownValues[componentData.id] = [];
  //                           }
  //                           (defaultDropDownValues[componentData.id] as List<dynamic>)
  //                               .add(value[0]);
  //                         }
  //
  //                         var dropdownItem = DropdownItem(
  //                             label: value[0],
  //                             value: MultiSelectDropdownItem(value: value[0], text: value[0]));
  //
  //                         multiSelectControllers[componentData.id]?.addItem(dropdownItem,
  //                             index: multiSelectControllers[componentData.id]!.items.length - 1);
  //                       }
  //                     }, title: "Add new Item (${componentData.label})");
  //                   } else {
  //                     setState(() {
  //                       item.selected = !item.selected;
  //                       print("Item ${item.label} selected via tap: ${item.selected}");
  //                       // updateFormValues();
  //                     });
  //                     onTap();
  //                   }
  //                 },
  //               ),
  //             );
  //           },
  //
  //           fieldDecoration: FieldDecoration(
  //             // hintText: 'Countries',
  //             // hintStyle: const TextStyle(color: Colors.black87),
  //             // prefixIcon: const Icon(CupertinoIcons.flag),
  //             showClearIcon: false,
  //             border: OutlineInputBorder(
  //               borderSide: const BorderSide(color: CustomColors.grey, width: 1),
  //               borderRadius: BorderRadius.circular(8.0),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderSide: const BorderSide(color: CustomColors.blue, width: 1),
  //               borderRadius: BorderRadius.circular(8.0),
  //             ),
  //           ),
  //           dropdownDecoration: DropdownDecoration(
  //             marginTop: 2,
  //             maxHeight: 500,
  //             header: Padding(
  //               padding: const EdgeInsets.all(8),
  //               child: Text(
  //                 'Select ${componentData.label} from the list',
  //                 textAlign: TextAlign.start,
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           dropdownItemDecoration: DropdownItemDecoration(
  //             selectedIcon: const Icon(Icons.check_box, color: Colors.green),
  //             disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
  //             selectedBackgroundColor: Colors.grey.shade200,
  //             selectedTextColor: Colors.black,
  //           ),
  //           validator: (value) {
  //             return getValidation(componentData, value);
  //           },
  //           // onSelectionChange: (selectedItems) {
  //           //   setState(() {
  //           //     var values = [];
  //           //     for (var elm in selectedItems) {
  //           //       values.add(elm.value);
  //           //       elm.selected = true; // Mark selected items as true
  //           //     }
  //           //
  //           //     formValues[componentData.id] = {
  //           //       "text": componentData.label,
  //           //       "displayValue": defaultDropDownValues[componentData.id],
  //           //       "type": "MultiSelectDropDown",
  //           //       "value": values
  //           //     };
  //           //
  //           //     // Deselect items that are not in selectedItems
  //           //     for (var item in dropDownOptions) {
  //           //       if (!selectedItems.contains(item)) {
  //           //         item.selected = false; // Uncheck items not in selectedItems
  //           //       }
  //           //     }
  //           //     // if (multiSelectControllers[componentData.id]?.items != dropDownOptions) {
  //           //     //   multiSelectControllers[componentData.id]?.setItems(dropDownOptions);
  //           //     // }
  //           //   });
  //           // },
  //
  //           onSelectionChange: (selectedItems) {
  //             var values = [];
  //             for (var elm in selectedItems) {
  //               values.add(elm.value);
  //             }
  //             formValues[componentData.id] = {
  //               "text": componentData.label,
  //               "displayValue": defaultDropDownValues[componentData.id],
  //               "type": "MultiSelectDropDown",
  //               "value": values
  //             };
  //           },
  //         ),
  //         if (defaultDropDownValues[componentData.id] == "Loading") const LinearProgressIndicator(),
  //
  //         const SizedBox(
  //           height: 8,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  IconData getRatingIcon(String icon) {
    if (icon == "HEART") {
      return Icons.favorite;
    } else if (icon == "SHIELD") {
      return Icons.shield;
    }
    return Icons.star;
  }

//TextInputType
  TextInputType getInputType(String sKeyboardType) {
    TextInputType keyboardType = TextInputType.text;
    switch (sKeyboardType) {
      case Strings.text:
        keyboardType = TextInputType.text;
        break;
      case Strings.decimal:
      case Strings.number:
      case Strings.integer:
        keyboardType = TextInputType.number;
        break;
      case Strings.email:
        keyboardType = TextInputType.emailAddress;
        break;
      case Strings.name:
        keyboardType = TextInputType.name;
        break;
    }
    return keyboardType;
  }

  Future _showDatePicker(BuildContext context, DateTime initial, DateTime firstDate,
      DateTime lastDate, Function(dynamic value) callback) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: CustomColors.ezpurple, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: CustomColors.ezpurple, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: CustomColors.ezpurple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      callback(date);
    }
  }

  Future _showTimePicker(BuildContext context, Function(TimeOfDay value) callback,
      {String timeFormat = "12"}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: timeFormat == "24"),
          child: child!,
        );
      },
    );

    if (time != null) {
      callback(time);
    }
  }

  bool doManualValidation() {
    var components = getComponents();

    for (var elm in components) {
      dynamic panel = getPanelByComponent(elm.id);
      if (panel != null) {
        if (!visibleFormControl(panel.id)) {
          continue;
        }
      }

      if (!visibleFormControl(elm.id)) {
        continue;
      }

      if (componentsVisibility.containsKey(elm.id) && componentsVisibility[elm.id] == false) {
        continue;
      }

      String fieldRule = elm.settings.validation.fieldRule;
      dynamic value;

      if (formValues.containsKey(elm.id)) {
        value = formValues[elm.id]["value"];
      }
      switch (elm.type) {
        case Strings.singleChoice:
          if (fieldRule == Strings.required && (value == null || value == "")) {
            formFieldErrors[elm.id] = '${elm.label} should not be empty';
          }
          break;
      }
    }

    return formFieldErrors.isEmpty;
  }

  _validateAllFieldsManually() {
    var components = getComponents();
    bool status = true;
    for (var elm in components) {
      if (elm.type == Strings.label) {
        continue;
      }

      // print(elm.label);

      dynamic value;
      if (formValues.containsKey(elm.id)) {
        value = formValues[elm.id]["value"];
      }

      if (elm.type == Strings.fileUpload) {
        var error = getValidation(elm, value);

        if (error != null) {
          setState(() {
            formFieldErrors[elm.id] = error;
          });
          status = false;
          continue;
        }
      } else if (elm.type == Strings.multiSelect ||
          elm.type == Strings.chips ||
          elm.type == Strings.multiChoice) {
        value = jsonEncode(value);
      }

      if (getValidation(elm, value) != null) {
        status = false;
      }
    }

    return status;
  }

  dynamic getValidation(dynamic componentData, dynamic value) {
    DateFormat defaultDateTimeFormat = DateFormat('yyyy-MM-dd hh:mm a');
    String fieldRule = componentData.settings.validation.fieldRule;
    String contentRule = componentData.settings.validation.contentRule;
    dynamic minimum = componentData.settings.validation.minimum;
    dynamic maximum = componentData.settings.validation.maximum;

    // If component type is file replace value from attachments
    if (componentData.type == Strings.fileUpload) {
      if (workflowAttachmentData.containsKey(componentData.id)) {
        value = workflowAttachmentData[componentData.id]?.length.toString() ?? "";
      }
    }

    if (componentData.type == Strings.multiSelect) {
      if (value != null && value is List<dynamic>) {
        value = value.isNotEmpty ? "Yes has Value" : "";
      }
    }

    // Check Panel is hidden
    dynamic panel = getPanelByComponent(componentData.id);
    if (panel != null) {
      if (!visibleFormControl(panel.id)) {
        return null;
      }
    }

    if (!isMandatoryField(componentData.id) &&
        fieldRule == Strings.optional &&
        (value == null || value == "")) {
      return null;
    }

    if (fieldRule == Strings.required &&
        !isMandatoryField(componentData.id) &&
        (value == null || value == "")) {
      return null;
    }

    if (!visibleFormControl(componentData.id)) {
      return null;
    }

    if (!isEnabled(componentData.id, true)) {
      return null;
    }

    if (fieldRule == Strings.required && (value == null || value == "")) {
      return '${componentData.label} should not be empty';
    }

    if (isMandatoryField(componentData.id) && (value == null || value == "")) {
      return '${componentData.label} should not be empty';
    }

    switch (contentRule) {
      case "EMAIL":
        if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(value ?? "")) {
          return "Email is not valid.";
        }
        break;
      case "WEB":
        if (!RegExp(r"^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$").hasMatch(value ?? "")) {
          return "${componentData.label} is not valid.";
        }
        break;

      case "TEXT":
        if (minimum != "" && minimum is int && (value ?? "").length < minimum) {
          return "${componentData.label} should be more than $minimum characters";
        }

        if (maximum != "" && maximum is int && (value ?? "").length > maximum) {
          return "${componentData.label} should not be more than $maximum characters";
        }
        break;

      case "INTEGER":
        if (minimum != "" &&
            minimum is int &&
            value != null &&
            value != "" &&
            int.tryParse(value ?? "") != null &&
            int.parse(value) < minimum) {
          return "${componentData.label} should not be less than $minimum";
        }

        if (maximum != "" &&
            maximum is int &&
            value != null &&
            value != "" &&
            int.tryParse(value ?? "") != null &&
            int.parse(value) > maximum) {
          return "${componentData.label} should not be more than $maximum";
        }
        break;
      case "DECIMAL":
        if (componentData.settings.validation.rangeType == "MAXIMUM") {
          if (componentData.settings.validation.maximumNumberField != "") {
            if (formValues.containsKey(componentData.settings.validation.maximumNumberField)) {
              maximum = int.tryParse(
                  formValues[componentData.settings.validation.maximumNumberField]["value"]);
            }
          }
        }

        if (minimum != "" &&
            minimum is int &&
            value != null &&
            value != "" &&
            double.tryParse(value ?? "") != null &&
            double.parse(value) < minimum) {
          return "${componentData.label} should not be less than $minimum";
        }

        if (maximum != "" &&
            maximum is int &&
            value != null &&
            value != "" &&
            double.tryParse(value ?? "") != null &&
            double.parse(value) > maximum) {
          return "${componentData.label} should not be more than $maximum";
        }
        break;
      case "":
        switch (componentData.type) {
          case Strings.date:
            if (minimum != null &&
                minimum != "" &&
                minimum is String &&
                value != null &&
                value != "" &&
                isValidDateFormat(value ?? "")) {
              DateTime currentDateTime = defaultDateTimeFormat.parse(value);
              DateTime minimumDateTime = defaultDateTimeFormat.parse(minimum);
              if (currentDateTime.isBefore(minimumDateTime)) {
                return "${componentData.label} should be greater than $minimum";
              }
            }

            if (maximum != null &&
                maximum != "" &&
                maximum is String &&
                value != null &&
                value != "" &&
                isValidDateFormat(value ?? "")) {
              DateTime currentDateTime = defaultDateTimeFormat.parse(value);
              DateTime maximumDateTime = defaultDateTimeFormat.parse(maximum);
              if (currentDateTime.isAfter(maximumDateTime)) {
                return "${componentData.label} should be lesser than $maximum";
              }
            }
            break;
          case Strings.dateTime:
            if (minimum != null &&
                minimum != "" &&
                minimum is String &&
                value != null &&
                value != "" &&
                isValidDateTimeFormat(value ?? "")) {
              DateTime currentDateTime = defaultDateTimeFormat.parse(value);
              DateTime minimumDateTime = defaultDateTimeFormat.parse(minimum);
              if (currentDateTime.isBefore(minimumDateTime)) {
                return "${componentData.label} should be greater than $minimum";
              }
            }

            if (maximum != null &&
                maximum != "" &&
                maximum is String &&
                value != null &&
                value != "" &&
                isValidDateTimeFormat(value ?? "")) {
              DateTime currentDateTime = defaultDateTimeFormat.parse(value);
              DateTime maximumDateTime = defaultDateTimeFormat.parse(maximum);
              if (currentDateTime.isAfter(maximumDateTime)) {
                return "${componentData.label} should be lesser than $maximum";
              }
            }
            break;
          case Strings.time:
            if (minimum != null &&
                minimum != "" &&
                minimum is String &&
                value != null &&
                value != "" &&
                isValidDateTimeFormat("1970-01-01 $value")) {
              DateTime currentDateTime = defaultDateTimeFormat.parse("1970-01-01 $value");
              DateTime minimumDateTime = defaultDateTimeFormat.parse("1970-01-01 $minimum");
              if (currentDateTime.isBefore(minimumDateTime)) {
                return "${componentData.label} should be greater than $minimum";
              }
            }

            if (maximum != null &&
                maximum != "" &&
                maximum is String &&
                value != null &&
                value != "" &&
                isValidDateTimeFormat("1970-01-01 $value")) {
              DateTime currentDateTime = defaultDateTimeFormat.parse("1970-01-01 $value");
              DateTime maximumDateTime = defaultDateTimeFormat.parse("1970-01-01 $maximum");
              if (currentDateTime.isAfter(maximumDateTime)) {
                return "${componentData.label} should be lesser than $maximum";
              }
            }
            break;
        }
        break;
    }
    return null;
  }

  bool isValidDateFormat(String input) {
    try {
      DateFormat format = DateFormat('yyyy-MM-dd');
      format.parse(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isValidDateTimeFormat(String input) {
    try {
      DateFormat format = DateFormat('yyyy-MM-dd hh:mm a');
      format.parse(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  TextEditingController getTextEditingController(String id) {
    if (textEditingController.containsKey(id)) {
      return textEditingController[id]!;
    }

    TextEditingController newTextEditingController = TextEditingController();
    textEditingController.putIfAbsent(id, () => newTextEditingController);
    return newTextEditingController;
  }

  dynamic getValue(String componentId) {
    if (formValues.containsKey(componentId)) {
      return formValues[componentId]["value"];
    } else {
      for (var tableKey in tableData.keys) {
        for (var tableRow in tableData[tableKey] as List<Map<String, dynamic>>) {
          if (tableRow.containsKey(componentId)) {
            return tableRow[componentId]["value"];
          }
        }
      }
    }

    return null;
  }

  Map<String, dynamic> getFields(Map<String, dynamic> formValues) {
    Map<String, dynamic> fields = {};
    for (var componentId in formValues.keys) {
      if (isMatrixComponent(componentId)) {
        var matrixComponentValuesList = [];
        for (var matrixComponentRowKey in (formValues[componentId] as Map<dynamic, dynamic>).keys) {
          var matrixComponentRowValues = {};

          for (var rowValue
              in (formValues[componentId] as Map<dynamic, dynamic>)[matrixComponentRowKey]) {
            matrixComponentRowValues[(rowValue as Map<dynamic, dynamic>).keys.elementAt(0)] =
                rowValue[(rowValue).keys.elementAt(0)];
          }

          matrixComponentValuesList.add(matrixComponentRowValues);
        }
        fields[componentId] = matrixComponentValuesList;
      } else if (isTableComponent(componentId)) {
        for (var tableRow in formValues[componentId]["value"]) {
          fields[componentId].add(getFields(tableRow));
        }
      } else if (formValues[componentId]["value"] is CroppedFile) {
        final bytes = File(formValues[componentId]["value"].path).readAsBytesSync();
        String img64 = base64Encode(bytes);
        fields[componentId] = 'data:image/png;base64,$img64';
      } else {
        // Explicitly check for empty object array cases
        if (formValues[componentId]["value"] is List && formValues[componentId]["value"].isEmpty) {
          fields[componentId] = [{}]; // Add as an empty object array
        } else {
          fields[componentId] = formValues[componentId]["value"];
        }
      }
    }

    for (String key in tableData.keys) {
      fields[key] = [];

      for (dynamic rows in (tableData[key] as List)) {
        var rowsValues = {};
        for (var rowKey in rows.keys) {
          dynamic value = rows[rowKey]["value"];
          rowsValues[rowKey] = value;
        }
        fields[key].add(rowsValues);
      }
    }
    return fields;
  }

  Map<String, dynamic> getFieldsByName(Map<String, dynamic> formValues) {
    _formKey.currentState?.save();
    Map<String, dynamic> fields = getFields(formValues);
    //Convert fieldKeys to name
    Map<String, dynamic> newFields = {};
    for (var key in fields.keys) {
      var component = getComponentById(key);
      if (component != null) {
        newFields[component.label] = fields[key];
        // fields.remove(key);
      }
    }
    return newFields;
  }

  bool isMatrixComponent(String componentId) {
    bool status = false;
    var components = [];
    if (widget.tableComponentData == null) {
      for (var panel in (widget.rootData?.panels ?? [])) {
        components.addAll(panel.fields);
      }
    } else {
      components = widget.tableComponentData.settings.specific.tableColumns;
    }

    for (var component in components) {
      if (component.id == componentId && component.type == "MATRIX") {
        status = true;
        break;
      }
    }
    return status;
  }

  bool isTableComponent(String componentId) {
    return formValues.containsKey(componentId) &&
        (formValues[componentId] as Map<dynamic, dynamic>).containsKey("type") &&
        formValues[componentId]["type"] == "Table";
  }

  Widget getMultiSelectDropDownDisplayValues(Map<String, dynamic> data) {
    // if (!data.containsKey("displayValue")) return Container();
    List<dynamic> displayValues = data["displayValue"];
    List<dynamic> values = data["value"];
    List<Widget> widgets = [];

    // for (var element in values) {
    //   for (var disElement in displayValues) {
    //     if (element == disElement["id"]) {
    //       widgets.add(Text(disElement["value"]));
    //     }
    //   }
    // }

    if (widgets.isEmpty) {
      for (var disElement in values) {
        if (disElement is String) {
          widgets.add(Text(disElement));
        }
      }
    }

    if (widgets.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widgets,
      );
    }
    return Container();
  }

  void loadDefaultUniqueColumns(String columnId, int formId, String componentId) async {
    var component = getComponentById(componentId);

    String payload = jsonEncode(AaaEncryption.EncryptDatatest(
        jsonEncode({"column": columnId, "keyword": "", "rowFrom": 0, "rowCount": 0})));

    var response = await Api()
        .clientWithHeader(responseType: Dio.ResponseType.plain)
        .post('form/$formId/uniqueColumnValues', data: payload);

    var responseResultStr = AaaEncryption.decryptAESaaa(response.data);
    var responseResult = jsonDecode(responseResultStr) as List<dynamic>;

    if (component != null && component.type == Strings.multiSelect) {
      var newData = [];
      for (var data in responseResult) {
        try {
          var childElm = jsonDecode(data);
          newData = [...newData, ...childElm];
        } catch (e) {}
      }

      defaultDropDownValues[componentId] = newData.toSet().toList();
    } else {
      defaultDropDownValues[componentId] = [];
      defaultDropDownValues[componentId] = responseResult;
    }

    setState(() {});
  }

  void loadDefaultUniqueColumnsRepository(
      String repositoryField, int repositoryId, String componentId) async {
    String payload = jsonEncode(AaaEncryption.EncryptDatatest(
        jsonEncode({"column": repositoryField, "keyword": "", "rowFrom": 0, "rowCount": 0})));

    try {
      var response = await Api()
          .clientWithHeader(responseType: Dio.ResponseType.plain)
          .post('repository/$repositoryId/uniqueColumnValues', data: payload);

      var responseResult = jsonDecode(AaaEncryption.decryptAESaaa(response.data)) as List<dynamic>;
      defaultDropDownValues[componentId] = responseResult;
    } catch (e) {
      defaultDropDownValues[componentId] = "Error";
      e.printError();
    }

    setState(() {});
  }

  void loadDefaultUniqueColumnsValuesFromParentMasterColumn(String componentId) async {
    var component = getComponentById(componentId);
    if (component == null) {
      return;
    }
    var criteriaComponent = getComponentById(component.settings.specific.masterFormParentColumn);
    if (criteriaComponent == null) {
      return;
    }

    if (formValues.containsKey(componentId)) {
      formValues.remove(componentId);
    }
    switch (component.type) {
      case Strings.shortText:
      case Strings.longText:
      case Strings.number:
      case Strings.password:
        // case Strings.calculated:
        getTextEditingController(component.id).text = "";
        break;
      default:
        break;
    }

    Map<String, dynamic> payloadObj = {
      "column": component.settings.specific.masterFormColumn,
      "keyword": "",
      "rowFrom": 0,
      "rowCount": 0,
      "filters": [
        {
          "criteria": criteriaComponent.settings.specific.masterFormColumn,
          "condition": "IS_EQUALS_TO",
          "value": formValues[criteriaComponent.id]["value"],
          "dataType": ""
        }
      ]
    };

    String payload = jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payloadObj)));

    var response = await Api().clientWithHeader(responseType: Dio.ResponseType.plain).post(
        'form/${criteriaComponent.settings.specific.masterFormId}/uniqueColumnValues',
        data: payload);

    var responseResult = jsonDecode(AaaEncryption.decryptAESaaa(response.data)) as List<dynamic>;
    print("Response Result from API: $responseResult");

    if (component.type == Strings.singleSelect || component.type == Strings.multiSelect) {
      print("Before clearing: ${defaultDropDownValues[component.id] ?? 'Not Found'}");

// Clear previous data and assign fresh list

      setState(() {
        defaultDropDownValues.remove(component.id);
        defaultDropDownValues[component.id] = [];
        defaultDropDownValues[component.id] = List<dynamic>.from(responseResult);
        doParentChangeEvent(component);
      });

      print("After updating: ${defaultDropDownValues[component.id]}");
      print("Total dropdown count: ${defaultDropDownValues.length}");

      if (responseResult.length == 1) {
        formValues[component.id] = {"text": component.label, "value": responseResult[0]};
        doParentChangeEvent(component);
      }
    } else {
      switch (component.type) {
        case Strings.shortText:
        case Strings.longText:
        case Strings.number:
        case Strings.password:
        case Strings.calculated:
          if (responseResult.isNotEmpty) {
            getTextEditingController(component.id).text = responseResult[0];
            formValues[component.id] = {"text": component.label, "value": responseResult[0]};
          }
          bindCalculatedInputParentChangeEvents();
          break;
        default:
          formValues[component.id] = {"text": component.label, "value": responseResult};
      }
    }

    setState(() {});
  }

  void loadDefaultFormValuesFromParentMasterColumn(String componentId) async {
    var component = getComponentById(componentId);
    if (component == null) {
      return;
    }
    var criteriaComponent = getComponentById(component.settings.specific.masterFormParentColumn);
    if (criteriaComponent == null) {
      return;
    }

    setState(() {
      tableDataLoading[componentId] = true;
    });

    List<dynamic>? masterFormTableColumns =
        component.settings.specific.masterFormTableColumns ?? [];

    getTableColumnIdFromMasterColumn(List<dynamic> masterFormTableColumns, String masterColumnId) {
      String tableColumnId = "";

      for (var elm in masterFormTableColumns) {
        if (elm["masterColumn"] == masterColumnId) {
          tableColumnId = elm["tableColumn"];
        }
      }

      return tableColumnId;
    }

    tableData.remove(componentId);

    Map<String, dynamic> payloadObj = {
      "mode": "BROWSE",
      "sortBy": {"criteria": "", "order": "DESC"},
      "groupBy": "",
      "filterBy": [
        {
          "filters": [
            {
              "criteria": criteriaComponent.settings.specific.masterFormColumn,
              "condition": "IS_EQUALS_TO",
              "value": formValues[criteriaComponent.id]["value"],
              "dataType": ""
            }
          ],
          "groupCondition": ""
        }
      ],
      "itemsPerPage": 0,
      "currentPage": 1
    };

    String payload = jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payloadObj)));

    try {
      var response = await Api().clientWithHeader(responseType: Dio.ResponseType.plain).post(
          'form/${criteriaComponent.settings.specific.masterFormId}/entry/all',
          data: payload);

      var responseResult =
          jsonDecode(AaaEncryption.decryptAESaaa(response.data)) as Map<String, dynamic>;

      List<dynamic> data = responseResult["data"];
      if (data.isNotEmpty) {
        List<dynamic> values = data[0]["value"];

        for (var tableValues in values) {
          Map<String, dynamic> tableRow = {};
          for (var key in (tableValues as Map<String, dynamic>).keys) {
            String tableComponentId =
                getTableColumnIdFromMasterColumn(masterFormTableColumns!, key);
            dynamic tableComponent = getTableComponentById(componentId, tableComponentId);
            if (tableComponent != null) {
              tableRow[tableComponentId] = {
                "text": tableComponent.label,
                "value": tableValues[key]
              };
            }
          }
          if (!tableData.containsKey(componentId)) {
            tableData[componentId] = [];
          }

          tableData[componentId]!.add(tableRow);
        }
      }
    } catch (e) {}

    tableDataLoading[componentId] = false;

    setState(() {});
  }

  void loadDefaultValuesFromParentMasterColumnText(String componentId, id, componentData) async {
    Map<String, dynamic> payloadObj = {
      "mode": "BROWSE",
      "sortBy": {"criteria": "", "order": "DESC"},
      "groupBy": "",
      "filterBy": [
        {
          "filters": [
            {
              "criteria": usernameField,
              "condition": "IS_EQUALS_TO",
              "value": sessionController.userDetails.value.email,
              "dataType": componentData.type
            }
          ],
          "groupCondition": ""
        }
      ],
      "itemsPerPage": 10,
      "currentPage": 1,
      "portalId": "1"
    };

    String payload = jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payloadObj)));
    int formids = 3;
    try {
      var response = await Api()
          .clientWithHeader(responseType: Dio.ResponseType.plain)
          .post('form/$MFormId/entry/all', data: payload);

      var responseResult =
          jsonDecode(AaaEncryption.decryptAESaaa(response.data)) as Map<String, dynamic>;

      List<dynamic> data = responseResult["data"];
      if (data.isNotEmpty) {
        List<dynamic> values = data[0]["value"];
        print("DefaultShortText:$values");
        for (var item in values) {
          if (item.containsKey(componentId)) {
            print("Matched Value: ${item[componentId]}");
            if (item[componentId] != null) {
              if (componentData.settings.general.visibility == "DISABLE") {
                formValues[componentData.id] = {
                  "text": componentData.label,
                  "value": item[componentId].toString(),
                };
              } else {
                getTextEditingController(id).text = item[componentId].toString();
              }
            } else {
              print("No value found for $componentId");
            }

            //   getTextEditingController(id).text = {item[componentId]};
            // Use the value as needed
          }
        }
      }
    } catch (e) {}

    tableDataLoading[componentId] = false;

    setState(() {});
  }

  List<dynamic> getChainedValuesFromParentRepository(String id) {
    print(id);
    var values = [];

    var criteriaComponent = getComponentById(id);
    values.add({
      "criteria": criteriaComponent.label,
      "condition": "IS_EQUALS_TO",
      "value": formValues[id]["value"],
      "dataType": criteriaComponent.type,
      "fieldId": criteriaComponent.id
    });

    if (criteriaComponent.settings.specific.repositoryFieldParent != "") {
      values.addAll(getChainedValuesFromParentRepository(
          criteriaComponent.settings.specific.repositoryFieldParent));
    }

    return values;
  }

  void loadDefaultUniqueColumnsValuesFromParentRepositoryField(String componentId) async {
    if (componentId == "77-Svg_Ps-axOj__C5Fpn") {
      print("<><><><><><><><><><START><<><><><><><><><>");
    }

    var component = getComponentById(componentId);
    if (component == null) {
      return;
    }
    var criteriaComponent = getComponentById(component.settings.specific.repositoryFieldParent);
    if (criteriaComponent == null) {
      return;
    }

    if (component.type == Strings.multiSelect) {
      if (!multiSelectControllers.containsKey(component.id)) {
        (multiSelectControllers[component.id] as MultiSelectController<MultiSelectDropdownItem>)
            .setItems([]);
      }
    }
    if (defaultDropDownValues[componentId] is List<dynamic> ||
        defaultDropDownValues[componentId] is List<String>) {
      defaultDropDownValues[componentId].clear();
    }

    // setState(() {
    defaultDropDownValues[component.id] = "Loading";
    // });

    var filters = [];
    var payloadObj = {
      "column": component.settings.specific.repositoryField,
      "keyword": "",
      "rowFrom": 0,
      "rowCount": 0,
    };

    bool isParentValueAdded = false;
    if (formValues.containsKey(criteriaComponent.id)) {
      isParentValueAdded = true;
      // filters.add({
      //   "criteria": criteriaComponent.settings.specific.repositoryField,
      //   "condition": "IS_EQUALS_TO",
      //   "value": formValues[criteriaComponent.id]["value"],
      //   "dataType": ""
      // });
      filters = getChainedValuesFromParentRepository(criteriaComponent.id);
    }

    if (filters.isNotEmpty) {
      payloadObj["filters"] = filters;
    }

    print(payloadObj);

    String payload = jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(payloadObj)));

    try {
      var response = await Api().clientWithHeader(responseType: Dio.ResponseType.plain).post(
          'repository/${criteriaComponent.settings.specific.repositoryId}/uniqueColumnValues',
          data: payload);

      var responseResult = jsonDecode(AaaEncryption.decryptAESaaa(response.data)) as List<dynamic>;

      print("VALUE VALUE");
      print(responseResult);
      defaultDropDownValues[componentId] = [];
      defaultDropDownValues[componentId] = responseResult;

      if (formValues.containsKey(componentId)) {
        formValues.remove(componentId);
      }

      if (isParentValueAdded && responseResult.length == 1) {
        if (component.type == Strings.multiSelect) {
          // formValues[componentId] = {
          //   "text": component.label,
          //   "value": [responseResult[0]]
          // };
        } else {
          formValues[componentId] = {"text": component.label, "value": responseResult[0]};
        }
        doParentChangeEvent(component);
      }
    } catch (e) {
      defaultDropDownValues[component.id] = "Error";
      e.printError();
    }

    if (componentId == "77-Svg_Ps-axOj__C5Fpn") {
      print("<><><><><><><><><><END><<><><><><><><><>");
    }
    setState(() {});
  }

  void loadDefaultUserList(String componentId) async {
    String payload = jsonEncode(
        AaaEncryption.EncryptDatatest(jsonEncode({"criteria": "userType", "value": "Normal"})));

    var response = await Api()
        .clientWithHeader(responseType: Dio.ResponseType.plain)
        .post('user/list', data: payload);

    var responseResult = jsonDecode(AaaEncryption.decryptAESaaa(response.data)) as List<dynamic>;
    defaultDropDownValues[componentId] = responseResult;
    setState(() {});
  }

  void setInitialComponentVisibility(String id, dynamic components) {
    if (componentsVisibility.containsKey(id)) return;

    for (var component in components) {
      if (component.settings.validation.enableSettings.length > 0) {
        for (var setting in component.settings.validation.enableSettings) {
          if (setting.controls.contains(id)) {
            componentsVisibility[id] = false;
          }
        }
      }
    }
  }

  void setComponentVisibilityIfPossible() {
    var components = [];
    if (widget.tableComponentData == null) {
      for (var panel in (widget.rootData?.panels ?? [])) {
        components.addAll(panel.fields);
      }
    } else {
      components = widget.tableComponentData.settings.specific.tableColumns;
    }

    componentsVisibility.clear();

    for (var component in components) {
      for (var setting in component.settings.validation.enableSettings) {
        if (setting.controls.length > 0) {
          for (var control in setting.controls) {
            if (!componentsVisibility.containsKey(control)) {
              componentsVisibility[control] = false;
            }
          }

          if (formValues.containsKey(component.id)) {
            var value = formValues[component.id]["value"];
            if (component.settings.validation.enableSettings.length > 0) {
              if (setting.value == value) {
                for (var control in setting.controls) {
                  componentsVisibility[control] = true;
                }
              }
            }
          }
        }
      }
    }

    for (var element in componentsVisibility.keys) {
      if (componentsVisibility[element] == false && formValues.containsKey(element)) {
        formValues.remove(element);
      }
    }

    setState(() {});
  }

  void bindParentChangeEvents(dynamic component) {
    var components = [];
    if (widget.tableComponentData == null) {
      for (var panel in (widget.rootData?.panels ?? [])) {
        components.addAll(panel.fields);
      }
    } else {
      components = widget.tableComponentData.settings.specific.tableColumns;
    }

    if (component.settings.specific.masterFormParentColumn != null &&
        component.settings.specific.masterFormParentColumn != "") {
      if (!parentComponentChangeEvents
          .containsKey(component.settings.specific.masterFormParentColumn)) {
        parentComponentChangeEvents[component.settings.specific.masterFormParentColumn] = [];
      }
      if (!parentComponentChangeEvents[component.settings.specific.masterFormParentColumn]!
          .contains(component.id)) {
        parentComponentChangeEvents[component.settings.specific.masterFormParentColumn]
            ?.add(component.id);
      }
    } else if (component.settings.specific.repositoryFieldParent != null &&
        component.settings.specific.repositoryFieldParent != "") {
      if (!parentComponentChangeEvents
          .containsKey(component.settings.specific.repositoryFieldParent)) {
        parentComponentChangeEvents[component.settings.specific.repositoryFieldParent] = [];
      }
      if (!parentComponentChangeEvents[component.settings.specific.repositoryFieldParent]!
          .contains(component.id)) {
        parentComponentChangeEvents[component.settings.specific.repositoryFieldParent]
            ?.add(component.id);
      }
    } else if (component.settings.specific.parentDateField != null &&
        component.settings.specific.parentDateField != "") {
      if (!parentComponentChangeEvents.containsKey(component.settings.specific.parentDateField)) {
        parentComponentChangeEvents[component.settings.specific.parentDateField] = [];
      }
      if (!parentComponentChangeEvents[component.settings.specific.parentDateField]!
          .contains(component.id)) {
        parentComponentChangeEvents[component.settings.specific.parentDateField]?.add(component.id);
      }

      if (component.settings.specific.parentOptionField != null &&
          component.settings.specific.parentOptionField != "") {
        if (!parentComponentChangeEvents
            .containsKey(component.settings.specific.parentOptionField)) {
          parentComponentChangeEvents[component.settings.specific.parentOptionField] = [];
        }
        if (!parentComponentChangeEvents[component.settings.specific.parentOptionField]!
            .contains(component.id)) {
          parentComponentChangeEvents[component.settings.specific.parentOptionField]
              ?.add(component.id);
        }
      }
    }
  }

  void bindCalculatedInputParentChangeEvents() {
    if (widget.rootData == null || widget.rootData.settings == null) {
      return;
    }

    if (widget.rootData.settings.rules.length > 0) {
      for (var rule in widget.rootData.settings.rules) {
        for (var calculation in rule.calculations) {
          bool isTimeCalculation = false;
          var firstDateTime;
          var secondDateTime;

          var math = "";

          int totalMinutes = 0;
          for (var formula in calculation.formula) {
            if (formula.name == "FIELD") {
              var component = getComponentById(formula.value);
              if (component != null) {
                if (formValues.containsKey(formula.value)) {
                  var value = getValue(formula.value);
                  print(value);
                  if (component.type == Strings.number) {
                    if (value == "") value = 0;
                    math += double.parse((value ?? "0").toString()).toString();
                  } else if (component.type == Strings.time) {
                    isTimeCalculation = true;
                    var time = value.toString();
                    if (firstDateTime == null) {
                      firstDateTime = time;
                    } else {
                      secondDateTime = time;
                    }

                    // List<String> formats = ["yyyy-M-dd h:m a", "yyyy-M-dd H:m"];
                    //
                    // var time = value.toString();
                    // DateTime? dateTime;
                    // for (String format in formats) {
                    //   try {
                    //     dateTime = DateFormat(format).parse(
                    //         "${DateFormat("yyyy-M-dd").format(DateTime.now())} $time");
                    //     break;
                    //   } catch (e) {
                    //     // Continue to the next format
                    //     continue;
                    //   }
                    // }
                    //
                    // if (dateTime != null) {
                    //   firstDateTime ??= dateTime;
                    //
                    //   int minutes = dateTime
                    //       .difference(DateFormat("yyyy-M-dd h:m:s").parse(
                    //           "${DateFormat("yyyy-M-dd").format(DateTime.now())} 00:00:00"))
                    //       .inMinutes;
                    //   totalMinutes += minutes;
                    //
                    //   math += minutes.toString();
                    // } else {
                    //   math += "0";
                    // }
                  }
                } else {
                  math += "0";
                }
              }
            } else if (formula.label != "") {
              math += formula.label;
            }
          }

          print(math);
          // if (isTimeCalculation) {
          //   int hours = totalMinutes ~/ 60;
          //   int minutes = totalMinutes % 60;
          //   math = "$hours.${minutes.toString().padLeft(2, '0')}";
          // }

          if (math != "") {
            double eval = 0;

            if (isTimeCalculation) {
              int minutes = calculateTimeDifference(secondDateTime, firstDateTime);
              int hours = (minutes / 60).floor();
              int remMinutes = (minutes - (hours * 60)).toInt();
              double remMinutesInHour = (remMinutes / 100);
              eval = hours + remMinutesInHour;
            } else {
              try {
                Parser p = Parser();
                Expression exp = p.parse(math);
                eval = exp.evaluate(EvaluationType.REAL, ContextModel());
              } catch (e) {}
            }

            if (calculation.columnId != "") {
              if (getTextEditingController(calculation.columnId).text != eval.toStringAsFixed(2)) {
                getTextEditingController(calculation.columnId).text = eval.toStringAsFixed(2);
              }
            } else {
              if (getTextEditingController(calculation.fieldId).text != eval.toStringAsFixed(2)) {
                getTextEditingController(calculation.fieldId).text = eval.toStringAsFixed(2);
              }
            }
          }
        }
      }
    }
  }

  int calculateTimeDifference(String time1, String time2) {
    List<String> formats = ["h:mm a", "H:mm"];

    print(time1);
    print(time2);

    DateTime? firstTime;
    DateTime? secondTime;
    for (String format in formats) {
      DateFormat dateFormat = DateFormat(format);

      try {
        firstTime ??= dateFormat.parse(time1);
      } catch (e) {}
      try {
        secondTime ??= dateFormat.parse(time2);
      } catch (e) {}
    }

    if (firstTime == null || secondTime == null) return 0;

    // If second time is earlier, consider it as the next day
    if (secondTime.isBefore(firstTime)) {
      secondTime = secondTime.add(const Duration(days: 1));
    }

    // Calculate the difference in minutes
    Duration difference = secondTime.difference(firstTime);
    return difference.inMinutes;
  }

  dynamic getComponentById(String componentId) {
    var components = [];
    if (widget.tableComponentData == null) {
      for (var panel in (widget.rootData?.panels ?? [])) {
        components.addAll(panel.fields);
      }
    } else {
      components = widget.tableComponentData.settings.specific.tableColumns;
    }

    for (var element in components) {
      if (element.id == componentId) {
        return element;
      }
    }

    return null;
  }

  dynamic getPanelByComponent(String componentId) {
    for (var panel in (widget.rootData?.panels ?? [])) {
      for (var element in panel.fields) {
        if (element.id == componentId) {
          return panel;
        }
      }
    }

    return null;
  }

  dynamic getTableComponentById(String tableComponentId, String tableComponentChildId) {
    var tableComponent = getComponentById(tableComponentId);
    if (tableComponent != null) {
      for (var tableColumn in tableComponent.settings.specific.tableColumns) {
        if (tableColumn.id == tableComponentChildId) {
          return tableColumn;
        }
      }
    }
    return null;
  }

  void addInputDefaultValues(dynamic componentData) {
    if (!textEditingController.containsKey(componentData.id)) {
      if (formValues.containsKey(componentData.id)) {
        getTextEditingController(componentData.id).text = formValues[componentData.id]["value"];
      } else {
        if (componentData.settings.specific.customDefaultValue != null &&
            componentData.settings.specific.customDefaultValue != "") {
          if (componentData.settings.specific.customDefaultValue != null) {
            if (!formValues.containsKey(componentData.id)) {
              formValues[componentData.id] = {
                "text": componentData.label,
                "value": componentData.settings.specific.customDefaultValue
              };
            }

            getTextEditingController(componentData.id).text =
                componentData.settings.specific.customDefaultValue.toString();
          } else {
            getTextEditingController(componentData.id).text = "";
          }
        } else if (componentData.settings.specific.defaultValue == "USER_NAME") {
          getTextEditingController(componentData.id).text =
              '${sessionController.userDetails.value.firstName} ${sessionController.userDetails.value.lastName}';
        } else if (componentData.settings.specific.defaultValue == "USER_EMAIL") {
          getTextEditingController(componentData.id).text =
              sessionController.userDetails.value.email;
        } else if (componentData.settings.specific.defaultValue == "MASTER") {
          loadDefaultValuesFromParentMasterColumnText(
              componentData.settings.specific.masterFormColumn, componentData.id, componentData);
          // getTextEditingController(componentData.id).text =
          //     sessionController.userDetails.value.email;
        } else if (componentData.settings.specific.defaultValue == "CURRENT_DATE") {
          getTextEditingController(componentData.id).text =
              DateFormat("yyyy-MM-dd").format(DateTime.now());
        } else if (componentData.settings.specific.defaultValue == "CURRENT_TIME") {
          getTextEditingController(componentData.id).text =
              DateFormat("hh:mm a").format(DateTime.now());
        } else if (componentData.settings.specific.defaultValue == "CURRENT_DATE_TIME") {
          getTextEditingController(componentData.id).text =
              DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now());
        } else if (componentData.settings.specific.defaultValue == "AUTO_GENERATE") {
          getTextEditingController(componentData.id).text = getAutoGenerateValue(componentData);
        }
      }
    }
  }

  String getAutoGenerateValue(dynamic componentData) {
    if (componentData.settings.specific.defaultValue == "AUTO_GENERATE") {
      String value = componentData.settings.specific.autoGenerateValue.prefix;
      if (componentData.settings.specific.autoGenerateValue.suffix == "DATE_TIME") {
        if (value.isNotEmpty) {
          value += " - ";
        }
        value += DateFormat("yyyyMMddhhmmss").format(DateTime.now());
      } else if (componentData.settings.specific.autoGenerateValue.suffix == "TIME") {
        if (value.isNotEmpty) {
          value += " - ";
          value += DateFormat("hhmmss").format(DateTime.now());
        }
      }
      return value;
    }
    return "";
  }

  void singleInputAdaptiveDialog(Function(List<String>? value) callback,
      {title = "", message = ""}) async {
    List<String>? result = await showTextInputDialog(
        context: Get.context!,
        textFields: [const DialogTextField()],
        title: title ?? "",
        message: message,
        okLabel: "Add");
    callback(result);
  }

  void submitWorkflow(Map<String, dynamic> request) async {
    setState(() {
      isLoading = true;
    });

    try {
      print("Request Payload: ${jsonEncode(request)}");

      if (request["review"] != "" && widget.transactionId != null && widget.processId != null) {
        var fields = getFields(formValues);

        bool isAllFileAttached = false;

        // Uncomment after verifying attachment logic
        isAllFileAttached = await WorkflowAttachments.isAllRequiredFilesAdded(
            widget.workflowId, widget.transactionId!, widget.processId!, fileCheckList, fields);

        if (!isAllFileAttached) {
          setState(() {
            isLoading = false;
          });

          Fluttertoast.showToast(
            msg: "Upload required documents.",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }
      }

      if (deleteFiles.isNotEmpty) {
        await Future.forEach<String>(deleteFiles.keys, (key) async {
          await workflowRepository.deleteAttachments(widget.repositoryId, 1, {
            "ids": deleteFiles[key]!.map((elm) => elm["itemId"]).toList(),
            "formInfo": {"formId": formId, "formEntryId": widget.formEntryId, "jsonId": key}
          });
        });
      }

      // Prepare API Payload
      String json = jsonEncode(request);
      String payload = jsonEncode(AaaEncryption.EncryptDatatest(json));

      // API Call
      var response = await Api()
          .clientWithHeader(responseType: Dio.ResponseType.plain)
          .post('workflow/transaction', data: payload);

      if (response.statusCode == 201) {
        // Decrypt and parse response
        var responseResult =
            jsonDecode(AaaEncryption.decryptAESaaa(response.data)) as Map<String, dynamic>;
        print("API Response: $responseResult");

        // Handle signature scenario
        if (userSignature) {
          await workflowRepository.signWithProcessId(
            widget.workflowId,
            responseResult["processId"] != 0 ? responseResult["processId"] : widget.processId,
            responseResult["transactionId"],
            {"signBinary": signature, "fileType": "png"},
          ).then((response) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16), topRight: Radius.circular(16))),
              content: Text(
                responseResult["requestNo"] +
                    (request["review"] != "" ? " Request Processed" : " Request Initiated."),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ));
            Get.back(result: true);
          }).onError((error, stackTrace) {
            print("Error in signing: $error");
            Snack.errorSnack(context, "Error Requesting Process");
          });
        } else {
          // Handle non-signature scenario
          try {
            String requestNo = responseResult["requestNo"] ?? "Unknown Request";
            String reviewStatus = (request["review"] ?? "").toString();

            Fluttertoast.showToast(
              msg: requestNo +
                  (reviewStatus.isNotEmpty ? " Request Processed" : " Request Initiated."),
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            Get.to(WorkflowList(
              sWorkflowId: widget.workflowId,
              sType: 1,
            ));
            // Close the workflow
            //  Get.back(result: true);
          } catch (e) {
            print("Error displaying toast: $e");
            Fluttertoast.showToast(
              msg: "An error occurred while processing the response.",
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        }
      } else {
        // Handle non-successful status code
        print("API Error: ${response.statusCode}");
        Snack.errorSnack(context, "Failed to submit the request.");
      }
    } catch (e) {
      print("Unexpected Error: $e");
      Fluttertoast.showToast(
        msg: "Unexpected error occurred.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      // Reset loading state
      setState(() {
        isLoading = false;
      });
    }
  }

  // void submitWorkflow(Map<String, dynamic> request) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   print(jsonEncode(request));
  //
  //   if (request["review"] != "" && widget.transactionId != null && widget.processId != null) {
  //     var fields = getFields(formValues);
  //
  //     bool isAllFileAttached = false;
  //
  //     // isAllFileAttached= await WorkflowAttachments.isAllRequiredFilesAdded(
  //     //     widget.workflowId, widget.transactionId!, widget.processId!, fileCheckList, fields);
  //
  //     if (!isAllFileAttached) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //
  //       Fluttertoast.showToast(
  //           msg: "Upload required documents.",
  //           backgroundColor: Colors.red,
  //           textColor: Colors.white);
  //       return;
  //     }
  //   }
  //
  //   if (deleteFiles.isNotEmpty) {
  //     await Future.forEach<String>(deleteFiles.keys, (key) async {
  //       await workflowRepository.deleteAttachments(widget.repositoryId, 1, {
  //         "ids": deleteFiles[key]!.map((elm) => elm["itemId"]).toList(),
  //         "formInfo": {"formId": formId, "formEntryId": widget.formEntryId, "jsonId": key}
  //       });
  //     });
  //   }
  //
  //   String json = jsonEncode(request);
  //   String payload = jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode(request)));
  //
  //   Api()
  //       .clientWithHeader(responseType: Dio.ResponseType.plain)
  //       .post('workflow/transaction', data: payload)
  //       .then((response) {
  //     if (response.statusCode == 201) {
  //       var responseResult =
  //           jsonDecode(AaaEncryption.decryptAESaaa(response.data)) as Map<String, dynamic>;
  //       print("API Response: $responseResult");
  //       if (userSignature) {
  //         workflowRepository.signWithProcessId(
  //             widget.workflowId,
  //             responseResult["processId"] != 0 ? responseResult["processId"] : widget.processId,
  //             responseResult["transactionId"],
  //             {"signBinary": signature, "fileType": "png"}).then((response) {
  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //             shape: const RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(16), topRight: Radius.circular(16))),
  //             content: Text(
  //               responseResult["requestNo"] +
  //                   (request["review"] != "" ? " Request Processed" : " Request Initiated."),
  //               style: const TextStyle(color: Colors.white),
  //             ),
  //             backgroundColor: Colors.green,
  //           ));
  //
  //           Get.back(result: true);
  //         }).onError((error, stackTrace) {
  //           print(error);
  //           Snack.errorSnack(context, "Error Requesting Process");
  //           setState(() {
  //             isLoading = false;
  //           });
  //         });
  //       } else {
  //         print("Error 1");
  //         try {
  //           String requestNo = responseResult["requestNo"] ?? "Unknown Request";
  //           String reviewStatus = (request["review"] ?? "").toString();
  //
  //           Fluttertoast.showToast(
  //             msg: requestNo +
  //                 (reviewStatus.isNotEmpty ? " Request Processed" : " Request Initiated."),
  //             backgroundColor: Colors.green,
  //             textColor: Colors.white,
  //           );
  //         } catch (e) {
  //           print("Error displaying toast: $e");
  //           Fluttertoast.showToast(
  //             msg: "An error occurred while processing the request.",
  //             backgroundColor: Colors.red,
  //             textColor: Colors.white,
  //           );
  //         }
  //
  //         // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         //   shape: const RoundedRectangleBorder(
  //         //       borderRadius: BorderRadius.only(
  //         //           topLeft: Radius.circular(16),
  //         //           topRight: Radius.circular(16))),
  //         //   content: Text(
  //         //     responseResult["requestNo"] +
  //         //         (request["review"] != ""
  //         //             ? " Request Processed"
  //         //             : " Request Initiated."),
  //         //     style: const TextStyle(color: Colors.white),
  //         //   ),
  //         //   backgroundColor: Colors.green,
  //         // ));
  //         Get.back(result: true);
  //       }
  //     }
  //   }).onError((error, stackTrace) {
  //     print("Error");
  //     print(error);
  //     Snack.errorSnack(context, "Error Requesting Process");
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }

  Widget loadPanels(data) {
    Widget answerIndicator = Container();

    List<Widget> widgets = [];

    if (showAnswerIndicator) {
      answerIndicator = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (answerIndicatorLevel > 0)
            Container(
              decoration: BoxDecoration(
                  color: Colors.green.withAlpha(200), borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "$answerIndicatorLevel ready",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          const SizedBox(
            width: 8,
          ),
          Container(
              decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(100), borderRadius: BorderRadius.circular(8)),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${totalAnswerIndicatorLevel - answerIndicatorLevel} need to work",
                      style: const TextStyle(fontWeight: FontWeight.w600))))
        ],
      );
    }
    for (var p = 0; p < (data?.panels?.length ?? 0); p++) {
      List<Widget> panelFields = [];
      if (!visibleFormControl(data?.panels[p].id)) {
        continue;
      }

      // Separator
      panelFields.add(Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p > 0)
            Container(
              height: 16,
              width: double.infinity,
              color: Colors.grey.withAlpha(20),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 16),
            child: Text(
              data.panels[p].settings.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ));

      for (var i = 0; i < data?.panels[p].fields.length; i++) {
        print("Field ID: ${data.panels[p].fields[i].id}");
        print("Field Label: ${data.panels[p].fields[i].label}");
        print("Field Settings: ${jsonEncode(data.panels[p].fields[i].settings)}");

        panelFields.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Offstage(
            offstage: !(componentsVisibility.containsKey(data.panels[p].fields[i].id) &&
                    componentsVisibility[data.panels[p].fields[i].id]! ||
                !componentsVisibility.containsKey(data.panels[p].fields[i].id)),
            child: Visibility(
              visible: visibleFormControl(data?.panels[p].fields[i].id),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: loadComponents(data.panels[p].fields[i], data.panels[p].fields),
              ),
            ),
          ),
        ));
      }

      if (workFlowMain?.layout == Strings.txt_layout_card) {
        panelFields.add(Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (p > 0)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                      child: const Text("Previous", style: const TextStyle(color: Colors.red)),
                      onPressed: () {
                        _controller.previousPage(
                            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      })),
            if (p < data?.panels.length - 1)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                      child: const Text("Next", style: const TextStyle(color: Colors.red)),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                        } else {
                          print("Not Valid form");
                        }
                      })),
          ],
        ));

        widgets.add(Column(children: panelFields));
      } else {
        widgets.addAll(panelFields);
      }

      if (p == data.panels.length - 1) {
        if (signatureList.isNotEmpty) {
          widgets.add(renderSignatureList());
        }

        if (userSignature) {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    "Signature",
                    style: Theme.of(Get.context!).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (signature != "")
                          Image.memory(base64Decode(signature))
                        else
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.draw_sharp,
                              size: 75,
                              color: Colors.grey,
                            ),
                          ),
                        if (signature != "")
                          IconButton(
                              onPressed: () {
                                signaturePadKey.currentState?.clear();
                                setState(() {
                                  signature = "";
                                });
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              )),
                        Column(
                          children: [
                            Divider(
                              height: 2,
                              color: Colors.grey.withAlpha(40),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      isScrollControlled: false,
                                      isDismissible: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.vertical(top: Radius.circular(16.0)),
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      builder: (BuildContext context) {
                                        return SizedBox(
                                          width: double.infinity,
                                          height: 436,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Text("Draw your signature"),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(left: 16.0, right: 16),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey),
                                                        borderRadius: BorderRadius.circular(8)),
                                                    child: SfSignaturePad(
                                                      key: signaturePadKey,
                                                    )),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      onPressed: () {
                                                        signaturePadKey.currentState?.clear();
                                                      },
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      )),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(horizontal: 16.0),
                                                child: Divider(
                                                  height: 1,
                                                  color: Colors.grey.withAlpha(40),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("Cancel")),
                                                  const SizedBox(
                                                    width: 16,
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      ui.Image image = await signaturePadKey
                                                          .currentState!
                                                          .toImage();
                                                      ByteData? byteData = await image.toByteData(
                                                          format: ui.ImageByteFormat.png);
                                                      if (byteData != null) {
                                                        Uint8List pngBytes =
                                                            byteData.buffer.asUint8List();
                                                        signature = base64Encode(pngBytes);
                                                        setState(() {});
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        elevation: 3,
                                                        backgroundColor: CustomColors.ezpurple,
                                                        textStyle:
                                                            const TextStyle(color: Colors.white)),
                                                    child: const Text(
                                                      "Save",
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    minimumSize: Size.zero,
                                  ),
                                  child: const Text(
                                    "Draw",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Text("or"),
                                TextButton(
                                  onPressed: () async {
                                    FilePickerResult? pickedFiles = await FilePicker.platform
                                        .pickFiles(
                                            type: FileType.image,
                                            allowMultiple: false,
                                            allowCompression: true,
                                            compressionQuality: 50);

                                    if (pickedFiles != null) {
                                      Uint8List bytes =
                                          File(pickedFiles.files[0].path!).readAsBytesSync();
                                      signature = base64Encode(bytes);
                                      setState(() {});
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    minimumSize: Size.zero,
                                  ),
                                  child: const Text("Upload",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const Text("your signature"),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
        }
      }
    }

    if (workFlowMain?.layout == Strings.txt_layout_card && widget.tableComponentData == null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: PageView.builder(
            scrollDirection: Axis.horizontal,
            // physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            itemCount: widget.tableComponentData == null ? widgets.length : 1,
            onPageChanged: (int page) {
              if (autoValidateWhenSwitchPage) {
                autoValidateWhenSwitchPage = false;
                _formKey.currentState?.validate();
              }
              setState(() {
                pageTitle = data?.panels[page].settings.title ?? "";
              });
            },
            itemBuilder: (BuildContext context, int index) {
              return SingleChildScrollView(
                  child: Column(
                children: [
                  answerIndicator,
                  widgets[index],
                ],
              ));
            }),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget loadStepper(data) {
    if (workFlowMain?.layout == Strings.txt_layout_card) {
      return EasyStepper(activeStep: 0, steps: [
        for (var p = 0; p < data?.panels.length; p++)
          EasyStep(
            customStep: const CircleAvatar(
              radius: 8,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 7,
                backgroundColor: Colors.orange,
              ),
            ),
            title: data!.panels[p].settings.title,
          ),
      ]);
    }

    return Container();
  }

  void bindValuesFromInboxDetails() {
    if (widget.existingDataFields != null) {
      Map<String, dynamic>? fields = widget.existingDataFields!;

      for (var key in fields.keys) {
        var component = getComponentById(key);
        if (component != null) {
          switch (component.type) {
            case Strings.multiSelect:
              formValues[key] = {
                "text": component.label,
                "value": jsonDecode(fields[key]) ?? [],
                "displayValue": defaultDropDownValues[component.id] ?? [],
                "type": "MultiSelectDropDown",
              };
              break;
            case Strings.multiChoice:
              try {
                formValues[key] = {
                  "text": component.label,
                  "value": jsonDecode(fields[key]) ?? [],
                };
              } catch (e) {
                formValues[key] = {
                  "text": component.label,
                  "value": [],
                };
              }
              break;
            case Strings.chips:
              formValues[key] = {
                "text": component.label,
                "value": List<String>.from(jsonDecode(fields[key]) ?? [])
              };
              break;
            case Strings.table:
              String rowsStr = fields[key];
              try {
                List<dynamic>? rows = jsonDecode(rowsStr);

                if (rows != null) {
                  List<Map<String, dynamic>> newRows = [];
                  for (var row in rows) {
                    Map<String, dynamic> newRow = {};
                    for (var key in row.keys) {
                      var tableChildComponent = getTableComponentById(component.id, key);

                      if (tableChildComponent != null && row[key] != null) {
                        switch (tableChildComponent.type) {
                          case Strings.multiSelect:
                            newRow[tableChildComponent.id] = {
                              "text": tableChildComponent.label,
                              "value": row[key] ?? [],
                              "displayValue": defaultDropDownValues[tableChildComponent.id] ?? [],
                              "type": "MultiSelectDropDown",
                            };
                            break;
                          case Strings.chips:
                            newRow[tableChildComponent.id] = {
                              "text": tableChildComponent.label,
                              "value": List<String>.from(row[key] ?? [])
                            };
                            break;
                          case Strings.image:
                            newRow[tableChildComponent.id] = {
                              "text": tableChildComponent.label,
                              "value": row[key],
                              "type": Strings.image,
                              "format": "base64"
                            };
                            break;
                          default:
                            newRow[tableChildComponent.id] = {
                              "text": tableChildComponent.label,
                              "value": row[key].toString()
                            };
                            break;
                        }
                      }
                    }
                    if (newRow.keys.isNotEmpty) {
                      newRows.add(newRow);
                    }
                  }
                  if (newRows.isNotEmpty) {
                    tableData[component.id] = newRows;
                  }
                }
              } catch (e) {
                e.printError();
              }
              break;
            case Strings.matrix:
              if (!formValues.containsKey(component.id)) {
                formValues[component.id] = {};
              }

              for (var row in component.settings.specific.matrixRows) {
                if (!formValues[component.id].containsKey(row.id)) {
                  formValues[component.id][row.id] = [];
                }
                for (var column in component.settings.specific.matrixColumns) {
                  if (component.settings.specific.matrixTypeSettings.type == "CHECKBOX" ||
                      component.settings.specific.matrixTypeSettings.type == "RADIO") {
                    formValues[component.id][row.id].add({column.id: false});
                  }
                }
              }

              switch (component.settings.specific.matrixTypeSettings.type) {
                case "CHECKBOX":
                case "RADIO":
                case "SINGLE_SELECT":
                  var json = jsonDecode(fields[key]);

                  if (json != null &&
                      (json is List<dynamic> || json is List<Map<String, dynamic>>)) {
                    for (var row in component.settings.specific.matrixRows) {
                      formValues[component.id][row.id] = [];
                      if (json.length > component.settings.specific.matrixRows.indexOf(row)) {
                        Map<String, dynamic> rowData =
                            json[component.settings.specific.matrixRows.indexOf(row)];
                        for (var columnKey in rowData.keys) {
                          if (component.settings.specific.matrixTypeSettings.type ==
                              "SINGLE_SELECT") {
                            if (rowData[columnKey] != "") {
                              formValues[component.id][row.id].add({columnKey: rowData[columnKey]});
                            }
                          } else {
                            formValues[component.id][row.id].add({columnKey: rowData[columnKey]});
                          }
                        }
                      }
                    }
                  }
                  break;
              }

              break;
            case Strings.date:
              // Add parentDateField values
              String? parentDateField = component.settings.specific.parentDateField;

              if (parentDateField != null && parentDateField != "") {
                if (formValues.containsKey(parentDateField)) {
                  getTextEditingController(component.id).text =
                      formValues[parentDateField]["value"];
                  formValues[key] = {
                    "text": component.label,
                    "value": formValues[parentDateField]["value"]
                  };
                }
              } else {
                formValues[key] = {"text": component.label, "value": fields[key]};
              }

              break;
            default:
              getTextEditingController(key).text = fields[key];
              formValues[key] = {"text": component.label, "value": fields[key]};
              break;
          }
        }
      }
    }
  }

  void setShowAnswerIndicator() {
    var components = [];
    if (widget.tableComponentData == null) {
      for (var panel in (widget.rootData?.panels ?? [])) {
        components.addAll(panel.fields);
      }
    } else {
      components = widget.tableComponentData.settings.specific.tableColumns;
    }

    for (var component in components) {
      if (component.settings.validation.fieldRule == Strings.required &&
          component.settings.validation.answerIndicator == "YES") {
        showAnswerIndicator = true;
        totalAnswerIndicatorLevel += 1;
      }
    }
  }

  List<dynamic> getComponents() {
    var components = [];
    if (widget.tableComponentData == null) {
      for (var panel in (widget.rootData?.panels ?? [])) {
        components.addAll(panel.fields);
      }
    } else {
      components = widget.tableComponentData.settings.specific.tableColumns;
    }

    return components;
  }

  void updateAnswerIndicator() {
    int answered = 0;
    var components = getComponents();

    for (var component in components) {
      if (component.settings.validation.fieldRule == Strings.required &&
          component.settings.validation.answerIndicator == "YES") {
        if (formValues.containsKey(component.id)) {
          if (formValues[component.id]["value"] != null &&
              formValues[component.id]["value"] != "") {
            answered += 1;
          }
        }
      }
    }

    setState(() {
      answerIndicatorLevel = answered;
    });
  }

  bool isMandatoryField(String componentId) {
    var componentData = getComponentById(componentId);
    var components = getComponents();
    bool isMandatory =
        componentData != null && componentData.settings.validation.fieldRule == Strings.required;

    if (!isEnabled(componentId, true)) {
      return false;
    }

    for (var component in components) {
      List<dynamic> mandatorySettings = component.settings.validation.mandatorySettings;
      for (var mandatorySetting in mandatorySettings) {
        List<dynamic> controls = mandatorySetting['controls'];
        if (controls.contains(componentId)) {
          if (formValues.containsKey(component.id)) {
            if (formValues[component.id]["value"] == mandatorySetting['value']) {
              isMandatory = true;
            } else {
              // isMandatory = false;
            }
          } else {
            // isMandatory = false;
          }
        }
      }
    }

    return isMandatory;
  }

  bool isEnabled(String componentId, bool defaultValue) {
    if (widget.readonly != null && widget.readonly!) {
      return false;
    }

    for (var processNumberPrefix in processNumberPrefix) {
      if (processNumberPrefix["key"] == "formColumn") {
        if (processNumberPrefix["value"] == componentId) {
          return false;
        }
      }
    }

    bool enabled = defaultValue;

    var components = getComponents();
    for (var component in components) {
      List<dynamic> readonlySettings = component.settings.validation.readonlySettings;
      for (var readonlySetting in readonlySettings) {
        List<dynamic> controls = readonlySetting['controls'];
        if (controls.contains(componentId)) {
          if (formValues.containsKey(component.id)) {
            if (formValues[component.id]["value"] == readonlySetting['value']) {
              enabled = false;
            } else if (formValues[component.id]["value"] != "") {
              enabled = true;
            }
          }
        }
      }
    }

    return enabled;
  }

  void resetValueWhenReadOnly(String componentId) {
    var componentData = getComponentById(componentId);
    String widgetType = componentData.type;

    List<dynamic> readonlySettings = componentData.settings.validation.readonlySettings;
    for (var readonlySetting in readonlySettings) {
      List<dynamic> controls = readonlySetting['controls'];

      for (var control in controls) {
        if (formValues.containsKey(control)) {
          if (formValues[componentId]["value"] == readonlySetting['value']) {
            formValues.remove(control);
            getTextEditingController(control).text = "";
          }
        } else {
          if ("No" == readonlySetting['value']) {}
        }
      }
    }
  }

  List<AttachmentData> getWorkflowAttachmentData() {
    List<AttachmentData> data = [];
    for (var elm in workflowAttachmentData.values) {
      data = [...data, ...elm];
    }
    return data;
  }

  List<dynamic> getAttachmentsForField(String componentId) {
    if (formValues.containsKey(componentId)) {
      var value = formValues[componentId]["value"];
      try {
        var dataList = jsonDecode(value);
        if (dataList.length > 0) {
          return dataList;
        }
      } catch (e) {}
    }

    return [];
  }

  bool deleteAttachmentsForField(String componentId, dynamic elm) {
    if (formValues.containsKey(componentId)) {
      var value = formValues[componentId]["value"];
      try {
        List<dynamic> dataList = jsonDecode(value);
        dataList = dataList.where((data) => data["itemId"] != elm["itemId"]).toList();
        if (!deleteFiles.containsKey(componentId)) {
          deleteFiles[componentId] = [];
        }

        deleteFiles[componentId]!.add(elm);
        formValues[componentId]["value"] = jsonEncode(dataList);
        return true;
      } catch (e) {
        e.printInfo();
      }
    }

    return false;
  }

  List<dynamic> getFormUploadFieldsForSubmit(fileIds) {
    List<dynamic> formUploads = [];
    int rowid = 1; // Start rowid from 1

    for (int fileId in fileIds) {
      formUploads.add({
        "jsonId": "82axfV2rskcpDegsSpCRL",
        "fileIds": [fileId], // Assign a single fileId per entry
        "rowid": rowid
      });
      rowid++; // Increment rowid for the next file
    } // Increment for the next entry

    if (workflowAttachmentData.isNotEmpty) {
      print("Workflow attachment when upload");

      for (var key in workflowAttachmentData.keys) {
        Map<String, dynamic> elm = {};
        elm["jsonId"] = key;
        List<dynamic> fileIds = [];

        for (var file in workflowAttachmentData[key] ?? []) {
          fileIds.add(file.id);
        }

        elm["fileIds"] = fileIds;
        elm["rowid"] = rowid; // Assign and increment rowid
        rowid++;

        formUploads.add(elm);
      }
    }

    print("Form Uploads Data: $formUploads");
    return formUploads;
  }

  // List<dynamic> getFormUploadFieldsForSubmit(fileIds) {
  //   List<dynamic> formUploads = [];
  //   formUploads = [
  //     {"jsonId": "82axfV2rskcpDegsSpCRL", "fileIds": fileIds, "rowid": 1}
  //   ];
  //   if (workflowAttachmentData.isNotEmpty) {
  //     print("Workflowattchmentwhenupload");
  //
  //     for (var key in workflowAttachmentData.keys) {
  //       Map<String, dynamic> elm = {};
  //       elm["jsonId"] = key;
  //       List<dynamic> fileIds = [];
  //
  //       for (var file in workflowAttachmentData[key] ?? []) {
  //         fileIds.add(file.id);
  //       }
  //
  //       elm["fileIds"] = fileIds;
  //       formUploads.add(elm);
  //     }
  //   }
  //   print("Form Uploads Data: $formUploads");
  //   return formUploads;
  // }

  Column renderSignatureList() {
    return Column(
      children: [
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Approval Signature",
              style: TextStyle(
                  color: Colors.indigoAccent,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14),
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (var signature in signatureList)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                          width: 100,
                          child: Image.network(
                              "${EndPoint.BaseUrl}workflow/signView/1/${widget.workflowId}/${signature["id"]}")),
                      Text(
                        signature["stage"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(signature["createdByEmail"]),
                      Text(
                        Utils.getStandardDateTimeFormat(signature["createdAt"]),
                        style: const TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }

  void addFormFileforanother(dynamic componentData, String? path) async {
    if (path == null) {
      return;
    }
    setState(() {
      isFileLoading[componentData.id] = true;
    });

    List<dynamic>? assignOtherControls =
        componentData.settings.validation.assignOtherControls ?? [];
    if (assignOtherControls != null) {
      List<String> uploadForStaticMetadataFormFields = [];
      for (var elm in assignOtherControls) {
        var componentAssignControl = getComponentById(elm);
        if (componentAssignControl != null) {
          uploadForStaticMetadataFormFields
              .add(componentAssignControl.label + ", " + componentAssignControl.type);
        }
      }

      Dio.MultipartFile multiPartFile =
          await Dio.MultipartFile.fromFile(path, filename: path.split("/").last);

      List<dynamic> data = [];
      try {
        print('Uploaded data: $data');
        data = await workflowRepository.uploadForStaticMetadata(
            widget.repositoryId, multiPartFile, uploadForStaticMetadataFormFields);
        print('Uploaded data: $data');
      } catch (e) {
        print('Error: $e');
      }
      if (data.isEmpty) {
        print('No data returned from the server.');
      } else {
        print('Received data: $data');
      }

      for (var elm in assignOtherControls) {
        var componentAssignControl = getComponentById(elm);
        if (componentAssignControl != null) {
          for (var value in data) {
            if (value['name'] == componentAssignControl.label &&
                value["value"] != "Not Found" &&
                value["value"] != "Not Available") {
              switch (componentAssignControl.type) {
                case Strings.shortText:
                case Strings.longText:
                case Strings.number:
                case Strings.password:
                case Strings.calculated:
                  if (value != null && value["value"] != null) {
                    var names = value["value"];

                    if (names is List<dynamic>) {
                      names = names[0];
                    }
                    formValues[componentAssignControl.id] = {
                      "text": componentAssignControl.label,
                      "value": value["value"]
                    };
                    getTextEditingController(componentAssignControl.id).text = names;
                  }
                  break;
                case Strings.dateTime:
                case Strings.date:
                  if (value != null &&
                      value["value"] != null &&
                      DateTime.tryParse(value["value"]) != null) {
                    formValues[componentAssignControl.id] = {
                      "text": componentAssignControl.label,
                      "value": value["value"]
                    };
                    getTextEditingController(componentAssignControl.id).text = value["value"];
                  }
                  break;
                default:
                  break;
              }
            }
          }
        }
      }

      // Add to attachments
      List<Map<String, dynamic>> fileObjects = [];

      Dio.MultipartFile multiPartFileForAttachment =
          await Dio.MultipartFile.fromFile(path, filename: path.split("/").last);
      fileObjects.add({
        "file": multiPartFileForAttachment,
        "formId": formId,
        "repositoryId": widget.repositoryId,
      });
      print("formId for image:$widget.formId");
      print("File uploaded successfully:1");
      var uploadAndIndexResponse = await workflowRepository.uploadAndIndex(fileObjects);
      print("File uploaded successfully:2");
      if (uploadAndIndexResponse[0].statusCode == 200) {
        print("File uploaded successfully:3");
        var uploadAndIndexResponseData = jsonDecode(uploadAndIndexResponse[0].data);
        if (uploadAndIndexResponseData.containsKey("fileId")) {
          fileIds.add(uploadAndIndexResponseData["fileId"]);

          if (!workflowAttachmentData.containsKey(componentData.id)) {
            workflowAttachmentData[componentData.id] = [];
          }

          AttachmentData attachmentData = AttachmentData(
              uploadAndIndexResponseData["fileId"],
              path.split("/").last,
              widget.repositoryId.toString(),
              "",
              "",
              false.obs,
              sessionController.userData["email"],
              DateTime.now().toString());

          workflowAttachmentData[componentData.id]!.add(attachmentData);
          // dynamicFormController.workflowAttachmentDataFromForm.add(attachmentData);
          formValues[componentData.id] = {
            "text": componentData.label, // Component label
            "value": [{}] // Full list of attachments for the component
          };
          print("File uploaded successfully: ${workflowAttachmentData[componentData.id]}");

          // dynamicFormController.attachmentCount.value += 1;
          setState(() {
            isFileLoading[componentData.id] = false;
          });

          print("Updated workflowAttachmentData: ${workflowAttachmentData[componentData.id]}");
        } else {
          print("File upload response does not contain fileId.");
        }
      }

      if (repositoryFieldsType == "STATIC") {
        // var indexData = await Get.to(() => IndexScreen(
        //     path: path!,
        //     rootData: widget.rootData,
        //     repositoryId: widget.repositoryId,
        //     defaultValues: getFieldsByName(formValues)));
      }

      if (formFieldErrors.containsKey(componentData.id)) {
        formFieldErrors.clear();
        _validateAllFieldsManually();
      }

      setState(() {
        isFileLoading[componentData.id] = false;
      });
    }
  }

  void addFormFile(dynamic componentData) async {
    showImageSelectionSourceDialog1((String value) async {
      String? path;

      if (value == "Camera") {
        XFile? file = await _imagePicker.pickImage(source: ImageSource.camera);
        if (file != null) {
          path = file.path;
        }
      } else if (value == "Gallery") {
        XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
        if (file != null) {
          path = file.path;
        }
      } else {
        FilePickerResult? pickedFiles = await FilePicker.platform
            .pickFiles(allowMultiple: true, allowCompression: false, compressionQuality: 0);

        if (pickedFiles != null && pickedFiles.files.isNotEmpty) {
          path = pickedFiles.files[0].path;
        }
      }

      if (path == null) {
        return;
      }
      setState(() {
        isFileLoading[componentData.id] = true;
      });

      List<dynamic>? assignOtherControls =
          componentData.settings.validation.assignOtherControls ?? [];
      if (assignOtherControls != null) {
        List<String> uploadForStaticMetadataFormFields = [];
        for (var elm in assignOtherControls) {
          var componentAssignControl = getComponentById(elm);
          if (componentAssignControl != null) {
            uploadForStaticMetadataFormFields
                .add(componentAssignControl.label + ", " + componentAssignControl.type);
          }
        }

        Dio.MultipartFile multiPartFile =
            await Dio.MultipartFile.fromFile(path, filename: path.split("/").last);

        List<dynamic> data = [];
        try {
          print('Uploaded data: $data');
          data = await workflowRepository.uploadForStaticMetadata(
              widget.repositoryId, multiPartFile, uploadForStaticMetadataFormFields);
          print('Uploaded data: $data');
        } catch (e) {
          print('Error: $e');
        }
        if (data.isEmpty) {
          print('No data returned from the server.');
        } else {
          print('Received data: $data');
        }

        for (var elm in assignOtherControls) {
          var componentAssignControl = getComponentById(elm);
          if (componentAssignControl != null) {
            for (var value in data) {
              if (value['name'] == componentAssignControl.label &&
                  value["value"] != "Not Found" &&
                  value["value"] != "Not Available") {
                switch (componentAssignControl.type) {
                  case Strings.shortText:
                  case Strings.longText:
                  case Strings.number:
                  case Strings.password:
                  case Strings.calculated:
                    if (value != null && value["value"] != null) {
                      var names = value["value"];

                      if (names is List<dynamic>) {
                        names = names[0];
                      }
                      formValues[componentAssignControl.id] = {
                        "text": componentAssignControl.label,
                        "value": value["value"]
                      };
                      getTextEditingController(componentAssignControl.id).text = names;
                    }
                    break;
                  case Strings.dateTime:
                  case Strings.date:
                    if (value != null &&
                        value["value"] != null &&
                        DateTime.tryParse(value["value"]) != null) {
                      formValues[componentAssignControl.id] = {
                        "text": componentAssignControl.label,
                        "value": value["value"]
                      };
                      getTextEditingController(componentAssignControl.id).text = value["value"];
                    }
                    break;
                  default:
                    break;
                }
              }
            }
          }
        }

        // Add to attachments
        List<Map<String, dynamic>> fileObjects = [];

        Dio.MultipartFile multiPartFileForAttachment =
            await Dio.MultipartFile.fromFile(path, filename: path.split("/").last);
        fileObjects.add({
          "file": multiPartFileForAttachment,
          "formId": formId,
          "repositoryId": widget.repositoryId,
        });
        var uploadAndIndexResponse = await workflowRepository.uploadAndIndex(fileObjects);
        if (uploadAndIndexResponse[0].statusCode == 200) {
          var uploadAndIndexResponseData = jsonDecode(uploadAndIndexResponse[0].data);
          if (uploadAndIndexResponseData.containsKey("fileId")) {
            fileIds.add(uploadAndIndexResponseData["fileId"]);

            if (!workflowAttachmentData.containsKey(componentData.id)) {
              workflowAttachmentData[componentData.id] = [];
            }

            AttachmentData attachmentData = AttachmentData(
                uploadAndIndexResponseData["fileId"],
                path.split("/").last,
                widget.repositoryId.toString(),
                "",
                "",
                false.obs,
                sessionController.userData["email"],
                DateTime.now().toString());

            workflowAttachmentData[componentData.id]!.add(attachmentData);
            dynamicFormController.workflowAttachmentDataFromForm.add(attachmentData);

            dynamicFormController.attachmentCount.value += 1;
          }
        }

        if (repositoryFieldsType == "STATIC") {
          // var indexData = await Get.to(() => IndexScreen(
          //     path: path!,
          //     rootData: widget.rootData,
          //     repositoryId: widget.repositoryId,
          //     defaultValues: getFieldsByName(formValues)));
        }

        if (formFieldErrors.containsKey(componentData.id)) {
          formFieldErrors.clear();
          _validateAllFieldsManually();
        }

        setState(() {
          isFileLoading[componentData.id] = false;
        });
      }
    });
  }

  void addQrJsonResultToRow(Map<String, dynamic> result, componentData) {
    List<dynamic> columns = componentData.settings.specific.tableColumns;

    Map<String, dynamic> row = {};

    for (var column in columns) {
      if (result.containsKey(column.label)) {
        switch (column.type) {
          default:
            row[column.id] = {"text": column.label, "value": result[column.label]};
        }
      }
    }

    setState(() {
      (tableData[componentData.id] as List<dynamic>).add(row);
    });
  }

  void resetChildSelection(componentData) {
    if (parentComponentChangeEvents.containsKey(componentData.id)) {
      parentComponentChangeEvents[componentData.id]?.forEach((element) {
        dynamic childComponent = getComponentById(element);
        if (formValues.containsKey(childComponent.id)) {
          formValues.remove(childComponent.id);
        }

        if (defaultDropDownValues.containsKey(childComponent.id)) {
          defaultDropDownValues.remove(childComponent.id);
        }

        resetChildSelection(childComponent);
      });
    }
  }

  void doParentChangeEvent(componentData) {
    if (parentComponentChangeEvents.containsKey(componentData.id)) {
      resetChildSelection(componentData);
      parentComponentChangeEvents[componentData.id]?.forEach((element) {
        dynamic childComponent = getComponentById(element);

        if (childComponent == null) {
          return;
        }

        switch (childComponent.type) {
          case Strings.date:
            if (childComponent.settings.specific.parentDateField != null &&
                childComponent.settings.specific.parentDateField != "") {
              var parentDateFieldId = childComponent.settings.specific.parentDateField;
              if (!formValues.containsKey(parentDateFieldId)) return;

              var parentDateFieldValue = formValues[parentDateFieldId]["value"];

              if (parentDateFieldValue == null ||
                  parentDateFieldValue == "" ||
                  !isValidDateFormat(parentDateFieldValue)) return;

              DateTime? parentDateFieldValueDateFormat;
              try {
                DateFormat format = DateFormat('yyyy-MM-dd');
                parentDateFieldValueDateFormat = format.parse(parentDateFieldValue);
              } catch (e) {
                return;
              }

              int days = 0;
              if (childComponent.settings.specific.dateFieldOptionSettings != null) {
                List<dynamic> dateFieldOptionSettings =
                    childComponent.settings.specific.dateFieldOptionSettings;
                String? parentOptionField = childComponent.settings.specific.parentOptionField;
                if (parentOptionField != null && parentOptionField != "") {
                  if (formValues.containsKey(parentOptionField)) {
                    for (var dateFieldOptionSetting in dateFieldOptionSettings) {
                      if (dateFieldOptionSetting["option"] ==
                          formValues[parentOptionField]["value"]) {
                        days = dateFieldOptionSetting["days"];
                      }
                    }
                  }
                }
              } else if (childComponent.settings.specific.parentFieldsDays != null) {
                days = childComponent.settings.specific.parentFieldsDays;
              }

              parentDateFieldValueDateFormat =
                  parentDateFieldValueDateFormat.add(Duration(days: days));
              setState(() {
                String newDate = DateFormat("yyyy-MM-dd").format(parentDateFieldValueDateFormat!);
                formValues[childComponent.id] = {"text": childComponent.label, "value": newDate};

                getTextEditingController(childComponent.id).text = newDate;
              });
            }

            break;
          case Strings.table:
            loadDefaultFormValuesFromParentMasterColumn(element);
            break;
          default:
            if (componentData.settings.specific.optionsType == "REPOSITORY") {
              // loadDefaultUniqueColumnsValuesFromParentRepositoryField(element);
              if (childComponent.settings.specific.repositoryFieldParent == "") {
                loadDefaultUniqueColumnsRepository(childComponent.settings.specific.repositoryField,
                    childComponent.settings.specific.repositoryId, childComponent.id);
              } else {
                loadDefaultUniqueColumnsValuesFromParentRepositoryField(childComponent.id);
              }
            } else {
              loadDefaultUniqueColumnsValuesFromParentMasterColumn(element);
            }
            break;
        }
      });
    }
  }

  Widget signatureDrawer(
      GlobalKey<SfSignaturePadState> signatureKey, dynamic componentData, Function onSign) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            "Signature",
            style: Theme.of(Get.context!).textTheme.labelMedium,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (formValues.containsKey(componentData.id) &&
                    formValues[componentData.id]["value"] != "")
                  Image.memory(base64Decode(formValues[componentData.id]["value"]))
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.draw_sharp,
                      size: 75,
                      color: Colors.grey,
                    ),
                  ),
                if (formValues.containsKey(componentData.id) &&
                    formValues[componentData.id]["value"] != "")
                  IconButton(
                      onPressed: () {
                        signatureKey.currentState?.clear();
                        setState(() {
                          formValues[componentData.id] = {"text": componentData.label, "value": ""};
                        });
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                Column(
                  children: [
                    Divider(
                      height: 2,
                      color: Colors.grey.withAlpha(40),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: false,
                              isDismissible: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 436,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text("Draw your signature"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16.0, right: 16),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(8)),
                                            child: SfSignaturePad(
                                              key: signatureKey,
                                            )),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                signatureKey.currentState?.clear();
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              )),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Divider(
                                          height: 1,
                                          color: Colors.grey.withAlpha(40),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Cancel")),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              ui.Image image =
                                                  await signatureKey.currentState!.toImage();
                                              ByteData? byteData = await image.toByteData(
                                                  format: ui.ImageByteFormat.png);
                                              if (byteData != null) {
                                                Uint8List pngBytes = byteData.buffer.asUint8List();

                                                onSign(base64Encode(pngBytes));

                                                Navigator.pop(context);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 3,
                                                backgroundColor: CustomColors.ezpurple,
                                                textStyle: const TextStyle(color: Colors.white)),
                                            child: const Text(
                                              "Save",
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          child: const Text(
                            "Draw",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Text("or"),
                        TextButton(
                          onPressed: () async {
                            FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                allowMultiple: false,
                                allowCompression: true,
                                compressionQuality: 50);

                            if (pickedFiles != null) {
                              Uint8List bytes = File(pickedFiles.files[0].path!).readAsBytesSync();
                              formValues[componentData.id] = {
                                "text": componentData.label,
                                "value": base64Encode(bytes)
                              };
                              setState(() {});
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          child:
                              const Text("Upload", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const Text("your signature"),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void setValuesFromQR(Map<String, dynamic> value) {
    List<dynamic> components = getComponents();

    for (var component in components) {
      if (value.containsKey(component.label)) {
        switch (component.type) {
          case Strings.shortText:
          case Strings.longText:
          case Strings.number:
          case Strings.password:
          case Strings.calculated:
            formValues[component.id] = {"text": component.label, "value": value[component.label]};
            getTextEditingController(component.id).text = value[component.label];

            break;
          case Strings.dateTime:
          case Strings.date:
            if (value["value"] != null && DateTime.tryParse(value[component.label]) != null) {
              formValues[component.id] = {"text": component.label, "value": value[component.label]};
              getTextEditingController(component.id).text = value[component.label];
            }
            break;
          default:
            break;
        }
        doParentChangeEvent(component);
        bindCalculatedInputParentChangeEvents();
      }
    }
  }

  void showImageSelectionSourceDialog(void Function(String action) callBack) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Choose an action",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        callBack("Camera");
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                                width: 70,
                                height: 70,
                                child: Image(
                                  image: AssetImage('assets/images/icons/camera.png'),
                                )),
                            Text("Camera")
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        callBack("Gallery");
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                                width: 70,
                                height: 70,
                                child: Image(
                                  image: AssetImage('assets/images/icons/gallery.png'),
                                )),
                            Text("Gallery")
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showImageSelectionSourceDialog1(void Function(String action) callBack) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First Option: Add to Shared Album
              _buildOption(
                context,
                icon: Icons.camera_alt,
                text: 'Capture Image / File',
                onTap: () {
                  print('Capture Image / File');
                  Navigator.pop(context);
                  callBack("Camera");
                },
              ),
              Divider(
                thickness: 0.1, // Increase the line thickness
                height: 1, // Ensure compact spacing
                color: Colors.grey, // Set a visible divider color
              ),
              // Second Option: Add to Album
              _buildOption(
                context,
                icon: Icons.photo_library,
                text: 'Upload from Gallery',
                onTap: () async {
                  Navigator.pop(context);
                  callBack("Gallery");
                  // Open the gallery
                  // XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
                  //
                  // if (file != null) {
                  //   String path = file.path;
                  //   print('Gallery image selected: $path');
                  //   callBack("Gallery");
                  // } else {
                  //   print('No image selected');
                  // }
                },
              ),
              Divider(
                thickness: 0.1, // Increase the line thickness
                height: 1, // Ensure compact spacing
                color: Colors.grey, // Set a visible divider color
              ),

              _buildOption(
                context,
                icon: Icons.cloud_upload,
                text: 'Upload file',
                onTap: () {
                  callBack("File");
                  print('Upload file tapped');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomSheetContent(BuildContext context, componentData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First Option: Add to Shared Album
          _buildOption(
            context,
            icon: Icons.camera_alt,
            text: 'Capture Image',
            onTap: () {
              print('Capture Image / File');
              Navigator.pop(context);
              _pickImage("Camera", componentData);
            },
          ),
          Divider(
            thickness: 0.1, // Increase the line thickness
            height: 1, // Ensure compact spacing
            color: Colors.grey, // Set a visible divider color
          ),
          // Second Option: Add to Album
          _buildOption(
            context,
            icon: Icons.photo_library,
            text: 'Upload from Gallery',
            onTap: () {
              //_pickImage(false, componentData);
              print('Upload from Gallery');
              Navigator.pop(context);
              _pickImage("Gallery", componentData);
            },
          ),
          Divider(
            thickness: 0.1, // Increase the line thickness
            height: 1, // Ensure compact spacing
            color: Colors.grey, // Set a visible divider color
          ),
          // Third Option: AirPlay

          // Fourth Option: Use as Wallpaper
          _buildOption(
            context,
            icon: Icons.cloud_upload,
            text: 'Upload file',
            onTap: () {
              _pickImage("file", componentData);
              print('Upload file tapped');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, size: 25, color: Colors.red),
      title: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: CustomColors.ezpurple),
      ),
      onTap: onTap,
    );
  }

  Widget _buildUploadButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColors.ezpurpleLite, // Light purple background
        foregroundColor: CustomColors.ezpurple, // Purple text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Future<void> _pickImage(String value, componentData) async {
    String? path;

    if (value == "Camera") {
      XFile? file = await _imagePicker.pickImage(source: ImageSource.camera);
      if (file != null) {
        path = file.path;
      }
    } else if (value == "Gallery") {
      XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        path = file.path;
      }
    } else {
      FilePickerResult? pickedFiles = await FilePicker.platform
          .pickFiles(allowMultiple: true, allowCompression: false, compressionQuality: 0);

      if (pickedFiles != null && pickedFiles.files.isNotEmpty) {
        path = pickedFiles.files[0].path;
      }
    }
    // final image = await ImagePicker().pickImage(
    //     source: isCamera ? ImageSource.camera : ImageSource.gallery); /////////////  to be check //
    // print('pick imaged34');
    // final XFile? pickedimage = image;
    // print('pick image');
    if (path != null) {
      // Create a File object from the path
      File selectedFile = File(path);

      // Pass the File and path to the dynamic form
      _openDynamicForm(context, selectedFile, componentData, path);
    }
    // if (pickedimage != null) {
    //   print('rrrrrrr  ' + controllerfolder.sRepositiryId.toString());
    //   UploadAPICal(File(pickedimage.path), int.parse(controllerfolder.sRepositiryId.toString()));
    //   setState(() {});
    // }
    print('just select');
  }

  void _openDynamicForm(BuildContext context, File image, componentData, String path) async {
    print("Form id  Next: $formId");

    try {
      var result = await Get.to(
          () => DynamicForm(
                rootData: widget.rootData,
                tableComponentData: componentData,
                formId: formId,
                repositoryId: widget.repositoryId,
                workflowId: widget.workflowId,
                formEditAccess: widget.formEditAccess,
                formEditControls: widget.formEditControls,
                formSecureControls: widget.formSecureControls,
                //pickedImage: image,
                paths: path,
              ),
          preventDuplicates: false);
      if (result != null) {
        if (result is Map<String, dynamic> && result.containsKey("fileIds")) {
          fileIds.addAll(result["fileIds"] as List<int>);
          fileIds = fileIds.toSet().toList();
          result.remove("fileIds");
        }

        setState(() {
          (tableData[componentData.id] as List<dynamic>).add(result);
        });
      }
      print('Result from DynamicForm: $result');
    } catch (e) {
      print('Error navigating to DynamicForm: $e');
    }
  }

  void showAlert(BuildContext context, Function onNavigate) {
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
            onPressed: () {
              clear();
              Navigator.of(context).pop();
              onNavigate();
              // Get.offAll(() => Usernamelogin(
              //       title: "Username",
              //       workflowId: workflowId,
              //       settings: settings,
              //     ))
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

  void PortalWhichLoginforDefault() async {
    try {
      // Fetch data from the API
      final data = await apiHandler.fetchDetails();

      // Extract required fields
      workflow = data['workflow'] ?? '';
      workflowId = data['workflowId'] ?? 0;
      final settingsJson = data['settingsJson'] ?? '{}';

      // Decode settingsJson
      settings = jsonDecode(settingsJson);
      loginType = settings['authentication']?['loginType'] ?? '';
      MFormId = settings['authentication']?['formId'] ?? '';
      //  usernameField = settings['authentication']?['usernameField'] ?? '';
      usernameField = (settings['authentication']?['usernameField'] as List<dynamic>?)?.first ?? '';
      print('First Username Field: $usernameField');
    } catch (e) {
      print('Error: $e');
      // Optionally show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data. Please try again.')),
      );
    }
  }

  void PortalWhichLogin(String stringPage, BuildContext context) async {
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
      // Navigate to the next page with extracted data
      if (loginType == 'MASTER_LOGIN') {
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
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Phonelogin(
        //       title: 'PhoneLogin',
        //       // workflow: workflow,
        //       // workflowId: workflowId,
        //       // settings: settings,
        //     ),
        //   ),
        // );
      }
    } catch (e) {
      print('Error: $e');
      // Optionally show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data. Please try again.')),
      );
    }
  }

  void deleteAttachment(AttachmentData file) async {
    setState(() {
      //  overlayLoadingText = "Deleting . . .";
      isLoading = true;
    });

    if (widget.processId == -1 && widget.transactionId == -1) {
      // files.remove(file);
    } else {
      await workflowRepository.deleteAttachments(widget.repositoryId, 1, {
        "ids": [file.id]
      });
    }

    // if (widget.onFileRemoved != null) {
    //   widget.onFileRemoved!(file.id);
    // }

    setState(() {
      isLoading = false;
      //    overlayLoadingText = "";
    });
    dynamicFormController.attachmentCount.value -= 1;

    //   await fetchData();
  }

  Color _getTextColor(String status) {
    switch (status) {
      case "Extracted":
        return Colors.green; // Green for "Extracted"
      case "Partially":
        return Colors.yellow; // Yellow for "Partially"
      default:
        return Colors.red; // Red for anything else
    }
  }

  Color _getBorderColor(String status) {
    switch (status) {
      case "Extracted":
        return Colors.green; // Green border for "Extracted"
      case "Partially":
        return Colors.yellow; // Yellow border for "Partially"
      default:
        return Colors.red; // Red border for anything else
    }
  }
}
