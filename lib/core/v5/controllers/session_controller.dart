import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../models/session.dart';
import '../utils/UserDetails.dart';
import '../utils/helper/aes_encryption.dart';
import 'package:encrypt/encrypt.dart' as enc;

class SessionController extends GetxController {
  final userDetails = UserDetails.empty().obs;
  Map<String,dynamic> userData = {};
  var token = ''.obs;
  var key = ''.obs;
  var iv = ''.obs;
  var userid = ''.obs;
  var twoFactorAuthentication = true.obs;
  final store = GetStorage();

  var userdata = '';

  @override
  Future onInit() async {
    await getSession();
    super.onInit();
  }

  // ...
  // initSession
  void initSession(Session session) {
    token.value = session.token;
    iv.value = session.iv;
    key.value = session.key;
    twoFactorAuthentication.value = session.twoFactorAuthentication;
    AaaEncryption.sToken = token.value;
    AaaEncryption.KeyVal = enc.Key.fromBase64(key.value);
    AaaEncryption.IvVal = enc.IV.fromBase64(iv.value);
  }

  void initUserDetails(UserDetails data) {
    userid.value = data.id;
  }

  // ...
  // setSession

  Future<void> setSession(Map<String, dynamic> data) async {
    try {
      final session = Session.fromJson(data);
      initSession(session);
      store.write('session', json.encode(session));
      store.save();
    } catch (e) {
    }
  }

  setSessionUser(Map<String, dynamic> data) async {
    try {
      userDetails.value = UserDetails.fromJson(data);

      store.write('userdetails', json.encode(data));
      store.save();

      final session = store.read('session') ?? '';
      userdata = store.read('userdetails') ?? '';
      Session.fromJson(json.decode(session));
    } catch (e) {
    }
  }

  // ...
  // getSession
  Future<void> getSession() async {
    try {
      final session = store.read('session') ?? '';
      final userdetailsdata = store.read('userdetails') ?? '';

      if (session != '') {
        final session0 = Session.fromJson(json.decode(session));
        initSession(session0);
        // assign user details
        if (userdetailsdata != '') {
          userDetails.value = UserDetails.fromJson(json.decode(userdetailsdata));
          initUserDetails(userDetails.value);
        }
      }
    } catch (e) {
    }
  }

  // deleet Session
  Future<void> deleteSession() async {
    await store.erase();
    if(Platform.isAndroid) {
      await _deleteAppDir();
      await _deleteCacheDir();
    }
  }

  Future<void> _deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  /// this will delete cache
  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }
}
