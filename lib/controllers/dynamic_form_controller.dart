import 'package:ez/core/v5/models/popup/controllers/attachfilecontroller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class DynamicFormController extends GetxController {
  var attachmentCount = 0.obs;
  var commentsCount = 0.obs;
  List<AttachmentData> workflowAttachmentDataFromForm = <AttachmentData>[].obs;
  BuildContext? workflowAttachmentBottomModelSheetContext;
  void reset() {
    attachmentCount.value = 0;
    commentsCount.value = 0;
    workflowAttachmentDataFromForm = [];
    workflowAttachmentBottomModelSheetContext = null;
    update();
  }
}
