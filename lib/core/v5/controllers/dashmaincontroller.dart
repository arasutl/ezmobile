
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../api/auth_repo.dart';
import '../utils/helper/aes_encryption.dart';

class WorkflowRootController extends GetxController {
  RxString iCurrentSelect = 'dashboard'.obs;
  final iPendingtask = ''.obs;

  justPrint() {
    debugPrint('justPrint');
    debugPrint(AaaEncryption.KeyVal.toString());
    debugPrint(AaaEncryption.IvVal.toString());
    debugPrint(AaaEncryption.sToken);
  }

  void getTotalInboxCount() async {
    final responses = await AuthRepo.getTotalInboxCount();
    final ttemp = AaaEncryption.decryptAESaaa(responses.toString());

    if (int.parse(ttemp) > 0) {
      iPendingtask.value = ttemp;
    } else {
      iPendingtask.value = '0';
    }
  }
}
