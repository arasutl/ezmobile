
import 'package:get/get.dart';

import '../../comments.dart';


class CommentController extends GetxController {
  //final controllerpopup = Get.put(PopupFullPageController());
  int iSelecteFileCount = 0;

  String sMessage = '';
  final formFieldsModel = <String, dynamic>{}.obs;
  dynamic showTo = 1;

  List dataMessageList = <WorkflowCommentsData>[];
  int getSelectedFileCount(List dataFileListNew) {
    var filtered = dataFileListNew.where((e) => e.selected == true);
    return filtered.length;
  }

  void onFormFieldChanged(dynamic value, String fieldName) {
    formFieldsModel[fieldName] = value;
  }
}
