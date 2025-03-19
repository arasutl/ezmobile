import 'dart:convert';

import 'package:ez/controllers/dynamic_form_controller.dart';
import 'package:ez/core/CustomColors.dart';
import 'package:ez/core/v5/controllers/session_controller.dart';
import 'package:ez/core/v5/utils/format_date_time.dart';
import 'package:ez/core/v5/widgets/CustomWidget.dart';
import 'package:ez/repositories/workflow_repository.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../api/auth_repo.dart';
import '../../../controllers/treeboxlistviewcontroller.dart';
import '../../../utils/helper/aes_encryption.dart';
import '../../comments.dart';
import '../controllers/commentcontroller.dart';
import '../controllers/workflow_detail_controller.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';

class WorkflowCommentList extends StatefulWidget {
  final int workflowId;
  final int processId;
  final int transactionId;
  final String? title;
  final bool modifyData;
  final ScrollController? scrollController;
  final Function(String comment)? onCommentsAdded;

  const WorkflowCommentList(
      {super.key,
      required this.workflowId,
      required this.processId,
      required this.transactionId,
      this.title,
      this.scrollController,
      this.modifyData = false,
      this.onCommentsAdded});

  @override //
  _WorkflowCommentListState createState() => _WorkflowCommentListState();
}

class _WorkflowCommentListState extends State<WorkflowCommentList>
    with AutomaticKeepAliveClientMixin {
  late WorkflowRepository workflowRepository;
  List<WorkflowCommentsData> workflowCommentsData = [];
  late SessionController sessionController;

  bool isLoading = false;
  bool isInternal = true;

  TextEditingController commentTextController = TextEditingController();

  CommentController controllerComments = Get.put(CommentController());
  final controllerTree = Get.put(TreeInboxListviewController());
  final controllerpopup = Get.put(WorkflowDetailController());
  final ScrollController _scrollController = ScrollController();
  final DynamicFormController dynamicFormController = Get.put(DynamicFormController());

  final bool _needsScroll = false;
  int iSelectedFileCount = 0;

  //dynamic showTO = 1;
  String sPostJsonComments = '';
  bool bResponse = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    workflowRepository = GetIt.instance<WorkflowRepository>();
    sessionController = Get.put(SessionController());

    getCommentsDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    super.initState();
  }

  Future<void> getCommentsDetails() async {
    if (widget.workflowId == -1 || widget.processId == -1) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    workflowCommentsData =
        await workflowRepository.workflowComments(widget.workflowId, widget.processId);

    dynamicFormController.commentsCount.value = workflowCommentsData.length;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              if (widget.title != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.title!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Divider(
                      height: 2,
                      color: Colors.grey.withAlpha(80),
                    )
                  ],
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: getCommentsDetails,
                  child: !isLoading && workflowCommentsData.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Start a conversation, spark a connection.\nChat now!",
                              textAlign: TextAlign.center,
                            )
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: widget.scrollController ?? _scrollController,
                          reverse: !isLoading,
                          itemCount: isLoading ? 20 : workflowCommentsData.length,
                          itemBuilder: (context, index) {
                            if (isLoading) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CustomWidget.rectangular(
                                  height: 70,
                                  width: MediaQuery.of(context).size.width * 0.3,
                                ),
                              );
                            }

                            WorkflowCommentsData item =
                                workflowCommentsData.reversed.elementAt(index);
                            return ListTile(
                                title: Container(
                              margin: const EdgeInsets.all(0),
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
                              child: Row(
                                  mainAxisAlignment:
                                      item.sCreatedBy == sessionController.userid.value
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                  children: [
                                    if (item.sCreatedBy == sessionController.userid.value)
                                      Column(
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.all(5),
                                              constraints: BoxConstraints(
                                                  minWidth: 70,
                                                  maxWidth:
                                                      MediaQuery.of(context).size.width * 0.75),
                                              decoration: const BoxDecoration(
                                                  color: CustomColors.lightpink,
                                                  borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(10.0),
                                                      topLeft: Radius.circular(10.0),
                                                      bottomLeft: Radius.circular(10.0))),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  HtmlWidget(
                                                    item.Comments,
                                                    factoryBuilder: () => MyWidgetFactory(),
                                                  ),
                                                  Text(
                                                    timeAgo(item.sCreatedAt.toString().trim(),
                                                        isUTC: true),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.grey,
                                                        fontSize: 10),
                                                  )
                                                ],
                                              )),
                                        ],
                                      )
                                    else
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4.0),
                                            child: Text(
                                              item.sCreatedByEmail,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Container(
                                              padding: const EdgeInsets.all(5),
                                              constraints: BoxConstraints(
                                                  minWidth: 70,
                                                  maxWidth:
                                                      MediaQuery.of(context).size.width * 0.75),
                                              decoration: const BoxDecoration(
                                                  color: CustomColors.lightblue,
                                                  borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(10.0),
                                                      topLeft: Radius.circular(10.0),
                                                      bottomRight: Radius.circular(10.0))),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.Comments,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                  Text(
                                                    timeAgo(item.sCreatedAt.toString().trim(),
                                                        isUTC: true),
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.grey,
                                                        fontSize: 10),
                                                  )
                                                ],
                                              )),
                                        ],
                                      ),
                                  ]),
                            ));
                          },
                        ),
                ),
              ),
              if (widget.modifyData)
                Wrap(
                  children: [
                    Divider(
                      height: 2,
                      color: Colors.grey.withAlpha(80),
                    ),
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Expanded(
                    //         child: GestureDetector(
                    //       onTap: () {
                    //         setState(() {
                    //           isInternal = true;
                    //         });
                    //       },
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.end,
                    //           children: [
                    //             Radio(
                    //                 value: 1,
                    //                 groupValue: isInternal ? 1 : 2,
                    //                 onChanged: (value) {
                    //                   setState(() {
                    //                     isInternal = true;
                    //                   });
                    //                 }),
                    //             const Text(
                    //               "Internal (Private)",
                    //               maxLines: 1,
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     )),
                    //     const SizedBox(
                    //       width: 16,
                    //     ),
                    //     Expanded(
                    //         child: GestureDetector(
                    //       onTap: () {
                    //         setState(() {
                    //           isInternal = false;
                    //         });
                    //       },
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           children: [
                    //             Radio(
                    //                 value: 2,
                    //                 groupValue: isInternal ? 1 : 2,
                    //                 onChanged: (value) {
                    //                   setState(() {
                    //                     isInternal = false;
                    //                   });
                    //                 }),
                    //             const Text(
                    //               "External (Public)",
                    //               maxLines: 1,
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     )),
                    //   ],
                    // ),
                    Container(
                      margin: const EdgeInsets.all(5),
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black45),
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                      child: TextField(
                          // enabled:
                          //     controllerTree.iCurrentSelect.toString().contains('_0'),
                          scrollPadding: const EdgeInsets.only(bottom: 32.0),
                          controller: commentTextController,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w400,
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          minLines: 4,
                          decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  MdiIcons.send,
                                  color: CustomColors.ezpurple,
                                ),
                                onPressed: () async {
                                  if (commentTextController.text.trim().isNotEmpty) {
                                    var comment = commentTextController.text;
                                    commentTextController.text = "";
                                    String formattedTime = DateFormat("yyyy-MM-ddTHH:mm:ss.SSZ")
                                        .format(DateTime.now().toUtc());

                                    WorkflowCommentsData newComment = WorkflowCommentsData(
                                        Comments: comment,
                                        sCreatedAt: formattedTime,
                                        sCreatedByEmail: '',
                                        sCreatedBy: sessionController.userid.value,
                                        sExternalCommentsby: '',
                                        sProcessId: '',
                                        sTransactionId: '',
                                        showTo: isInternal ? 0 : 1,
                                        bIsDeletes: false);

                                    workflowCommentsData.add(newComment);
                                    dynamicFormController.commentsCount.value =
                                        workflowCommentsData.length;

                                    setState(() {});
                                    if (widget.transactionId != -1 && widget.processId != -1) {
                                      var response = await workflowRepository.postWorkflowComment(
                                          widget.workflowId,
                                          widget.processId,
                                          widget.transactionId,
                                          {"comments": comment, "showTo": isInternal ? 0 : 1});
                                    }

                                    if (widget.onCommentsAdded != null) {
                                      widget.onCommentsAdded!(comment);
                                    }
                                  }
                                },
                              ),
                              // hintText: "Enter Remarks",
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.blue)))),
                    )
                  ],
                )
            ],
          ),
        ));
  }

  scrollToBottom() {
    // _scrollController.animateTo(_scrollController.position.maxScrollExtent,
    //     duration: const Duration(milliseconds: 1), curve: Curves.fastOutSlowIn);
  }

  void getCommentsDetailsCount() async {
    final responses = await AuthRepo.getCommentsList(
        int.parse(controllerpopup.sWorkFlowId), controllerpopup.sProcessId);
    List lComments = jsonDecode(AaaEncryption.decryptAESaaa(responses.toString())) as List;
    setState(() {
      controllerpopup.iMsgCount.value = lComments.length;
    });
  }
}

class MyWidgetFactory extends WidgetFactory with UrlLauncherFactory {}
