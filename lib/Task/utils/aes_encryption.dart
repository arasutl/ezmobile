import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import '../../core/v5/utils/helper/aes_encryption.dart' as aestemp;

class AaaEncryption {
  String enc = '';
  static Key KeyVal = Key.fromBase64('');
  static IV IvVal = IV.fromBase64('');
  static String sToken = '';

  AaaEncryption() {}

  //SharedPreferences pre = SharedPreferences.getInstance() as SharedPreferences;

  static decryptAESaaa(String encrptedString) {
    final encrypter = Encrypter(AES(KeyVal, mode: AESMode.cbc));
    var decrypted = encrypter.decrypt64(encrptedString, iv: IvVal);
    return decrypted;
  }

  static EncryptData(String plaintext) {
    final encrypter = Encrypter(AES(KeyVal, mode: AESMode.cbc));
    Encrypted encrypted = encrypter.encrypt(plaintext, iv: IvVal);
    return encrypted.base64;
  }

  static EncryptDatatest(final plaintext) {
    final encrypter = Encrypter(AES(KeyVal, mode: AESMode.cbc));
    Encrypted encrypted = encrypter.encrypt(plaintext, iv: IvVal);
    return encrypted.base64;
  }

  static dec_base64(String sBase64String) {
    var decoded_bytes = base64.decode(sBase64String);
    var decoded_str = utf8.decode(decoded_bytes);
    return decoded_str;
  }

  //It is duplicate Fn will remove in future after merge source
  void assignValues() {
    print('Folder key values1.');
    KeyVal = aestemp.AaaEncryption.KeyVal;
    IvVal = aestemp.AaaEncryption.IvVal;
    sToken = aestemp.AaaEncryption.sToken;
  }
}
