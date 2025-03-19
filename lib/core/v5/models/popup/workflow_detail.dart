import 'dart:convert';

import 'package:ez/core/v5/api/auth_repo.dart';
import 'package:ez/core/v5/controllers/session_controller.dart';
import 'package:ez/core/v5/models/popup/widgetpopup/process_history.dart';
import 'package:ez/core/v5/utils/format_date_time.dart';
import 'package:ez/core/v5/utils/helper/aes_encryption.dart';
import 'package:ez/repositories/workflow_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../CustomColors.dart';
import 'package:badges/badges.dart' as badges;

import 'widgetpopup/workflow_attachments.dart';
import 'widgetpopup/workflow_comment_list.dart';
import 'widgetpopup/workflow_details_key_values.dart';

class WorkflowDetail extends StatefulWidget {
  final int workflowId;
  final int processId;
  final int? formId;
  final int transactionId;
  String? requestNo;
  String? raisedAt;
  int repositoryId;
  final bool enableEditWorkflow;
  String? activityId;

  WorkflowDetail(
      {super.key,
      required this.workflowId,
      this.formId,
      required this.processId,
      required this.transactionId,
      this.requestNo,
      this.raisedAt,
      required this.repositoryId,
      this.enableEditWorkflow = false,
      this.activityId});

  @override
  _WorkflowDetailState createState() => _WorkflowDetailState();
}

class _WorkflowDetailState extends State<WorkflowDetail> with TickerProviderStateMixin {
  late WorkflowRepository workflowRepository;
  late TabController tabController = TabController(length: 3, vsync: this);
  final sessionController = Get.find<SessionController>();

  int? commentsCount;
  int? fileCount;
  int? taskCount;
  List<dynamic> fileCheckList = [];
  Map<String, dynamic> fields = {};

  @override
  void initState() {
    workflowRepository = GetIt.instance<WorkflowRepository>();
    fetchWorkflowData();
    getCommentsDetailsCount();
    getFileDetailsCount();
    getTaskListCount();
    super.initState();
  }

  void fetchWorkflowData() async {
    Map<String, dynamic> workflowData = await workflowRepository.getWorkflowData(widget.workflowId);
    Map<String, dynamic> flowJson = json.decode(workflowData["flowJson"]);
    List<dynamic> blocks = flowJson["blocks"];
    for (var element in blocks) {
      if (element["type"] == "START" && widget.activityId == null ||
          widget.activityId != null && element["id"] == widget.activityId!) {
        fileCheckList = element["settings"]["fileSettings"]["fileCheckList"] ?? [];
      }
    }

    Map<String, dynamic> inboxItem = await workflowRepository.getInboxItem(
        widget.workflowId, widget.processId.toString(), widget.transactionId.toString());

    setState(() {
      fields = inboxItem["formData"]["fields"];
    });
  }

  void getCommentsDetailsCount() async {
    try {
      final responses =
          await AuthRepo.getCommentsList(widget.workflowId, widget.processId.toString());
      List lComments = jsonDecode(AaaEncryption.decryptAESaaa(responses.toString())) as List;
      commentsCount = lComments.length;
      setState(() {});
    } catch (e) {}
  }

  void getFileDetailsCount() async {
    try {
      final responses = await AuthRepo.getFileList(widget.workflowId, widget.processId.toString());
      List lFiles = jsonDecode(AaaEncryption.decryptAESaaa(responses.toString())) as List;
      fileCount = lFiles.length;
      setState(() {});
    } catch (e) {}
  }

  void getTaskListCount() async {
    try {
      final responses = await AuthRepo.getTaskList(
          widget.workflowId,
          widget.processId.toString(),
          jsonEncode(AaaEncryption.EncryptDatatest(jsonEncode({
            "filterBy": [
              {
                "filters": [
                  {
                    "criteria": "createdBy",
                    "condition": "IS_EQUALS_TO",
                    "value": sessionController.userData["id"]
                  }
                ]
              }
            ]
          }))));
      List lTask = jsonDecode(AaaEncryption.decryptAESaaa(responses.toString())) as List;

      taskCount = lTask.length;
      setState(() {});
    } catch (e) {}
  }

  // Future getInboxSingleDetails() async {
  //   Map<String, dynamic> formData =
  //       await workflowRepository.getFormData(widget.formId.toString());
  //   Map<String, dynamic> inboxItem = await workflowRepository.getInboxItem(
  //       widget.workflowId,
  //       widget.processId.toString(),
  //       widget.transactionId.toString());
  //   // Map<String, dynamic> mDataGenerate = <String, dynamic>{};
  //   // Map mDataGenerateForID = <String, dynamic>{};
  //   // final response =
  //   //     await AuthRepo.getInboxSingleDetails(formId.toString()); //23 formid
  //   // Map<String, dynamic> data =
  //   //     jsonDecode(AaaEncryption.decryptAESaaa(response.data));
  //   // Map<String, dynamic> datas = json.decode(data['formJson']);
  //   // datas['panels'].forEach((item) {
  //   //   for (var entry in mData.entries) {
  //   //     item['fields'].forEach((field) {
  //   //       if (entry.key.toString() == field['id']) {
  //   //         mDataGenerate.putIfAbsent(
  //   //             field['label'].toString(), () => checkIsArray(entry.value));
  //   //         mDataGenerateForID.putIfAbsent(
  //   //             field['id'], () => checkIsArray(entry.value));
  //   //       }
  //   //     });
  //   //   }
  //   // });
  //   // fields = mDataGenerate;
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Container(
            decoration: const BoxDecoration(
              color: CustomColors.white,
            ),
            width: double.infinity,
            child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                      flex: 75,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.requestNo ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ))),
                  Flexible(
                      flex: 25,
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            timeAgo(widget.raisedAt ?? ""),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15),
                          ))),
                ])),
        actions: const [],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: TabBar(
                  labelColor: CustomColors.ezpurple,
                  unselectedLabelColor: Colors.blueGrey,
                  isScrollable: false,
                  controller: tabController,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: CustomColors.eztabSelectcolor),
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
                        badgeColor: CustomColors.ezpurple,
                      ),
                      child: Icon(MdiIcons.listBoxOutline),
                    )),
                    Tab(
                        icon: badges.Badge(
                      badgeContent: fileCount == null
                          ? badgeLoader()
                          : Text(fileCount.toString(),
                              style: const TextStyle(
                                  //fontSize: 14,
                                  fontSize: 10,
                                  color: Colors.white, //#00bfd6
                                  fontWeight: FontWeight.w500)),
                      showBadge: fileCount == null || fileCount! > 0,
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: CustomColors.ezpurple,
                      ),
                      child: const Icon(Icons.attachment),
                    )),
                    Tab(
                        icon: badges.Badge(
                      badgeContent: commentsCount == null
                          ? badgeLoader()
                          : Text(commentsCount.toString(),
                              style: const TextStyle(
                                  //fontSize: 14,
                                  fontSize: 10,
                                  color: Colors.white, //#00bfd6
                                  fontWeight: FontWeight.w500)),
                      showBadge: commentsCount == null || commentsCount! > 0,
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: CustomColors.ezpurple,
                      ),
                      child: Icon(MdiIcons.commentOutline),
                    )),
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
                    //     badgeColor: CustomColors.ezpurple,
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
                    //     badgeColor: CustomColors.ezpurple,
                    //   ),
                    //   child: Icon(MdiIcons.history),
                    // )),
                  ],
                  // 9443451033
                  onTap: (index) {},
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, constraint) {
                return Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.0), bottomLeft: Radius.circular(10.0))),
                  height: constraint.maxHeight,
                  child: TabBarView(
                    controller: tabController,
                    children: <Widget>[
                      WorkflowDetailsKeyValues(
                          workflowId: widget.workflowId,
                          formId: widget.formId,
                          repositoryId: widget.repositoryId,
                          transactionId: widget.transactionId,
                          processId: widget.processId,
                          enableEditWorkflow: widget.enableEditWorkflow,
                          pageTitle: widget.requestNo ?? "",
                          activityId: widget.activityId),
                      WorkflowAttachments(
                        workflowId: widget.workflowId,
                        processId: widget.processId,
                        repositoryId: widget.repositoryId,
                        transactionId: widget.transactionId,
                        modifyData: widget.enableEditWorkflow,
                        fileCheckList: fileCheckList,
                        formFields: fields,
                      ),
                      WorkflowCommentList(
                        workflowId: widget.workflowId,
                        processId: widget.processId,
                        transactionId: widget.transactionId,
                        modifyData: widget.enableEditWorkflow,
                      ),
                      // WorkflowTaskList(
                      //     workflowId: widget.workflowId,
                      //     repositoryId: widget.repositoryId,
                      //     transactionId: widget.transactionId,
                      //     processId: widget.processId,
                      //     modifyData: widget.enableEditWorkflow),
                      // Container(
                      //     color: Colors.white,
                      //     child: ProcessHistory(
                      //       workflowId: widget.workflowId,
                      //       processId: widget.processId,
                      //     )),
                    ],
                  ),
                );
              }),
            )
          ],
        ),
      ),
      // drawer: MainDrawer(),
    );
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
}
