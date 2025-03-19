import 'package:ez/core/CustomColors.dart';
import 'package:ez/core/v5/utils/utils.dart';
import 'package:ez/core/v5/widgets/CustomWidget.dart';
import 'package:ez/repositories/workflow_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:stepper_list_view/stepper_list_view.dart';

class ProcessHistory extends StatefulWidget {
  final int workflowId;
  final int processId;
  final String title;

  const ProcessHistory(
      {super.key,
      required this.workflowId,
      required this.processId,
      this.title = ""});

  @override
  State<ProcessHistory> createState() => _ProcessHistoryState();
}

class _ProcessHistoryState extends State<ProcessHistory> {
  late WorkflowRepository workflowRepository;
  List<dynamic> processHistoryList = [];
  bool isLoading = false;

  @override
  void initState() {
    workflowRepository = GetIt.instance<WorkflowRepository>();
    getHistoryDetails();
    super.initState();
  }

  Future<void> getHistoryDetails() async {
    setState(() {
      isLoading = true;
      processHistoryList = [];
    });

    List<dynamic> response = await workflowRepository.getProcessHistory(
        widget.workflowId, widget.processId);

    setState(() {
      isLoading = false;
      processHistoryList = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: getHistoryDetails,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != "")
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Divider(
                    height: 2,
                    color: Colors.grey.withAlpha(80),
                  )
                ],
              ),
            processHistoryList.isNotEmpty
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: StepperListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        showStepperInLast: false,
                        stepperData: processHistoryList.map((e) {
                          return StepperItemData(
                            id: e["activityId"],
                            content: e,
                          );
                        }).toList(),
                        stepAvatar: (_, data) {
                          return const PreferredSize(
                            preferredSize: Size.fromRadius(4),
                            child: Padding(
                              padding: EdgeInsets.only(top: 6.0),
                              child: CircleAvatar(
                                maxRadius: 4,
                                backgroundColor: Colors.lightBlueAccent,
                              ),
                            ),
                          );
                        },
                        stepWidget: (_, data) {
                          return const PreferredSize(
                              preferredSize: Size.fromWidth(30),
                              child: Column(
                                children: [],
                              ));
                        },
                        stepContentWidget: (_, data) {
                          final stepData = data as StepperItemData;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stepData.content["stage"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Text(
                                  Utils.getStandardDateTimeFormat(stepData.content["receivedOn"]),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),
                                ),
                                rowValueWidget("Action By",
                                    stepData.content["actionUser"] ?? ""),
                                rowValueWidget("Processed By",
                                    stepData.content["processedBy"]),
                                rowValueDateTimeWidget("Processed On",
                                    stepData.content["processedOn"]),
                                rowValueWidget(
                                    "Status", stepData.content["status"]),
                                if (stepData.content["attachments"].length > 0)
                                  ExpansionTile(
                                    tilePadding: EdgeInsets.zero,
                                    title: Text(
                                      "Attachments (${stepData.content["attachments"].length})",
                                      style: const TextStyle(
                                          color: CustomColors.blue),
                                    ),
                                    children: [
                                      for (var attachment
                                          in stepData.content["attachments"])
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Card(
                                            elevation: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text("File Name"),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          attachment["name"],
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text("Attached By"),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          attachment[
                                                              "createdByEmail"],
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text("Attached On"),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          Utils.getStandardDateTimeFormat(
                                                              attachment[
                                                                  "createdAt"]),
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                              ],
                            ),
                          );
                        },
                        stepperThemeData: StepperThemeData(
                          lineColor: Colors.cyanAccent.shade200,
                          lineWidth: 1,
                        ),
                      ),
                    ),
                  )
                : isLoading
                    ? Expanded(
                        child: ListView.builder(
                            itemCount: 20,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomWidget.rectangular(
                                  height: 70,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                ),
                              );
                            }),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }

  Widget rowValueWidget(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }



  Widget rowValueDateTimeWidget(String title, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value.trim().isNotEmpty ? Utils.getStandardDateTimeFormat(value) : "-",
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
