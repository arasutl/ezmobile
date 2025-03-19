import 'dart:convert';
import 'package:ez/controllers/dynamic_form_controller.dart';
import 'package:ez/core/ApiClient/ApiHandler.dart';
import 'package:ez/core/CustomColors.dart';
import 'package:ez/core/v5/api/auth_repo.dart';
import 'package:ez/core/v5/controllers/dashmaincontroller.dart';
import 'package:ez/core/v5/controllers/session_controller.dart';
import 'package:ez/core/v5/models/popup/widgetpopup/process_history.dart';
import 'package:ez/core/v5/models/popup/widgetpopup/workflow_attachments.dart';
import 'package:ez/core/v5/models/popup/widgetpopup/workflow_comment_list.dart';
import 'package:ez/core/v5/models/popup/workflow_detail.dart';
import 'package:ez/core/v5/utils/InboxDetails.dart';
import 'package:ez/core/v5/utils/format_date_time.dart';
import 'package:ez/core/v5/widgets/load_more_widget.dart';
import 'package:ez/features/dashboard/model/workflow_section_data.dart';
import 'package:ez/features/dynamic_form/dynamic_form.dart';
import 'package:ez/widgets/editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/v5/utils/helper/aes_encryption.dart';
import '../core/v5/widgets/CustomWidget.dart';

import 'package:badges/badges.dart' as badges;

import 'UsernameLogin.dart';

class WorkflowList extends StatefulWidget {
  int sWorkflowId;
  int sType = -1;
  String sProcessId = '';
  final bool enableEditWorkflow;

  WorkflowList({
    super.key,
    required this.sWorkflowId,
    required this.sType,
    this.enableEditWorkflow = false,
  });

  @override
  WorkflowListState createState() => WorkflowListState();
}

class WorkflowListState extends State<WorkflowList> {
  List<InboxDetails> _inboxDetails = [];
  List<InboxDetails> _inboxDetailsTemp = [];

  // final controllerPopup = Get.put(WorkflowDetailController());
  final dbController = Get.put(WorkflowRootController());
  // final controllerSession = Get.find<SessionController>();
  // final controller = Get.put(TreeInboxListviewController());
  // final controllerPanel = Get.put(PanelController());
  final dynamicFormController = Get.put(DynamicFormController());
  final ScrollController _controller = ScrollController();
  final store = GetStorage();
  String workflow = '';
  int workflowId = 0;
  Map<String, dynamic> settings = {};
  final isLoading = true.obs;
  String sUserId = '';
  int iCurrentPage = 0;
  int iListCountPerPage = 10;
  bool _showFab = true;
  bool isAllItemsLoaded = false;
  final sessionController = Get.find<SessionController>();

  final apiHandler = ApiHandler();
  Future<bool> getInboxDetailsNew() async {
    iCurrentPage = ++iCurrentPage;

    String payloadEnc = jsonEncode({
      "currentPage": iCurrentPage.toString(),
      "itemsPerPage": iListCountPerPage.toString(),
    });

    // Encrypt the payload
    String encryptedPayload = jsonEncode(AaaEncryption.EncryptDatatest(payloadEnc));

    // Initialize a temporary list to hold all results
    List<InboxDetails> tempInboxDetails = [];

    // Fetch `processList` (sType = 1)
    final processResponse =
        await AuthRepo.getInboxListForFolder(widget.sWorkflowId, encryptedPayload, 1);

    final processDecoded = AaaEncryption.decryptAESaaa(processResponse.toString());
    Map<String, dynamic> processValueMap = json.decode(processDecoded);

    processValueMap['data'].forEach((item) {
      item['value'].forEach((items) {
        tempInboxDetails.add(InboxDetails.fromJson(items));
      });
    });

    // Fetch `completedList` (sType = 3)
    final completedResponse =
        await AuthRepo.getInboxListForFolder(widget.sWorkflowId, encryptedPayload, 3);

    final completedDecoded = AaaEncryption.decryptAESaaa(completedResponse.toString());
    Map<String, dynamic> completedValueMap = json.decode(completedDecoded);

    completedValueMap['data'].forEach((item) {
      item['value'].forEach((items) {
        tempInboxDetails.add(InboxDetails.fromJson(items));
      });
    });

    // Update state
    if (tempInboxDetails.isEmpty || tempInboxDetails.length < iListCountPerPage) {
      isAllItemsLoaded = true;
    }

    if (mounted) {
      _inboxDetails.addAll(tempInboxDetails);
      setState(() {
        isLoading.value = false;
      });
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _inboxDetails = [];
    _inboxDetailsTemp = [];
    iCurrentPage = 0;
    // controllerPopup.sWorkFlowId = widget.sWorkflowId.toString();
    dbController.iCurrentSelect = 'listview'.obs;
    getInboxDetailsNew();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _pullRefresh,
        color: CustomColors.ezpurple,
        child: Scaffold(
          backgroundColor: Colors.white,
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
                        children: [
                          TextButton(
                              onPressed: () async {
                                Get.to(DynamicForm(
                                    formId: 2, repositoryId: 1, workflowId: widget.sWorkflowId));
                                print("Button Pressed!");
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
                                "Form",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: CustomColors.ezpurple,
                                  fontWeight: FontWeight.w300, // Medium (use w400 for Regular)
                                  //  fontSize: 16, // Optional text styling
                                ),
                              )),
                          // SizedBox(
                          //   height: 30,
                          //   // width: 120,
                          //   // width: 100,
                          //   child: ElevatedButton(
                          //     onPressed: () {
                          //       Get.to(DynamicForm(formId: 2, repositoryId: 1, workflowId: 1));
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
                          //       "Start Page",
                          //       style: TextStyle(
                          //         color: CustomColors.white, // Set text color to white
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.all(5.0),
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       Get.to(DynamicForm(formId: 2, repositoryId: 1, workflowId: 1));
                          //       // Add your logout functionality here
                          //       print("Logout tapped");
                          //     },
                          //     child: Icon(
                          //       MdiIcons.starThreePointsOutline, // Logout icon
                          //       color: Colors.black,
                          //       size: 20, // Icon color
                          //     ),
                          //   ),
                          // ),
                          SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: GestureDetector(
                              onTap: () {
                                showAlert(context, () => PortalWhichLogin("Track", context));
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
          // floatingActionButton: widget.enableInitiateWorkflow
          //     ? AnimatedSlide(
          //         duration: const Duration(milliseconds: 300),
          //         offset: _showFab ? Offset.zero : const Offset(0, 2),
          //         child: AnimatedOpacity(
          //           duration: const Duration(milliseconds: 300),
          //           opacity: _showFab ? 1 : 0,
          //           child: FloatingActionButton.extended(
          //             backgroundColor: Colors.blueAccent.shade200,
          //             shape: const RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.all(Radius.circular(30.0))),
          //             label: const Text('Initiate'),
          //             icon: const Icon(Icons.start),
          //             onPressed: () async {
          //               var reload = await Get.to(() => DynamicForm(
          //                   pageTitle: widget.miSelectedData.name,
          //                   formId: widget.miSelectedData.wFormId!,
          //                   repositoryId: widget.miSelectedData.repositoryId!,
          //                   workflowId: widget.sWorkflowId));
          //
          //               if (reload != null && reload) {
          //                 _pullRefresh();
          //               }
          //             },
          //           ),
          //         ),
          //       )
          //     : Container(),
          body: Obx(() => isLoading.value
              ? ListView.builder(
                  controller: _controller,
                  shrinkWrap: true,
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: ListTile(
                          leading: const CustomWidget.circular(height: 64, width: 64),
                          title: Align(
                            alignment: Alignment.centerLeft,
                            child: CustomWidget.rectangular(
                              height: 16,
                              width: MediaQuery.of(context).size.width * 0.3,
                            ),
                          ),
                          subtitle: CustomWidget.rectangular(height: 14),
                        ));
                  },
                )
              : NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    final ScrollDirection direction = notification.direction;
                    setState(() {
                      if (direction == ScrollDirection.reverse) {
                        _showFab = false;
                      } else if (direction == ScrollDirection.forward) {
                        _showFab = true;
                      }
                    });
                    return true;
                  },
                  child: loadListview(context))),
        ));
  }

  Widget getListTile(InboxDetails inboxDetails, {subTicket = false}) {
    int workflowId = widget.sWorkflowId;
    int repositoryId = 1;
    int processId = inboxDetails.processId;
    int transactionId = inboxDetails.transactionId;
    String requestNo = inboxDetails.requestNo;

    return Container(
      decoration: BoxDecoration(
          color: subTicket ? CustomColors.ezpurpleLite : CustomColors.ezpurpleLite,
          borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: () async {
          var reload = await Get.to(() => WorkflowDetail(
              workflowId: widget.sWorkflowId,
              processId: inboxDetails.processId,
              formId: inboxDetails.formId,
              transactionId: inboxDetails.transactionId,
              requestNo: inboxDetails.requestNo,
              raisedAt: inboxDetails.raisedAt,
              repositoryId: 1,
              enableEditWorkflow: subTicket == false && widget.enableEditWorkflow,
              activityId: inboxDetails.activityId));
          if (reload != null && reload) {
            _pullRefresh();
          }
        },
        contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                      child: subTicket
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(
                                Icons.history,
                                color: CustomColors.greyblue,
                              ),
                            )
                          : IconButton(
                              color: CustomColors.sapphireBlue,
                              icon: const Icon(Icons.star_border_outlined,
                                  color: CustomColors.greyblue),
                              onPressed: () => {},
                            )),
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(inboxDetails.requestNo.replaceAll('"', ''),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                            Row(children: [
                              Expanded(
                                child: Text(inboxDetails.stage,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300)),
                              )
                            ]),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      textAlign: TextAlign.end,
                      timeAgo(inboxDetails.transaction_createdAt.trim()),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w300)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // IconButton(
                    //     tooltip: "History",
                    //     onPressed: () {
                    //       showModalBottomSheet<void>(
                    //         context: context,
                    //         isScrollControlled: true,
                    //         isDismissible: true,
                    //         shape: const RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                    //         ),
                    //         clipBehavior: Clip.antiAliasWithSaveLayer,
                    //         builder: (BuildContext context) {
                    //           return DraggableScrollableSheet(
                    //               expand: false,
                    //               initialChildSize: 0.7,
                    //               maxChildSize: 0.9,
                    //               minChildSize: .7,
                    //               snap: true,
                    //               snapSizes: const [0.7],
                    //               builder: (context, controller) {
                    //                 return ProcessHistory(
                    //                     workflowId: workflowId,
                    //                     processId: processId,
                    //                     title: "Process History - ($requestNo)");
                    //               });
                    //         },
                    //       );
                    //     },
                    //     icon: const Icon(
                    //       Icons.history_outlined,
                    //       color: CustomColors.ezpurple,
                    //     )),
                    IconButton(
                      tooltip: "Attachment",
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          builder: (BuildContext context) {
                            return Builder(builder: (context) {
                              dynamicFormController.workflowAttachmentBottomModelSheetContext =
                                  context;

                              return DraggableScrollableSheet(
                                  expand: false,
                                  initialChildSize: 0.7,
                                  maxChildSize: 0.9,
                                  minChildSize: .7,
                                  snap: true,
                                  snapSizes: const [0.7],
                                  builder: (context, controller) {
                                    return WorkflowAttachments(
                                        workflowId: workflowId,
                                        repositoryId: repositoryId,
                                        processId: processId,
                                        transactionId: transactionId,
                                        title: "Attachments ($requestNo)",
                                        modifyData: subTicket == false && widget.enableEditWorkflow,
                                        bottomSheetContext: context);
                                  });
                            });
                          },
                        );
                      },
                      icon: badges.Badge(
                          badgeContent: Text(inboxDetails.attachmentCount.toString(),
                              style: const TextStyle(
                                  //fontSize: 14,
                                  fontSize: 10,
                                  color: Colors.white, //#00bfd6
                                  fontWeight: FontWeight.w500)),
                          showBadge: inboxDetails.attachmentCount > 0,
                          badgeStyle: const badges.BadgeStyle(badgeColor: CustomColors.ezpurple),
                          child: const Icon(
                            Icons.attachment_outlined,
                            color: CustomColors.ezpurple,
                          )),
                    ),
                    IconButton(
                      tooltip: "Comments",
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          builder: (BuildContext context) {
                            return DraggableScrollableSheet(
                                expand: false,
                                initialChildSize: 0.7,
                                maxChildSize: 0.9,
                                minChildSize: .7,
                                snap: true,
                                snapSizes: const [0.7],
                                builder: (context, controller) {
                                  return WorkflowCommentList(
                                    workflowId: workflowId,
                                    processId: processId,
                                    transactionId: transactionId,
                                    title: "Comments ($requestNo)",
                                    scrollController: controller,
                                    modifyData: subTicket == false && widget.enableEditWorkflow,
                                  );
                                });
                          },
                        );
                      },
                      icon: badges.Badge(
                          badgeContent: Text(inboxDetails.commentsCount.toString(),
                              style: const TextStyle(
                                  //fontSize: 14,
                                  fontSize: 10,
                                  color: Colors.white, //#00bfd6
                                  fontWeight: FontWeight.w500)),
                          showBadge: inboxDetails.commentsCount > 0,
                          badgeStyle: const badges.BadgeStyle(
                            badgeColor: CustomColors.ezpurple,
                          ),
                          child: const Icon(
                            Icons.comment_outlined,
                            color: CustomColors.ezpurple,
                          )),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget loadListview(BuildContext context) {
    // controllerPanel.sFormId = widget.miSelectedData.wFormId;
    // controllerPopup.sFormId = widget.miSelectedData.wFormId;

    // controllerPanel.repositoryId = widget.miSelectedData.repositoryId;
    // controllerPopup.repositoryId = widget.miSelectedData.repositoryId;

    return LoadMore(
      onLoadMore: getInboxDetailsNew,
      isFinish: isAllItemsLoaded,
      whenEmptyLoad: true,
      delegate: const DefaultLoadMoreDelegate(),
      textBuilder: DefaultLoadMoreTextBuilder.english,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _inboxDetails.length,
        itemBuilder: (context, index) {
          InboxDetails inboxDetails = _inboxDetails.elementAt(index);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                child: ListTileTheme(
                    // tileColor: Colors.white,
                    style: ListTileStyle.list,
                    child: getListTile(inboxDetails)),
              ),
              if ((inboxDetails.subWorkflowTransactions?.length ?? 0) > 0)
                for (InboxDetails a in inboxDetails.subWorkflowTransactions ?? [])
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, right: 8, top: 4, bottom: 4),
                    child: ListTileTheme(
                        style: ListTileStyle.list, child: getListTile(a, subTicket: true)),
                  ),
            ],
          );

          // return Container(
          //     margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          //     child: ListTile(
          //       onTap: () async {
          //         InboxDetails inboxDetails = _inboxDetails.elementAt(index);
          //         controllerPopup.iSelectedIndex = index;
          //         controllerPopup.sRaisedAt = inboxDetails.raisedAt;
          //         controllerPopup.transaction_createdAt =
          //             _inboxDetails.elementAt(index).transaction_createdAt;
          //         controllerPopup.srequesno =
          //             _inboxDetails.elementAt(index).requestNo;
          //         controllerPopup.sFormId =
          //             _inboxDetails.elementAt(index).formEntryId.toString();
          //         controllerPopup.sFormEntryId =
          //             _inboxDetails.elementAt(index).formEntryId.toString();
          //         controllerPopup.sProcessId =
          //             _inboxDetails.elementAt(index).processId.toString();
          //         controllerPopup.sActivityId =
          //             _inboxDetails.elementAt(index).activityId.toString();
          //         controllerPopup.sTransactionId =
          //             _inboxDetails.elementAt(index).transactionId.toString();
          //         controllerPopup.inboxDetails = _inboxDetails.elementAt(index);
          //         controllerPopup.mFormJSon =
          //             jsonDecode(jsonDecode(widget.miSelectedData.flowJson));
          //         //
          //         var response = await Get.to(() => WorkflowDetail(
          //               workflowId: widget.sWorkflowId,
          //               processId: inboxDetails.processId,
          //               formId: inboxDetails.formId,
          //               transactionId: inboxDetails.transactionId,
          //               requestNo: inboxDetails.requestNo,
          //               raisedAt: inboxDetails.raisedAt,
          //             ));
          //         print(response);
          //         // openPopupForm();
          //       },
          //       title: Row(
          //         mainAxisSize: MainAxisSize.max,
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Expanded(
          //               flex: 12,
          //               child: Container(
          //                   alignment: Alignment.topLeft,
          //                   margin: const EdgeInsets.all(2),
          //                   child: ClipOval(
          //                     child: SizedBox.fromSize(
          //                       size: const Size.fromRadius(15), // Image radius
          //                       child: Image.asset(
          //                           'assets/images/logo/user/user.png',
          //                           fit: BoxFit.fill),
          //                     ),
          //                   ))),
          //           Expanded(
          //               flex: 80,
          //               child: Container(
          //                   padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          //                   child: Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     mainAxisSize: MainAxisSize.max,
          //                     children: [
          //                       //141  55,16,16
          //                       // name
          //                       Text(_inboxDetails[index].requestNo,
          //                           overflow: TextOverflow.ellipsis,
          //                           style: _inboxDetails[index].bread
          //                               ? const TextStyle(
          //                                   color: Colors.black87,
          //                                   fontSize: 18,
          //                                   fontWeight: FontWeight.w300)
          //                               : const TextStyle(
          //                                   color: Colors.black87,
          //                                   fontSize: 21,
          //                                   fontWeight: FontWeight.w600)),
          //                       Text(_inboxDetails[index].stage,
          //                           overflow: TextOverflow.ellipsis,
          //                           style: _inboxDetails[index].bread
          //                               ? const TextStyle(
          //                                   color: Colors.black87,
          //                                   fontSize: 18,
          //                                   fontWeight: FontWeight.w300)
          //                               : const TextStyle(
          //                                   color: Colors.black87,
          //                                   fontSize: 18,
          //                                   fontWeight: FontWeight.w600)),
          //                       Text(
          //                           _inboxDetails[index].lastAction.toString() ==
          //                                   'null'
          //                               ? '-'
          //                               : 'Last Action : ${_inboxDetails[index].lastAction}',
          //                           overflow: TextOverflow.ellipsis,
          //                           style: const TextStyle(
          //                               color: Colors.black87,
          //                               fontSize: 18,
          //                               fontWeight: FontWeight.w300)),
          //                     ],
          //                   ))),
          //           Expanded(
          //               flex: 20,
          //               child: Container(
          //                   padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
          //                   child: Text(
          //                       textAlign: TextAlign.end,
          //                       timeFormate(_inboxDetails[index]
          //                           .transaction_createdAt
          //                           .trim()),
          //                       overflow: TextOverflow.ellipsis,
          //                       style: _inboxDetails[index].bread
          //                           ? const TextStyle(
          //                               color: Colors.black87,
          //                               fontSize: 18,
          //                               fontWeight: FontWeight.w300)
          //                           : const TextStyle(
          //                               color: Colors.black87,
          //                               fontSize: 21,
          //                               fontWeight: FontWeight.w600))))
          //         ],
          //       ),
          //     ));
        },
      ),
    );
  }

  Future<void> _pullRefresh() async {
    iCurrentPage = 0;
    isLoading.value = true;
    _inboxDetails.clear();
    isAllItemsLoaded = false;
    await getInboxDetailsNew();
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

  // CheckFabDisplay(String sUserid) {
  //   final RegExp r = RegExp(r'\\\\u([0-9a-fa-f]+)');
  //   //4947
  //   String sTemp = widget.miSelectedData.flowJson.toString();
  //   sTemp = sTemp.replaceAllMapped(r, (Match m) {
  //     // extract the parenthesised hex string. '\\u0123' -> '123'.
  //     final String? hexstring = m.group(1);
  //     // parse the hex string to an int.
  //     final int codepoint = int.parse(hexstring!, radix: 16);
  //     // convert codepoint to string.
  //     return String.fromCharCode(codepoint);
  //   });
  //
  //   sTemp =
  //       sTemp.replaceAll('\\r', "").replaceAll('\\n', "").replaceAll('\\', "");
  //
  //   var replaceStr = sTemp.replaceAll('="#', '=');
  //   replaceStr = replaceStr.replaceAll('#"', '');
  //
  //   replaceStr = replaceStr.replaceAll('"{"', '[{"');
  //   replaceStr = replaceStr.replaceAll('}"', '}]');
  //
  //   replaceStr = replaceStr.replaceAll(':"[{', ':[{');
  //   replaceStr = replaceStr.replaceAll('}]"', '}]');
  //
  //   RegExp pattern = RegExp(r'<p>.*?</p>');
  //   replaceStr = replaceStr.replaceAll(pattern, '');
  //
  //   Map<String, dynamic> mFJ =
  //       jsonDecode(replaceStr.substring(1, replaceStr.length - 1));
  //
  //   controllerPopup.bFab = false;
  //   for (int i = 0; i < mFJ['blocks'].length; i++) {
  //     // findBlockId(mFJ['blocks'][i]['settings'], mFJ['blocks'][i]['id']);
  //     if (mFJ['blocks'][i]['type'] == 'START') {
  //       List<dynamic> slist = mFJ['blocks'][i]['settings']['users'];
  //       for (int j = 0; j < slist.length; j++) {
  //         if (slist[j].toString() == sUserid) {
  //           setState(() {
  //             controllerPopup.bFab = true;
  //           });
  //         }
  //       }
  //     }
  //   }
  // }
  //
  // openForm() {
  //   // controllerPanel.sFormId = widget.miSelectedData.wFormId;
  //   // controllerPanel.repositoryId = widget.miSelectedData.repositoryId;
  //   // List<String> buttonList = Utils.getActionButtonList(widget.miSelectedData);
  //   // controllerPanel.formbuttonList = buttonList;
  //   Get.to(() => DynamicForm(
  //       formId: widget.miSelectedData.wFormId!,
  //       repositoryId: widget.miSelectedData.repositoryId!,
  //       workflowId: widget.sWorkflowId));
  // }

  // findUserGroupsList(String dd) {
  //   final responseMap = jsonDecode(AaaEncryption.decryptAESaaa(dd));
  //   final infoList = responseMap['groups'];
  //   controllerPanel.userGroupList = infoList.map((info) => info['id']).toList();
  // }
  //
  // findBlockId(var auserList, String sBlockId) {
  //   bool bpresent = false;
  //   bpresent = auserList['users'].contains(sUserId);
  //   if (!bpresent && auserList['groups'].length > 0 && controllerPanel.userGroupList.isNotEmpty) {
  //     for (int i = 0; i < auserList['groups'].length; i++) {
  //       bpresent = controllerPanel.userGroupList.contains(auserList['groups'][i].toString());
  //       if (bpresent) break;
  //     }
  //   }
  //
  //   if (bpresent) {
  //   } else {}
  // }
}
