import 'dart:convert';
import 'package:ez/Const/CustomColors.dart';
import 'package:ez/controllers/dynamic_form_controller.dart';
import 'package:ez/core/v5/widgets/CustomWidget.dart';
import 'package:ez/repositories/workflow_repository.dart';
import 'package:ez/screens/CustomCameraPage.dart';
import 'package:ez/screens/document_sharing_by_email.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../ApiClient/endpoint.dart';
import '../../../api/auth_repo.dart';
import '../../../controllers/session_controller.dart';
import '../../../controllers/treeboxlistviewcontroller.dart';
import '../../../utils/file_fns.dart';
import '../../../utils/format_date_time.dart';
import '../../../utils/helper/aes_encryption.dart';
import '../controllers/attachfilecontroller.dart';
import 'package:dio/dio.dart' as Dio;

class WorkflowAttachments extends StatefulWidget {
  final int workflowId;
  final int processId;
  final int repositoryId;
  final int transactionId;
  final String? title;
  final bool modifyData;
  Function(int fileId)? onFileAdded;
  Function(int fileId)? onFileRemoved;
  Function(int count)? attachmentCount;
  BuildContext? bottomSheetContext;
  List<dynamic>? fileCheckList = [];
  Map<String, dynamic>? formFields = {};
  Function(dynamic status)? isAllRequiredAttachmentsAdded;

  WorkflowAttachments(
      {super.key,
      required this.workflowId,
      required this.processId,
      required this.transactionId,
      this.title,
      this.modifyData = false,
      required this.repositoryId,
      this.onFileAdded,
      this.onFileRemoved,
      this.attachmentCount,
      this.bottomSheetContext,
      this.fileCheckList,
      this.formFields,
      this.isAllRequiredAttachmentsAdded});

  @override
  _WorkflowAttachmentsState createState() {
    return _WorkflowAttachmentsState();
  }

  static Future<bool> isAllRequiredFilesAdded(int workflowId, int transactionId, int processId,
      List<dynamic>? fileCheckList, Map<String, dynamic>? formFields) async {
    WorkflowRepository workflowRepository = GetIt.instance<WorkflowRepository>();

    List<dynamic> fileSettings =
        await workflowRepository.getFileSettings(workflowId, transactionId);

    List<AttachmentData> files =
        await workflowRepository.workflowAttachments(workflowId, processId);

    var status = true;
    for (var elm in fileSettings) {
      if (isMandatory(elm, fileCheckList, formFields)) {
        if (status) {
          bool isFileUploaded = false;
          for (var file in files) {
            String uFileName = file.name.split(".").first.toLowerCase();
            if (uFileName.startsWith(elm['name'].toLowerCase())) {
              isFileUploaded = true;
              continue;
            }
          }

          if (!isFileUploaded) {
            status = false;
          }
        }
      }
    }

    print("All files uploaded ${status}");
    return status;
  }

  static bool isMandatory(
      dynamic item, List<dynamic>? fileCheckList, Map<String, dynamic>? formFields) {
    if (fileCheckList == null || formFields == null) return false;

    for (var fileCheckList in fileCheckList ?? []) {
      if (item['name'] == fileCheckList['name']) {
        bool required = fileCheckList['required'];

        List<dynamic>? conditions = fileCheckList['conditions'];

        for (var condition in conditions ?? []) {
          switch (condition['logic']) {
            case "IS_EQUALS_TO":
              if (formFields.containsKey(condition["name"]) ?? false) {
                if (formFields[condition['name']] == condition['value']) {
                  required = !required && true;
                } else {
                  required = false;
                }
              }
              break;
            case "IS_LESSER_THAN":
              if (formFields.containsKey(condition["name"]) ?? false) {
                if ((double.tryParse(formFields[condition['name']].toString()) ?? 0) <
                    (double.tryParse(condition['value'].toString()) ?? 0)) {
                  required = !required && true;
                } else {
                  required = false;
                }
              }
              break;
            case "IS_GREATER_THAN":
              if (formFields.containsKey(condition["name"]) ?? false) {
                if ((double.tryParse(formFields[condition['name']].toString()) ?? 0) >
                    (double.tryParse(condition['value'].toString()) ?? 0)) {
                  required = !required && true;
                } else {
                  required = false;
                }
              }
              break;
          }
        }

        return required;
      }
    }
    return false;
  }
}

class _WorkflowAttachmentsState extends State<WorkflowAttachments>
    with AutomaticKeepAliveClientMixin {
  late WorkflowRepository workflowRepository;
  List<AttachmentData> files = [];
  bool isLoading = false;
  bool overlayLoading = false;
  String overlayLoadingText = "";
  final controller = Get.put(AttcaheFileController());
  final controllerTree = Get.put(TreeInboxListviewController());
  final sessionController = Get.find<SessionController>();
  List<dynamic> fileSettings = [];
  bool selectionModeEnabled = false;
  final DynamicFormController dynamicFormController = Get.put(DynamicFormController());

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    workflowRepository = GetIt.instance<WorkflowRepository>();
    files = dynamicFormController.workflowAttachmentDataFromForm;

    fetchData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // getWorkflowAttachments();
  }

  Future fetchData() async {
    if (widget.transactionId == -1 && widget.processId == -1) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (widget.modifyData) {
      fileSettings =
          await workflowRepository.getFileSettings(widget.workflowId, widget.transactionId);
    }

    files = await workflowRepository.workflowAttachments(widget.workflowId, widget.processId);

    // if ((widget.workflowAttachmentData?.length ?? 0) > 0) {
    files = [...files, ...dynamicFormController.workflowAttachmentDataFromForm];
    // }

    dynamicFormController.attachmentCount.value = files.length;
    dynamicFormController.update();
    // if(widget.attachmentCount != null) {
    //   widget.attachmentCount!(files.length);
    // }
    setState(() {
      isLoading = false;
    });
    WorkflowAttachments.isAllRequiredFilesAdded(widget.workflowId, widget.transactionId,
        widget.processId, widget.fileCheckList, widget.formFields);
  }

  bool isFileSelected() {
    bool status = false;
    for (var elm in files) {
      if (elm.selected.value == true) {
        status = true;
      }
    }
    return status;
  }

  List<AttachmentData> getSelectedFiles() {
    return files.where((elm) => elm.selected.value == true).toList();
  }

  List<AttachmentData> getSelectedPdfFiles() {
    return files.where((elm) {
      return elm.selected.value == true && elm.name.toLowerCase().endsWith(".pdf");
    }).toList();
  }

  bool isPdfOnlySelected() {
    return getSelectedPdfFiles().isNotEmpty &&
        files
            .where((elm) {
              return elm.selected.value == true && !elm.name.toLowerCase().endsWith(".pdf");
            })
            .toList()
            .isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned.fill(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await fetchData();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      if (!isLoading && !widget.modifyData && files.isEmpty)
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Spacer(), Text("No attachments or documents available.")],
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: isLoading
                              ? 10
                              : files.length + (widget.modifyData ? fileSettings.length : 0),
                          itemBuilder: (context, index) {
                            // Return shimmer
                            if (isLoading) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomWidget.rectangular(
                                  height: 70,
                                  width: MediaQuery.of(context).size.width * 0.3,
                                ),
                              );
                            }

                            // Upload card
                            if (index > files.length - 1) {
                              // Is file already uploaded
                              if (isFileAlreadyUploaded(
                                  fileSettings[index - files.length]["name"])) {
                                return Container();
                              }

                              return ListTile(
                                title: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                    alignment: Alignment.topCenter,
                                                    margin: const EdgeInsets.all(2),
                                                    child: Image.asset(
                                                      fileIcon("a.file"),
                                                      height: 20,
                                                      width: 20,
                                                    )),
                                                Flexible(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        // name
                                                        Text(
                                                            fileSettings[index - files.length]
                                                                    ["name"] ??
                                                                "",
                                                            style: const TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold)),
                                                        if (WorkflowAttachments.isMandatory(
                                                            fileSettings[index - files.length],
                                                            widget.fileCheckList,
                                                            widget.formFields))
                                                          const Text(
                                                            "Required",
                                                            style: TextStyle(
                                                                color: Colors.red, fontSize: 12),
                                                          )
                                                        // ...
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                  fixedSize: const Size(100, 20),
                                                  padding: EdgeInsets.zero,
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                              onPressed: () async {
                                                uploadSelectedFile(
                                                    fileName: fileSettings[index - files.length]
                                                        ["name"]);
                                              },
                                              icon: Icon(MdiIcons.upload),
                                              label: const Text(
                                                "Upload",
                                                style: TextStyle(fontWeight: FontWeight.w600),
                                              ))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            // Upload card

                            AttachmentData item = files.elementAt(index);
                            return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: GestureDetector(
                                    onTap: () async {
                                      if (selectionModeEnabled) {
                                        item.selected.value = !item.selected.value;
                                        if (getSelectedFiles().isEmpty) {
                                          selectionModeEnabled = false;
                                        }
                                        setState(() {});
                                      } else {
                                        if (widget.transactionId != -1 && widget.processId != -1) {
                                          Uri fileUrl = Uri.parse(
                                              '${EndPoint.BaseUrl}file/view/${sessionController.userDetails.value.tenantId}/${sessionController.userDetails.value.id}/${widget.repositoryId}/${item.id}/2');
                                          if (await canLaunchUrl(fileUrl)) {
                                            await launchUrl(fileUrl);
                                          }
                                        } else {
                                          Uri fileUrl = Uri.parse(
                                              '${EndPoint.BaseUrl}uploadandindex/viewThumbnail/${sessionController.userDetails.value.tenantId}/${item.id}/1');
                                          if (await canLaunchUrl(fileUrl)) {
                                            await launchUrl(fileUrl);
                                          }
                                        }
                                      }
                                    },
                                    onLongPress: () {
                                      item.selected.value = !item.selected.value;

                                      setState(() {
                                        selectionModeEnabled = isFileSelected();
                                      });
                                    },
                                    child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Column(children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (selectionModeEnabled)
                                                Checkbox(
                                                    value: item.selected.value,
                                                    onChanged: (value) {
                                                      item.selected.value = value ?? false;
                                                    }),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Container(
                                                              alignment: Alignment.topCenter,
                                                              margin: const EdgeInsets.all(2),
                                                              child: Image.asset(
                                                                fileIcon(item.name),
                                                                height: 20,
                                                                width: 20,
                                                              )),
                                                          const Positioned(
                                                              bottom: 50,
                                                              child:
                                                                  Icon(Icons.lock_person_outlined))
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(item.name,
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                                style: const TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.bold)),
                                                            Text(
                                                              item.createdByEmail,
                                                              style: const TextStyle(fontSize: 12),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            if (item.createdByEmail ==
                                                                sessionController
                                                                    .userDetails.value.email)
                                                              const Text(
                                                                "You are owner",
                                                                style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors.green),
                                                              )
                                                            else
                                                              const Text(
                                                                "You are not the owner",
                                                                style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors.red),
                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                      padding: const EdgeInsets.only(right: 16),
                                                      child: Text(
                                                          textAlign: TextAlign.end,
                                                          timeAgo(item.createdAt.trim()),
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w300))),
                                                  if (widget.modifyData)
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        if (item.createdByEmail ==
                                                            sessionController
                                                                .userDetails.value.email)
                                                          IconButton(
                                                              onPressed: () {
                                                                deleteAttachment(files[index]);
                                                              },
                                                              icon: Icon(
                                                                MdiIcons.trashCanOutline,
                                                                color: Colors.red,
                                                              )),
                                                        if (isThisPredefinedFile(files[index].name))
                                                          IconButton(
                                                              onPressed: () {
                                                                uploadSelectedFile(
                                                                    fileName: getPredefinedFileName(
                                                                        files[index].name));
                                                              },
                                                              icon: Icon(
                                                                MdiIcons.uploadOutline,
                                                                color: Colors.blue,
                                                              )),
                                                      ],
                                                    )
                                                ],
                                              )
                                            ],
                                          ),
                                        ]))));
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            if (isLoading) return Container();
                            if (index > files.length - 1) {
                              // Is file already uploaded
                              if (isFileAlreadyUploaded(
                                  fileSettings[index - files.length]["name"])) {
                                return Container();
                              }
                            }

                            return Divider(
                              height: 1,
                              color: Colors.grey.withAlpha(80),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              overlayLoading
                  ? Positioned.fill(
                      child: Container(
                      color: Colors.black.withAlpha(150),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                          overlayLoadingText.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    overlayLoadingText,
                                    style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ))
                  : Container()
            ],
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isPdfOnlySelected() && getSelectedPdfFiles().length > 1)
                Container(
                    margin: const EdgeInsets.all(8),
                    child: FloatingActionButton.small(
                      backgroundColor: CustomColors.ezpurple,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                              });

                              await workflowRepository.mergeFiles(
                                  widget.workflowId,
                                  widget.processId,
                                  widget.transactionId,
                                  widget.repositoryId,
                                  {"ids": getSelectedFiles().map((elm) => elm.id).toList()});

                              Fluttertoast.showToast(
                                  msg: "Document merge process initiated.",
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white);

                              for (var elm in files) {
                                elm.selected.value = false;
                              }
                              setState(() {
                                selectionModeEnabled = false;
                                isLoading = false;
                              });
                            },
                      child: const Icon(color: Colors.white, Icons.file_copy),
                    )),
              if (isFileSelected())
                Container(
                    margin: const EdgeInsets.all(8),
                    child: FloatingActionButton.small(
                      backgroundColor: Colors.blueAccent.shade200,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      onPressed: isLoading
                          ? null
                          : () => {
                                Get.to(() => DocumentSharingByEmail(
                                    repositoryId: widget.repositoryId, files: getSelectedFiles()))
                              },
                      child: const Icon(color: Colors.white, Icons.outgoing_mail),
                    )),
              Visibility(
                  visible: widget.modifyData,
                  child: Wrap(
                    direction: Axis.vertical,
                    children: <Widget>[
                      controller.iSelecteFileCount > 0
                          ? Container(
                              margin: const EdgeInsets.all(5),
                              child: FloatingActionButton.small(
                                backgroundColor: Colors.blueAccent.shade200,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(7.0))),
                                onPressed: isLoading ? null : () => {},
                                child: const Icon(color: Colors.white, Icons.delete_outline),
                              ))
                          : const SizedBox(), //button first//
                      controller.iSelecteFileCount == 0
                          ? Container(
                              margin: const EdgeInsets.all(8),
                              child: FloatingActionButton.small(
                                backgroundColor: CustomColors.ezpurple,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                onPressed: isLoading
                                    ? null
                                    : () => {
                                          //  ShowDialogforUpload(context)
                                          uploadSelectedFile()
                                        },
                                child: const Icon(color: Colors.white, Icons.file_upload_outlined),
                              ))
                          : const SizedBox(), // button third
                      // Add more buttons here
                    ],
                  )),
            ],
          ),
        ));
  }

  Color sReturnColor(String status) {
    switch (status) {
      case 'UPLOADED':
        return Colors.grey;
      case 'MODIFIED':
        return Colors.green;
      case 'ESIGN_REQUIRED':
        return Colors.deepOrangeAccent;
    }
    return Colors.grey;
  }

  void ShowDialogforUpload(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Upload Options",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildUploadButton(
                context,
                label: "Capture Image / File",
                icon: Icons.camera_alt,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(true);

                  // Add your logic for capturing image/file
                },
              ),
              const SizedBox(height: 8),
              _buildUploadButton(
                context,
                label: "Upload from Gallery",
                icon: Icons.photo_library,
                onTap: () {
                  Navigator.pop(context);
                  // Add your logic for uploading from gallery
                },
              ),
              const SizedBox(height: 8),
              _buildUploadButton(
                context,
                label: "Capture Multi-Page",
                icon: Icons.pages,
                onTap: () {
                  Navigator.pop(context);
                  // Add your logic for capturing multi-page
                },
              ),
              const SizedBox(height: 8),
              _buildUploadButton(
                context,
                label: "Upload file",
                icon: Icons.cloud_upload,
                onTap: () {
                  Navigator.pop(context);
                  // Add your logic for capturing multi-page
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void uploadSelectedFile({fileName}) async {
    FilePickerResult? pickedFiles = await FilePicker.platform
        .pickFiles(allowMultiple: true, allowCompression: false, compressionQuality: 0);

    if (pickedFiles != null) {
      setState(() {
        overlayLoadingText = "Uploading . . .";
        isLoading = true;
      });
      List<Map<String, dynamic>> fileObjects = [];

      for (var file in pickedFiles.files) {
        if (fileName != null) {
          fileName += ".${file.extension}";
        }

        Dio.MultipartFile multiPartFile =
            await Dio.MultipartFile.fromFile(file.path!, filename: file.path!.split("/").last);

        if (widget.transactionId == -1 && widget.processId == -1) {
          fileObjects.add({
            "filename": fileName ?? file.name,
            "file": multiPartFile,
            "repositoryId": widget.repositoryId
          });
        } else {
          fileObjects.add({
            "filename": fileName ?? file.name,
            "file": multiPartFile,
            "workflowId": widget.workflowId,
            "repositoryId": widget.repositoryId,
            "processId": widget.processId,
            "transactionId": widget.transactionId,
            "fields": ''
          });
        }
      }
      var response;

      if (widget.transactionId != -1 && widget.processId != -1) {
        response = await workflowRepository.uploadAttachments(fileObjects);
      } else {
        response = await workflowRepository.uploadAndIndex(fileObjects);

        if (response != null && response.length > 0) {
          dynamicFormController.attachmentCount.value += 1;

          String data = response[0].data;
          Map<String, dynamic> dataMap = jsonDecode(data);
          if (dataMap.containsKey("fileId")) {
            if (widget.onFileAdded != null) {
              widget.onFileAdded!(dataMap["fileId"]);
            }
            String email = sessionController.userData["email"];
            files.add(AttachmentData(
                dataMap["fileId"],
                fileName ?? fileObjects[0]["filename"],
                widget.repositoryId.toString(),
                "",
                "",
                false.obs,
                email,
                DateTime.now().toString()));
          }
        }
      }

      await fetchData();

      setState(() {
        overlayLoadingText = "";
        isLoading = false;
      });
    }
  }

  getFileDetailsCount() async {
    await Future.delayed(const Duration(seconds: 2));
    final responses = await AuthRepo.getFileList(widget.workflowId, widget.processId.toString());
    List lFiles = jsonDecode(AaaEncryption.decryptAESaaa(responses.toString())) as List;
  }

  bool isFileAlreadyUploaded(String fileName) {
    for (var file in files) {
      String uFileName = file.name.split(".").first.toLowerCase();
      if (uFileName.startsWith(fileName.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  bool isThisPredefinedFile(String fileName) {
    for (var file in fileSettings) {
      String uFileName = file["name"];
      String fileNameWithoutExt = fileName.split(".").first.toLowerCase();

      if (fileNameWithoutExt.startsWith(uFileName.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  String getPredefinedFileName(String fileName) {
    for (var file in fileSettings) {
      String uFileName = file["name"];
      String fileNameWithoutExt = fileName.split(".").first.toLowerCase();

      if (fileNameWithoutExt.startsWith(uFileName.toLowerCase())) {
        return uFileName;
      }
    }
    return fileName;
  }

  void deleteAttachment(AttachmentData file) async {
    setState(() {
      overlayLoadingText = "Deleting . . .";
      isLoading = true;
    });

    if (widget.processId == -1 && widget.transactionId == -1) {
      files.remove(file);
    } else {
      await workflowRepository.deleteAttachments(widget.repositoryId, 1, {
        "ids": [file.id]
      });
    }

    if (widget.onFileRemoved != null) {
      widget.onFileRemoved!(file.id);
    }

    setState(() {
      isLoading = false;
      overlayLoadingText = "";
    });
    dynamicFormController.attachmentCount.value -= 1;

    await fetchData();
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

  void showCustomCamera(BuildContext context) async {
    final capturedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomCameraPage()),
    );

    if (capturedImage != null) {
      print('Image path: ${capturedImage.path}');
      // Use the captured image
    }
  }

  Future<void> _pickImage(bool isCamera) async {
    final image = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery); /////////////  to be check //
    print('pick imaged34');
    final XFile? pickedimage = image;
    print('pick image');

    // if (pickedimage != null) {
    //   print('rrrrrrr  ' + controllerfolder.sRepositiryId.toString());
    //   UploadAPICal(File(pickedimage.path), int.parse(controllerfolder.sRepositiryId.toString()));
    //   setState(() {});
    // }
    print('just select');
  }
}
