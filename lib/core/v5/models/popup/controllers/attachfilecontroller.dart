import 'package:ez/core/v5/models/popup/controllers/workflow_detail_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../api/auth_repo.dart';
import '../../../utils/helper/aes_encryption.dart';
import '../../../utils/helper/alert.dart';
import '../models/selectedFileUpload.dart';
import 'package:dio/dio.dart' as dii;
//import 'package:mime_type/mime_type.dart';

class AttcaheFileController extends GetxController {
  final controllerpopup = Get.put(WorkflowDetailController());
  int iSelecteFileCount = 0;
  //late File Pfile;
  //final tabitems = ['Home', 'Attachemnts', 'Comments', 'Task', 'History'];

  List dataFileListNew = <AttachmentData>[].obs;
  List lSelectedFileIds = <int>[].obs;
  String sSelectedRepository = '';

  final showSelectedFiles = false.obs;
  final selectedFiles = <SelectedFileUpload>[].obs;
  late bool bActionType = true;
  late bool bDeletionType = true;
  String sFilrUrl = '';

  int getSelectedFileCount(List dataFileListNew) {
    var filtered = dataFileListNew.where((e) => e.selected == true);
    return filtered.length;
  }

  selectedUploadedFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      selectedFiles.clear();

      selectedFiles.value = result.files
          .map((file) => SelectedFileUpload(
              name: file.name,
              size: formatFileSize(file.size),
              type: file.extension ?? '',
              file: file.path,
              workflowId: controllerpopup.sWorkFlowId,
              repositoryId: controllerpopup.repositoryId,
              processId: controllerpopup.sProcessId,
              transactionId: controllerpopup.sTransactionId,
              fields: ''))
          .toList();

      showSelectedFiles.value = true;

      dii.FormData formData = dii.FormData.fromMap({
        'name': selectedFiles[0].name,
        'size': selectedFiles[0].size,
        'type': selectedFiles[0].type,
        'file': await dii.MultipartFile.fromFile(selectedFiles[0].file),
        'workflowId': controllerpopup.sWorkFlowId,
        'repositoryId': controllerpopup.repositoryId,
        'processId': controllerpopup.sProcessId,
        'transactionId': controllerpopup.sTransactionId,
        'fields': ''
      });

      final responses = await AuthRepo.postAttachment(formData);
      String dec = AaaEncryption.decryptAESaaa(responses.toString());

      final statusCode = responses.statusCode;

      if (statusCode == 200) {
        print('sucess');
        return true;
      }
      return false;
    }
  }

  String formatFileSize(int size) {
    return filesize(size);
  }

  void onUpload() {
    //showbottomup.value = false;
    selectedUploadedFiles();
    debugPrint('onFabPlus onUpload');
  }

  Future<bool> DeleteMultipleFiles(
      BuildContext ctx, String sRepositoryID, String sFileIdsENc) async {
    print('DeleteMultipleFiles');

    final responses = await AuthRepo.postDeleteFiles(
        sRepositoryID, sFileIdsENc, bActionType ? '1' : '2', bDeletionType ? '0' : '1');

    if (AaaEncryption.decryptAESaaa(responses.toString()) == 'success') {
      alert(title: 'Success', subtitle: 'File Deleted Sucessfully', type: 'Positive');
    } else {
      alert(title: 'Error', subtitle: 'File Not Deleted', type: 'Negative');
    }
    //MotionToastWidget().displayErrorMotionToast('!File Not Deleted.', ctx);

    for (int i = 0; i < dataFileListNew.length; i++) {
      AttachmentData fd = dataFileListNew[i];
      if (fd.selected.value) {
        //bDeletionType   =>   0 for file go to trash, 1-> for permanant delete
        //bActionType   =>   1 for delete , 2 -> for restore
        //Fileidd =>  { "ids": [1,2] }
        final responses = await AuthRepo.postDeleteFiles(
            fd.repositoryId, sFileIdsENc, bActionType ? '1' : '2', bDeletionType ? '0' : '1');

        if (AaaEncryption.decryptAESaaa(responses.toString()) == 'success') {
          alert(title: 'Success', subtitle: 'File Deleted Sucessfully', type: 'Positive');
        } else {
          alert(title: 'Error', subtitle: 'File Not Deleted', type: 'Negative');
        }
        //MotionToastWidget().displayErrorMotionToast('!File Not Deleted.', ctx);
      }
    }

    return true;
  }

/*  Future Uploadimage(BuildContext context, String entryType, String mode) async {
    FormData fd = new FormData({
      'workflowId': controllerpopup.sWorkFlowId,
      'repositoryId': controllerpopup.repositoryId,
      'processId': controllerpopup.sProcessId,
      'transactionId': controllerpopup.sTransactionId,
      'fields': '',
      'filename': ''
    });
  }*/
}

class AttachmentData {
  int id = 0;
  String name = '';
  String repositoryId = '';
  String description = '';
  String Status = '';
  String createdByEmail = '';
  String createdAt = '';
  RxBool selected = false.obs;

  AttachmentData(this.id, this.name, this.repositoryId, this.Status, this.description, this.selected,
      this.createdByEmail, this.createdAt);

  AttachmentData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    repositoryId = json['repositoryId'].toString();
    description = json['repository'];
    createdByEmail = json['createdByEmail'];
    createdAt = json['createdAt'];
    Status = 'UPLOADED'; //json['comments'];
    selected.value = false;
  }
}
