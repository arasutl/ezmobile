import 'package:ez/core/CustomColors.dart';
import 'package:ez/core/snack_bar.dart';
import 'package:ez/core/v5/models/popup/controllers/attachfilecontroller.dart';
import 'package:ez/repositories/workflow_repository.dart';
import 'package:ez/widgets/editor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:textfield_tags/textfield_tags.dart';

class DocumentSharingByEmail extends StatefulWidget {
  final List<AttachmentData> files;
  final int repositoryId;

  const DocumentSharingByEmail({super.key, required this.repositoryId, required this.files});

  @override
  State<DocumentSharingByEmail> createState() => _DocumentSharingByEmailState();
}

class _DocumentSharingByEmailState extends State<DocumentSharingByEmail> {
  String? toError;
  String? subjectError;
  List<String> emails = [];
  String html = "";
  TextEditingController subject = TextEditingController();
  WorkflowRepository workflowRepository = GetIt.instance<WorkflowRepository>();
  bool isLoading = false;

  Future<void> submitMail() async {
    FocusManager.instance.primaryFocus?.unfocus();

    toError = null;
    subjectError = null;
    if (emails.isEmpty) {
      setState(() {
        toError = "To should not be empty";
      });
    } else {
      for (var elm in emails) {
        if (!elm.isEmail) {
          setState(() {
            toError = "Invalid email address!";
          });
        }
      }
    }

    if (subject.text.isEmpty) {
      setState(() {
        subjectError = "Subject should not be empty";
      });
    }

    if (toError != null && toError!.isNotEmpty ||
        subjectError != null && subjectError!.isNotEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    await workflowRepository.shareMailWithAttachments({
      "repositoryId": widget.repositoryId,
      "itemIds": widget.files.map((elm) => elm.id).toList(),
      "toAdd": emails.join(","),
      "subject": subject.text,
      "body": html
    });

    Navigator.pop(context);
    Snack.successSnack(context, "Initiated document sharing by Email.");

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        title: const FittedBox(fit: BoxFit.scaleDown, child: Text("Document Sharing By Email")),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "To",
                                style: Theme.of(Get.context!).textTheme.labelMedium,
                              ),
                            ),
                            const Text(
                              " * ",
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFieldTags<String>(
                          initialTags: const [],
                          textSeparators: const [' ', ','],
                          letterCase: LetterCase.normal,
                          validator: (String tag) {
                            return null;
                          },
                          inputFieldBuilder: (context, inputFieldValues) {
                            emails = inputFieldValues.tags;

                            return TextField(
                              controller: inputFieldValues.textEditingController,
                              focusNode: inputFieldValues.focusNode,
                              decoration: InputDecoration(
                                isDense: true,
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
                                  borderSide: const BorderSide(color: CustomColors.blue, width: 1),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: CustomColors.blue, width: 1),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                isCollapsed: true,
                                helperStyle: const TextStyle(
                                  color: Colors.blue,
                                ),
                                errorText: toError,
                                prefixIconConstraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.74),
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
                                              color: Colors.blue,
                                            ),
                                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0, vertical: 5.0),
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
                        const Text(
                          "Enter , (Comma) or space to add the email address",
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                        const SizedBox(
                          height: 8,
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "Subject",
                                style: Theme.of(Get.context!).textTheme.labelMedium,
                              ),
                            ),
                            const Text(
                              " * ",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: subject,
                          decoration: InputDecoration(
                              filled: true,
                              errorText: subjectError,
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
                                borderSide: const BorderSide(color: CustomColors.blue, width: 1),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: CustomColors.blue, width: 1),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                              isCollapsed: true,
                              hintStyle: TextStyle(color: Colors.grey.withAlpha(100))),
                        ),
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      runSpacing: 8,
                      spacing: 8,
                      children: [
                        for (var elm in widget.files)
                          Chip(
                            label: Text(elm.name),
                            elevation: 2,
                            shadowColor: Colors.black,
                            deleteIconColor: Colors.red,
                            onDeleted: () {
                              if (widget.files.length > 1) {
                                setState(() {
                                  widget.files.remove(elm);
                                });
                              }
                            },
                          )
                      ],
                    ),
                    SizedBox(
                        height: 350,
                        child: Editor(
                          onChange: (value) {
                            html = value;
                          },
                          initialValue: "",
                          readOnly: false,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: () {}, child: const Text("Cancel")),
                          const SizedBox(
                            width: 16,
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: CustomColors.ezpurple,
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              submitMail();
                            },
                            iconAlignment: IconAlignment.end,
                            label: const Text(
                              "Send",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
                child: Container(
              color: Colors.black.withAlpha(40),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [CircularProgressIndicator()],
              ),
            ))
        ],
      ),
    );
  }
}
