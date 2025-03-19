
import 'package:get/get.dart';

import '../../../api/auth_repo.dart';
import '../../../utils/helper/aes_encryption.dart';

import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class MultiSelectMainController extends GetxController {
  String sSelectedmemberIds = "";
  List<String> items = [];
  List<String> itemsId = [];
  String sSelectedmemberIdsd = "";

  Future<List<String>> fetchStaff() async {
    String payload = '{"criteria":"userType","value":"Normal"}';
    payload = '{"criteria":userType,"value":Normal}';

    //Fkw7HjvauCSlRQR2Z5zm5jUV6B1iIDAzkbJ+C65JJ9DmVJ1b9HxlIho/rUjGcZ97"
    //print(jsonEncode(AaaEncryption.EncryptDatatest(payload)));

    final response = await AuthRepo.getUserList(AaaEncryption.EncryptDatatest(payload));

    //Map<String, dynamic> data = jsonDecode(AaaEncryption.decryptAESaaa(response.data));
    //temp = jsonDecode(AaaEncryption.decryptAESaaa(response.data)) as List<dynamic>;

    return items;
  }
}
