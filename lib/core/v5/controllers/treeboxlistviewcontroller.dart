import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../api/workflow_repo.dart';
import '../models/MenuInbox.dart';
import '../utils/helper/aes_encryption.dart';

class TreeInboxListviewController extends GetxController {
  RxString iCurrentSelect = 'dashboard'.obs;
  List<MenuInbox> data = [];
  late MenuInbox miList;

  Future<List<MenuInbox>> getWorkFlowList() async {
    final response = await WorkflowRepo.getlistByUserId();
    final dtemp = AaaEncryption.decryptAESaaa(response.data);

    List datas = json.decode(dtemp);

    data = [];
    for (var element in datas) {
      data.add(MenuInbox.fromJson(element));
    }
    return data;
  }
}
