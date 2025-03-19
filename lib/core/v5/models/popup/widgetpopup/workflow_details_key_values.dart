import 'dart:convert';

import 'package:ez/core/ApiClient/endpoint.dart';
import 'package:ez/core/CustomColors.dart';
import 'package:ez/core/utils/strings.dart';
import 'package:ez/core/v5/controllers/session_controller.dart';
import 'package:ez/core/v5/models/popup/widgetpopup/workflow_attachments.dart';
import 'package:ez/core/v5/utils/file_fns.dart';
import 'package:ez/core/v5/utils/utils.dart';
import 'package:ez/features/dynamic_form/dynamic_form.dart';
import 'package:ez/repositories/workflow_repository.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../features/workflow/model/Panel.dart';
import '../../../controllers/treeboxlistviewcontroller.dart';

import '../../../widgets/CustomWidget.dart';
import '../../../widgets/MotionToastWidget.dart';
import 'package:flutter/material.dart';

import '../controllers/workflow_detail_controller.dart';

class WorkflowDetailsKeyValues extends StatefulWidget {
  final int workflowId;
  final int? formId;
  final int repositoryId;
  final int processId;
  final int transactionId;
  final bool enableEditWorkflow;
  final String pageTitle;
  final String? activityId;

  const WorkflowDetailsKeyValues(
      {super.key,
      required this.workflowId,
      this.formId,
      required this.repositoryId,
      required this.processId,
      required this.transactionId,
      this.enableEditWorkflow = false,
      this.pageTitle = "",
      this.activityId});

  @override //
  _WorkflowDetailsKeyValuesState createState() => _WorkflowDetailsKeyValuesState();
}

class _WorkflowDetailsKeyValuesState extends State<WorkflowDetailsKeyValues>
    with AutomaticKeepAliveClientMixin {
  final workflowDetailController = Get.put(WorkflowDetailController());
  final controllerTree = Get.put(TreeInboxListviewController());
  late WorkflowRepository workflowRepository;
  bool isLoading = false;
  Map<String, dynamic> formData = {};
  Map<String, dynamic> items = {};
  RxMap tableMatrixViewType = {}.obs;
  Map<String, dynamic> fields = {};
  List<dynamic> actionButtons = [];
  int? formEntryId;
  String initiatedBy = "";
  Map<String, dynamic> inboxItem = {};
  final sessionController = Get.find<SessionController>();
  List<dynamic> signatureList = [];
  bool? canSubmit;
  bool? isAllRequiredAttachmentAdded;
  GlobalKey keyForDynamicForm = GlobalKey();
  List<dynamic> fileCheckList = [];
  bool submitLoading = false;
  bool isInitiatedByMatching = false;
  dynamic rootData;
  List<dynamic> formSecureControls = [];
  bool isMoreOptionClicked = false;

  int _currentIndex = 0;

  List<dynamic>? tableRows = [];
  @override
  void initState() {
    workflowRepository = GetIt.instance<WorkflowRepository>();
    workflowDetailController.bFilledButton = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchFormData();
    });
    super.initState();
  }

  @override
  void dispose() {
    //_scrollController.dispose();
    // Cancel any ongoing operations or listeners
    super.dispose();
  }

  Future<void> fetchFormData() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> workflowData = await workflowRepository.getWorkflowData(widget.workflowId);
    initiatedBy = workflowData["initiatedBy"];

    String flowJsonStr = workflowData["flowJson"];
    Map<String, dynamic> flowJson = jsonDecode(flowJsonStr);

    List<dynamic> blocks = flowJson["blocks"];
    bool userSignature = false;
    for (var element in blocks) {
      if (element["type"] == "START" && widget.activityId == null ||
          widget.activityId != null && element["id"] == widget.activityId!) {
        if (element != null &&
            element["settings"] != null &&
            element["settings"]["userSignature"] != null) {
          userSignature = element["settings"]["userSignature"];
        }

        isInitiatedByMatching = Utils.isInitiatedByMatched(element);
        fileCheckList = element["settings"]["fileSettings"]["fileCheckList"] ?? [];

        formSecureControls = element["settings"]["formSecureControls"];

        if (formSecureControls.isNotEmpty && formSecureControls[0] is Map<String, dynamic>) {
          List<String> newFormSecureControls = [];
          for (var formSecureControl in formSecureControls) {
            if (formSecureControl.containsKey("user") &&
                formSecureControl["user"] == sessionController.userData["email"]) {
              newFormSecureControls = [
                ...newFormSecureControls,
                ...formSecureControl["formFields"]
              ];
            }
          }

          formSecureControls = newFormSecureControls;
        }
      }
    }

    if (userSignature) {
      signatureList =
          await workflowRepository.signWithProcessIdList(widget.workflowId, widget.processId);
    }

    inboxItem = await workflowRepository.getInboxItem(
        widget.workflowId, widget.processId.toString(), widget.transactionId.toString());

    if (initiatedBy == "DOCUMENT") {
      items = inboxItem['itemData']['items'];
    } else {
      print("formDatabefore");
      formData = await workflowRepository.getFormData(widget.formId.toString());
      print("Raw formData: $formData");
      if (formData.containsKey("formJson")) {
        final formJson = json.decode(formData['formJson'] ?? "");

        rootData = Panel.fromJson(formJson);
      }
      print("formDataafter");
      fields = inboxItem["formData"]["fields"];
      formEntryId = inboxItem["formData"]["formEntryId"];
    }

    actionButtons = inboxItem["actionButton"];

    // Check other buttons
    if (inboxItem["userReply"]) {
      actionButtons
          .add({"proceedAction": "UserReply", "custom": true, "buttonText": "Reply To START 1"});
    }

    if (inboxItem["toInitiator"]) {
      actionButtons
          .add({"proceedAction": "ToInitiator", "custom": true, "buttonText": "To Requester"});
    }

    setState(() {
      print("formDataloading");
      canSubmit = null;
      isLoading = false;
    });
  }

  List<dynamic> getRootFields() {
    var components = [];
    if (formData.containsKey("formJson")) {
      Map<String, dynamic> formJson = jsonDecode(formData["formJson"]);
      if (formJson.containsKey("panels") && formJson["panels"] is List<dynamic>) {
        for (var panel in formJson["panels"]) {
          if (panel is Map<String, dynamic>) {
            if (panel.containsKey("fields")) {
              components.addAll(panel["fields"]);
            }
          }
        }
      }
    }

    return components;
  }

  Map<String, dynamic>? getComponentById(List<dynamic> components, String componentId) {
    for (var element in components) {
      if (element is Map<String, dynamic>) {
        if (element.containsKey("id") && element["id"] == componentId) {
          return element;
        }
      }
    }

    return null;
  }

  dynamic getPanelByComponent(String componentId) {
    for (var panel in (rootData?.panels ?? [])) {
      for (var element in panel.fields) {
        if (element.id == componentId) {
          return panel;
        }
      }
    }

    return null;
  }

  bool isPanelSecured(String componentId) {
    var panel = getPanelByComponent(componentId);
    if (panel != null) {
      return formSecureControls.contains(panel.id);
    }

    return false;
  }

  bool isValueExists(Map<String, dynamic> fields, String componentId) {
    return fields.containsKey(componentId) &&
        fields[componentId] != null &&
        fields[componentId] != "";
  }

  Widget getValue(List<dynamic> components, Map<String, dynamic> fields, String componentId) {
    Map<String, dynamic>? component = getComponentById(components, componentId);
    List<dynamic> currentRows = [];
    if (component != null) {
      if (fields.containsKey(componentId)) {
        switch (component['type']) {
          case Strings.chips:
            List<dynamic>? chips = [];
            if (fields[componentId] is String) {
              chips = jsonDecode(fields[componentId]);
            } else if (fields[componentId] is List<dynamic> ||
                fields[componentId] is List<String>) {
              chips = fields[componentId];
            }
            if (chips != null) {
              return Wrap(
                children: [
                  for (var elm in chips)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Container(
                          decoration: BoxDecoration(
                              color: CustomColors.ezblue, borderRadius: BorderRadius.circular(50)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                            child: Text(
                              elm,
                              style:
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          )),
                    )
                ],
              );
            }
            break;
          case Strings.shortText:
            break;
          case Strings.textBuilder:
            return Align(
                alignment: Alignment.centerLeft,
                child: HtmlWidget(fields[componentId].toString() ?? ""));
            break;
          case Strings.image:
            if (fields[componentId].toString() != "") {
              return SizedBox(
                width: 50,
                child: Image.memory(
                  const Base64Decoder().convert(
                      fields[componentId].toString().replaceAll("data:image/png;base64,", "")),
                  fit: BoxFit.contain,
                ),
              );
            }
            return Container();
          case Strings.multiChoice:
          case Strings.multiSelect:
            List<dynamic>? chips = [];
            if (fields[componentId] is String) {
              try {
                chips = jsonDecode(fields[componentId]);
              } catch (e, s) {}
            } else if (fields[componentId] is List<dynamic> ||
                fields[componentId] is List<String>) {
              chips = fields[componentId];
            }

            return Text((chips ?? []).join(", "));
          case Strings.date:
            if (fields[componentId] != null && fields[componentId].toString().isNotEmpty) {
              return Text(Utils.getStandardDateFormat(fields[componentId].toString()));
            }
            return Text(fields[componentId].toString());
          case Strings.dateTime:
            if (fields[componentId] != null && fields[componentId].toString().isNotEmpty) {
              return Text(Utils.getStandardDateTimeFormat(fields[componentId].toString()));
            }
            return Text(fields[componentId].toString());
          case Strings.fileUpload:
            var json = [];
            try {
              // Attempt to decode the fields directly
              json = jsonDecode(fields[componentId].toString());
            } catch (e) {
              // Handle improperly formatted JSON
              String escapedInput = fields[componentId]
                  .toString()
                  .replaceAllMapped(
                      RegExp(r'(\w+):'), (match) => '"${match[1]}":') // Add quotes around keys
                  .replaceAllMapped(RegExp(r': ([^,\]}]+)'),
                      (match) => ': "${match[1]}"'); // Add quotes around values

              try {
                var dataList = jsonDecode(escapedInput);
                if (dataList.length > 0) {
                  json.addAll(dataList); // Safely append new data
                }
              } catch (_) {
                // Handle further errors silently or log them
              }
            }

            // Return the widget to display the files
            return Column(
              children: json.isNotEmpty
                  ? json
                      .map((data) => FilePreviewWidget(
                            fileUrl1: Uri.parse(
                                '${EndPoint.BaseUrl}file/view/${sessionController.userDetails.value.tenantId}/${sessionController.userDetails.value.id}/${widget.repositoryId}/${data["itemId"]}/2'),
                            fileUrl: Uri.parse(
                                '${EndPoint.BaseUrl}file/view/${sessionController.userDetails.value.tenantId}/${sessionController.userDetails.value.id}/${widget.repositoryId}/${data["itemId"]}/1'),
                            fileName: data["fileName"],
                          ))
                      .toList()
                  : [const Text('No files available.')], // Fallback message if no files
            );

          // return Column(
          //   children: [
          //     for (var data in json)
          //       Builder(
          //         builder: (context) {
          //           // Construct the file URL
          //           Uri fileUrl1 = Uri.parse(
          //               '${EndPoint.BaseUrl}file/view/${sessionController.userDetails.value.tenantId}/${sessionController.userDetails.value.id}/${widget.repositoryId}/${data["itemId"]}/1');
          //
          //           // Print the file URL before rendering the button
          //           print('File URL: $fileUrl1');
          //
          //           // Return the button widget
          //           return TextButton(
          //             style: TextButton.styleFrom(
          //               padding: EdgeInsets.zero,
          //               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //             ),
          //             onPressed: () async {
          //               // Print the URL when the button is clicked
          //               print('Button clicked. URL: $fileUrl1');
          //
          //               if (await canLaunchUrl(fileUrl1)) {
          //                 await launchUrl(fileUrl1);
          //               }
          //             },
          //             child: Row(
          //               mainAxisSize: MainAxisSize.min,
          //               children: [
          //                 // Display a preview image
          //                 Image.network(
          //                   fileUrl1.toString(),
          //                   height: 100, // Adjust the height and width as needed
          //                   width: 100,
          //                   fit: BoxFit.cover,
          //                   errorBuilder: (context, error, stackTrace) {
          //                     print('Error loading image: $error');
          //                     // Fallback widget in case of an error
          //                     return Icon(Icons.image_not_supported, color: Colors.grey);
          //                   },
          //                   loadingBuilder: (context, child, progress) {
          //                     if (progress == null) return child;
          //                     return SizedBox(
          //                       height: 40,
          //                       width: 40,
          //                       child: Center(
          //                         child: CircularProgressIndicator(
          //                           value: progress.expectedTotalBytes != null
          //                               ? progress.cumulativeBytesLoaded /
          //                                   (progress.expectedTotalBytes ?? 1)
          //                               : null,
          //                         ),
          //                       ),
          //                     );
          //                   },
          //                 ),
          //                 const SizedBox(
          //                   width: 8,
          //                 ),
          //                 Flexible(
          //                   child: Text(
          //                     data["fileName"],
          //                     overflow: TextOverflow.ellipsis,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           );
          //         },
          //       ),
          //   ],
          // );

          // case Strings.fileUpload:
          //   var json = [];
          //   try {
          //     json = jsonDecode(fields[componentId].toString());
          //   } catch (e) {}
          //   return Column(
          //     children: [
          //       for (var data in json)
          //         TextButton(
          //             style: TextButton.styleFrom(
          //               padding: EdgeInsets.zero,
          //               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //             ),
          //             onPressed: () async {
          //               Uri fileUrl = Uri.parse(
          //                   '${EndPoint.BaseUrl}file/view/${sessionController.userDetails.value.tenantId}/${sessionController.userDetails.value.id}/${widget.repositoryId}/${data["itemId"]}/2');
          //               if (await canLaunchUrl(fileUrl)) {
          //                 await launchUrl(fileUrl);
          //               }
          //             },
          //             child: Row(
          //               children: [
          //                 Image.asset(
          //                   fileIcon(data["fileName"]),
          //                   height: 20,
          //                   width: 20,
          //                 ),
          //                 const SizedBox(
          //                   width: 8,
          //                 ),
          //                 Flexible(
          //                     child: Text(
          //                   data["fileName"],
          //                   overflow: TextOverflow.ellipsis,
          //                 )),
          //               ],
          //             )),
          //     ],
          //   );
          case Strings.signature:
            if (fields[componentId].toString() != "") {
              return Image.memory(base64Decode(fields[componentId].toString()));
            }
            return const Text("-");
          case Strings.table:
            try {
              tableRows = json.decode(fields[componentId]);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {});
              });
            } on FormatException catch (e) {
              e.printError();
            }
            currentRows = tableRows!.skip(_currentIndex).take(1).toList();
            List<dynamic> components = component["settings"]["specific"]["tableColumns"];
            var listView = Align(
                alignment: Alignment.topLeft,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  for (var row in (tableRows ?? []).take(3))
                    for (var row in currentRows ?? [])
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //  mainAxisAlignment: MainAxisAlignment.start,
                        //  mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var key in row.keys)
                            Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 400,
                                      child: (getComponentById(components, key)?['label'] ?? "")
                                                  .toString()
                                                  .capitalizeFirst ==
                                              'Receipt upload'
                                          ? SizedBox
                                              .shrink() // If the label is 'Receipt upload', don't show the text
                                          : Text(
                                              (getComponentById(components, key)?['label'] ?? "")
                                                      .toString()
                                                      .capitalizeFirst ??
                                                  "",
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.left,
                                            ),
                                    ),
                                    getValue(components, row, key),
                                  ],
                                ),
                                if (row.keys.last != key)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: Colors.grey.withAlpha(80),
                                    ),
                                  )
                              ],
                            ),
                          if (tableRows!.last != row)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(height: 1, color: Colors.grey),
                            )
                        ],
                      )
                  ],
                ));

            List<TableRow> tableRowsWidget = [];

            // Add headers
            tableRowsWidget.add(
                TableRow(decoration: BoxDecoration(color: Colors.grey.withAlpha(80)), children: [
              for (var column in components)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getComponentById(components, column['id'])?['label'] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
            ]));

            for (var row in tableRows ?? []) {
              List<Widget> tableRowColumns = [];

              for (var column in components) {
                var columnAdded = false;
                for (var key in row.keys) {
                  if (key == column["id"]) {
                    columnAdded = true;
                    tableRowColumns.add(Padding(
                      padding: const EdgeInsets.all(8),
                      child: getValue(components, row, key),
                    ));
                  }
                }

                if (!columnAdded) {
                  tableRowColumns.add(const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(""),
                  ));
                }
              }

              tableRowsWidget.add(TableRow(children: tableRowColumns));
            }

            return Obx(() => !tableMatrixViewType.containsKey(component['id']) ||
                    tableMatrixViewType[component["id"]] == "LIST"
                ? listView
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      defaultColumnWidth: const FixedColumnWidth(100),
                      border: TableBorder.all(color: Colors.grey.withAlpha(80)),
                      children: tableRowsWidget,
                    )));
          case Strings.matrix:
            List<dynamic> matrixHeaderRows = component["settings"]["specific"]["matrixRows"];
            List<dynamic> matrixHeaderColumns = component["settings"]["specific"]["matrixColumns"];
            List<dynamic>? matrixRows = jsonDecode(fields[componentId]);
            List<Widget> widgets = [];
            List<Widget> tableViewWidgets = [];

            for (var rh = 0; rh < matrixHeaderRows.length; rh++) {
              if (matrixRows != null && matrixRows.length > rh) {
                Map<String, dynamic> matrixRow = matrixRows[rh];
                widgets.add(Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    matrixHeaderRows[rh]["label"]!.toString().capitalizeFirst!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ));
                for (var ch = 0; ch < matrixHeaderColumns.length; ch++) {
                  widgets.add(Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${matrixHeaderColumns[ch]["label"].toString().capitalizeFirst!} : ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (matrixRow.containsKey(matrixHeaderColumns[ch]["id"]))
                          if (matrixRow[matrixHeaderColumns[ch]["id"]] is bool)
                            Icon(
                              matrixRow[matrixHeaderColumns[ch]["id"]]
                                  ? Icons.check_outlined
                                  : Icons.close_outlined,
                              color: matrixRow[matrixHeaderColumns[ch]["id"]]
                                  ? Colors.green
                                  : Colors.red,
                            )
                          else
                            Flexible(child: Text(matrixRow[matrixHeaderColumns[ch]["id"]]))
                      ],
                    ),
                  ));
                  if (rh != matrixHeaderRows.length - 1 || ch != matrixHeaderRows.length - 1) {
                    widgets.add(Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(
                        height: 2,
                        color: Colors.grey.withAlpha(80),
                      ),
                    ));
                  }
                }
              }
            }

            List<TableRow> tableRows = [];
            // Add header
            tableRows.add(
                TableRow(decoration: BoxDecoration(color: Colors.grey.withAlpha(80)), children: [
              const Text(""),
              for (var ch = 0; ch < matrixHeaderColumns.length; ch++)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    matrixHeaderColumns[ch]["label"].toString().capitalizeFirst!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
            ]));

            for (var rh = 0; rh < matrixHeaderRows.length; rh++) {
              if (matrixRows != null && matrixRows.length > rh) {
                Map<String, dynamic> matrixRow = matrixRows[rh];

                tableRows.add(TableRow(children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.fill,
                    child: Container(
                      color: Colors.grey.withAlpha(80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            matrixHeaderRows[rh]["label"].toString().capitalizeFirst!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  for (var ch = 0; ch < matrixHeaderColumns.length; ch++)
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: matrixRow.containsKey(matrixHeaderColumns[ch]["id"])
                            ? matrixRow[matrixHeaderColumns[ch]["id"]] is bool
                                ? Icon(
                                    matrixRow[matrixHeaderColumns[ch]["id"]]
                                        ? Icons.check_outlined
                                        : Icons.close_outlined,
                                    color: matrixRow[matrixHeaderColumns[ch]["id"]]
                                        ? Colors.green
                                        : Colors.red,
                                  )
                                : Text(matrixRow[matrixHeaderColumns[ch]["id"]])
                            : const Text(""))
                ]));
              }
            }

            tableViewWidgets.add(Table(
              defaultColumnWidth: const FixedColumnWidth(100),
              border: TableBorder.all(color: Colors.grey.withAlpha(80)),
              children: tableRows,
            ));

            return Obx(() => !tableMatrixViewType.containsKey(component['id']) ||
                    tableMatrixViewType[component["id"]] == "LIST"
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widgets,
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal, child: tableViewWidgets[0]));
        }

        return Text(fields[componentId] != null ? fields[componentId].toString() : "");
      }
    }

    return Container();
  }

  // Map<String, dynamic>? getComponentById(List<dynamic> components, String componentId) {
  //   return components.firstWhere(
  //     (component) => component['id'] == componentId,
  //     orElse: () => null,
  //   );
  // }

  Widget renderItem(String componentId) {
    Map<String, dynamic>? component = getComponentById(getRootFields(), componentId);
    String? type = component?["type"];

    if (component == null) {
      return Container();
    }

    if (isPanelSecured(component["id"])) {
      return Container();
    }

    if (formSecureControls.contains(component["id"])) {
      return Container();
    }

    Widget child = Container();

    switch (type) {
      case Strings.matrix:
      case Strings.table:
        child = renderColumn(componentId);
        break;
      default:
        child = renderRow(componentId);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget getActionButtons() {
    if (!widget.enableEditWorkflow) {
      return Container();
    }

    List<Widget> widgets = [];
    for (var action in actionButtons) {
      String buttonText = action["proceedAction"];

      if (action["custom"] == true) {
        buttonText = action["buttonText"];
      }

      switch (action["proceedAction"]) {
        case 'Submit':
        case 'Ignore':
          widgets.add(ElevatedButton.icon(
            onPressed: () async {
              submitWorkflow(action["proceedAction"]);
            },
            icon: Icon(
              MdiIcons.arrowRight,
              color: CustomColors.navyblue,
            ),
            label: Text(buttonText),
          ));
          break;
        case 'Forward':
          widgets.add(ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(
              MdiIcons.arrowRight,
              color: Colors.orange,
            ),
            label: Text(buttonText),
          ));
          break;
        case 'Rightsize':
        case 'Complete':
        case 'Approve':
          widgets.add(ElevatedButton.icon(
            onPressed: () {
              submitWorkflow(action["proceedAction"]);
            },
            icon: Icon(
              MdiIcons.check,
              color: Colors.green,
            ),
            label: Text(buttonText),
          ));
          break;
        case 'Terminate':
        case 'Close':
          widgets.add(ElevatedButton.icon(
            onPressed: () {
              submitWorkflow(action["proceedAction"]);
            },
            icon: Icon(
              MdiIcons.close,
              color: Colors.redAccent,
            ),
            label: Text(buttonText),
          ));
          break;
        case 'Reject':
          widgets.add(ElevatedButton.icon(
            onPressed: () {
              submitWorkflow(action["proceedAction"]);
            },
            icon: Icon(
              MdiIcons.close,
              color: Colors.deepOrange,
            ),
            label: Text(buttonText),
          ));
          break;
        case 'Save':
          widgets.add(ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(
              MdiIcons.contentSave,
              color: Colors.lightBlue,
            ),
            label: Text(buttonText),
          ));
          break;
        default:
          widgets.add(ElevatedButton.icon(
            onPressed: () {
              submitWorkflow(action["proceedAction"]);
            },
            icon: Icon(
              MdiIcons.arrowRight,
              color: Colors.purple,
            ),
            label: Text(buttonText),
          ));
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        spacing: 16,
        children: widgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("formDatascaffold");
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      //  controller: _scrollController,
                      // physics:
                      //     // isMoreOptionClicked
                      //     //     ? const AlwaysScrollableScrollPhysics()
                      //     //     : const
                      //     NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      children: [
                        if (!isLoading && formData.isNotEmpty && canSubmit != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: getRootFields().length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                dynamic component = getRootFields()[index];
                                print("formDatarenderWidgetafteritem");
                                if (component != null && fields.containsKey(component['id'])) {
                                  if (isValueExists(fields, component['id'])) {
                                    print("formDatarenderWidget");
                                    return renderItem(component['id']);
                                  }
                                }

                                return Container();
                              },
                            ),
                          ),
                        if (!isLoading && items.isNotEmpty && canSubmit != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.keys.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Text(
                                        items.keys.elementAt(index).toString(),
                                        style: const TextStyle(
                                            color: Colors.indigoAccent,
                                            fontWeight: FontWeight.w500,
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 14),
                                      )),
                                      Expanded(
                                          child: Text(items.values.elementAt(index).toString())),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        if (signatureList.isNotEmpty)
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
                        renderSignatureList(),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: isLoading || canSubmit == null ? 30 : 0,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                children: [
                                  Expanded(
                                      child: ListTile(
                                    title: Align(
                                      alignment: Alignment.centerLeft,
                                      child: CustomWidget.rectangular(
                                        height: 16,
                                        width: MediaQuery.of(context).size.width * 0.3,
                                      ),
                                    ),
                                    // subtitle: CustomWidget.rectangular(height: 8),
                                  )),
                                  Expanded(
                                      child: ListTile(
                                    title: Align(
                                      alignment: Alignment.centerRight,
                                      child: CustomWidget.rectangular(
                                        height: 16,
                                        width: MediaQuery.of(context).size.width * 0.3,
                                      ),
                                    ),
                                    // subtitle: CustomWidget.rectangular(height: 8),
                                  ))
                                ],
                              );
                            },
                          ),
                        ),

                        // Container(
                        //     width: double.infinity,
                        //     height: 40,
                        //     margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        //     child: Center(
                        //         child: ListView.builder(
                        //             scrollDirection: Axis.horizontal,
                        //             itemCount: workflowDetailController.wButtons.length,
                        //             itemBuilder: (context, index) {
                        //               return workflowDetailController.wButtons
                        //                   .elementAt(index); //// new update by arun sir
                        //             })
                        //         //New Button Arun new design
                        //         /*ListView.builder(
                        //             scrollDirection: Axis.horizontal,
                        //             itemCount: controllerpopup.wButtonsGroup.length,
                        //             itemBuilder: (context, index) {
                        //
                        //               return controllerpopup.wButtonsGroup
                        //                   .elementAt(index); //// new update by arun sir
                        //
                        //             })*/
                        //         )),
                      ],
                    ),
                  ),
                  // if (!isMoreOptionClicked)

                  if (!isLoading && actionButtons.isNotEmpty && canSubmit != null && !submitLoading)
                    getActionButtons(),
                  if (submitLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CircularProgressIndicator()],
                      ),
                    ),
                  if (inboxItem.keys.isNotEmpty && canSubmit == null) // Temp fix for validation
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        width: 1,
                        height: 1,
                        child: DynamicForm(
                            key: keyForDynamicForm,
                            existingDataFields: fields,
                            formId: inboxItem["formData"]["formId"]!,
                            formEntryId: inboxItem['formData']['formEntryId'],
                            repositoryId: widget.repositoryId,
                            workflowId: widget.workflowId,
                            pageTitle: widget.pageTitle,
                            processId: widget.processId,
                            transactionId: widget.transactionId,
                            actionButtons: actionButtons,
                            formEditControls: inboxItem["formEditControls"],
                            formSecureControls: inboxItem["formSecureControls"],
                            formEditAccess: inboxItem["formEditAccess"],
                            activityId: widget.activityId,
                            canSubmit: (status) {
                              setState(() {
                                canSubmit = status;
                              });
                            }),
                      ),
                    )
                ],
              ),
              if (tableRows != null && tableRows!.isNotEmpty && tableRows!.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, right: 5, left: 5),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Ensures buttons are on opposite ends
                      children: [
                        // Previous Button
                        InkWell(
                          onTap: _currentIndex > 0
                              ? () {
                                  setState(() {
                                    _currentIndex--;
                                  });
                                  print("Previous button tapped!");
                                }
                              : null, // Disable the button when _currentIndex is 0
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _currentIndex > 0
                                    ? CustomColors.ezpurple
                                    : Colors.grey, // Adjust border color
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              "Previous",
                              style: TextStyle(
                                fontSize: 16,
                                color: _currentIndex > 0
                                    ? Colors.black
                                    : Colors.grey, // Adjust text color
                              ),
                            ),
                          ),
                        ),

                        // Next Button
                        InkWell(
                          onTap: _currentIndex + 1 < tableRows!.length
                              ? () {
                                  setState(() {
                                    _currentIndex++;
                                  });
                                  print("Next button tapped!");
                                }
                              : null, // Disable the button when at the end of the list
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _currentIndex + 1 < tableRows!.length
                                    ? CustomColors.ezpurple
                                    : Colors.grey, // Adjust border color
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              "Next",
                              style: TextStyle(
                                fontSize: 16,
                                color: _currentIndex + 1 < tableRows!.length
                                    ? Colors.black
                                    : Colors.grey, // Adjust text color
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          )),
      floatingActionButton: Wrap(
        //will break to another line on overflow
        direction: Axis.vertical, //use vertical to show  on vertical axis
        children: <Widget>[
          Visibility(
              visible: widget.enableEditWorkflow &&
                  initiatedBy != "DOCUMENT" &&
                  !isLoading &&
                  canSubmit != null,
              child: Container(
                  margin: const EdgeInsets.all(5),
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.blueAccent.shade200,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0))),
                    child: const Icon(color: Colors.white, Icons.edit),
                    onPressed: () async {
                      if (workflowDetailController.bIsFormBaseWorkFlow) {
                        // workflowDetailController.assignDefaultValuesFields();
                        // workflowDetailController.formFieldsValues;

                        if (widget.formId != null) {
                          var result = await Get.to(() => DynamicForm(
                              existingDataFields: fields,
                              formId: widget.formId!,
                              formEntryId: inboxItem['formData']['formEntryId'],
                              repositoryId: widget.repositoryId,
                              workflowId: widget.workflowId,
                              pageTitle: widget.pageTitle,
                              processId: widget.processId,
                              transactionId: widget.transactionId,
                              actionButtons: actionButtons,
                              formEditControls: inboxItem["formEditControls"],
                              formSecureControls: inboxItem["formSecureControls"],
                              formEditAccess: inboxItem["formEditAccess"],
                              activityId: widget.activityId));

                          if (result != null && result) {
                            // WidgetsBinding.instance.addPostFrameCallback((_) {
                            //   //   keyForDynamicForm = GlobalKey();
                            //   fetchFormData();
                            // });
                            Navigator.pop(context, true);
                          }
                        }
                      } else {
                        MotionToastWidget().displayWarningMotionToast('Will be Update', context);
                      }
                    },
                  ))),
        ],
      ),
    );
  }

  Wrap renderSignatureList() {
    return Wrap(
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
    );
  }

  Row renderRow(String componentId) {
    Map<String, dynamic>? component = getComponentById(getRootFields(), componentId);
    String? type = component?["type"];
    if (type == Strings.shortText) {
      // Get the visibility setting from component
      String? visibility = component!['settings']?['general']?['visibility'];

      // If visibility is 'DISABLED', do not display
      if (visibility == "DISABLED") {
        return Row(); // Return an empty widget
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Text(
          getComponentById(getRootFields(), componentId)?["label"] ?? "",
          style: const TextStyle(
              color: CustomColors.ezpurple,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontSize: 14),
          maxLines: 2,
        )),
        Expanded(child: getValue(getRootFields(), fields, componentId)),
      ],
    );
  }

  Widget renderColumn(String componentId) {
    var component = getComponentById(getRootFields(), componentId);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the label vertically
        // Text(
        //   component?["label"] ?? "",
        //   style: const TextStyle(
        //     color: CustomColors.ezpurple,
        //     fontWeight: FontWeight.w500,
        //     overflow: TextOverflow.ellipsis,
        //     fontSize: 20,
        //   ),
        //   maxLines: 2,
        // ),
        //  const SizedBox(height: 10), // Add spacing between elements
        // Render the value below the label
        getValue(getRootFields(), fields, componentId),
      ],
    );
  }

  // Widget renderColumn(String componentId) {
  //   var component = getComponentById(getRootFields(), componentId);
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             component?["label"] ?? "",
  //             style: const TextStyle(
  //                 color: CustomColors.ezpurple,
  //                 fontWeight: FontWeight.w500,
  //                 overflow: TextOverflow.ellipsis,
  //                 fontSize: 14),
  //             maxLines: 2,
  //           ),
  //           Obx(() => IconButton(
  //               onPressed: () {
  //                 if (component != null) {
  //                   if (tableMatrixViewType[component["id"]] == "TABLE") {
  //                     tableMatrixViewType[component["id"]] = "LIST";
  //                   } else {
  //                     tableMatrixViewType[component["id"]] = "TABLE";
  //                   }
  //                 }
  //
  //                 tableMatrixViewType = {...tableMatrixViewType}.obs;
  //               },
  //               icon: tableMatrixViewType[component?["id"]] == "TABLE"
  //                   ? const Icon(Icons.list_outlined)
  //                   : const Icon(Icons.table_view_outlined)))
  //         ],
  //       ),
  //       // const VerticalDivider(width: 10.0),
  //       getValue(getRootFields(), fields, componentId),
  //     ],
  //   );
  // }

  Future<void> submitWorkflow(String action) async {
    if (canSubmit != null && !canSubmit!) {
      Fluttertoast.showToast(
          msg: "Required Mandatory Info", backgroundColor: Colors.red, textColor: Colors.white);
      return;
    }

    if (canSubmit == null) {
      return;
    }

    setState(() {
      submitLoading = true;
    });

    bool isAllFileAttached = await WorkflowAttachments.isAllRequiredFilesAdded(
        widget.workflowId, widget.transactionId, widget.processId, fileCheckList, fields);

    if (!isAllFileAttached) {
      setState(() {
        submitLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Upload required documents.", backgroundColor: Colors.red, textColor: Colors.white);
      return;
    }

    SVProgressHUD.show();
    Map<String, dynamic> request = {
      "workflowId": widget.workflowId,
      "transactionId": widget.transactionId,
      "review": action,
      "formData": {
        "formId": widget.formId,
        "formEntryId": formEntryId,
        "fields": fields,
      },
      "userIds": [],
      "groupIds": []
    };
    var response = await workflowRepository.submitWorkflowForm(request);
    SVProgressHUD.dismiss();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      content: Text(
        response["requestNo"] +
            (request["review"] != "" ? " Request Processed" : " Request Initiated."),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    ));

    setState(() {
      submitLoading = false;
    });

    Get.back(result: true);
  }

  @override
  bool get wantKeepAlive => true;
}

class FilePreviewWidget extends StatelessWidget {
  final Uri fileUrl;
  final String fileName;
  final Uri fileUrl1;

  const FilePreviewWidget(
      {Key? key, required this.fileUrl, required this.fileName, required this.fileUrl1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('File URL: $fileUrl');

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              print('Stack clicked. URL: $fileUrl1');
              if (await canLaunchUrl(fileUrl1)) {
                await launchUrl(fileUrl1);
              }
            },
            child: Stack(
              children: [
                // Image widget
                Image.network(
                  fileUrl.toString(),
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: 250,
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
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
                              print('Button clicked. URL: $fileUrl1');
                              if (await canLaunchUrl(fileUrl1)) {
                                await launchUrl(fileUrl1);
                              }
                            },
                            child: Text(
                              fileName,
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
            ),
          ),
        ],
      ),
    );
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
