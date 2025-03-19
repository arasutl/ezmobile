import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AaaEncryption {
  String enc =
      'JdZZttdPmclirvPzu2HArZHn2J3H+YqSpE7AmoAwVsGhUHtbU9W4Qa2icdeqNnbP5DMBuuIL3lhmdiSTsnDlVbFGpq6A7eSaIm/BVCT6YGqEa/1pgIySS6mnv2Ti1sj98Qd07yXDdWjNxFo7qwJ1T8EtAcujOHZ8v2wOqeyuOGCTSu8tzuk1uUS01cI4OdyUvZepgtMmMj+NCgTRf5caOVMKCB3e5HmS0iqAB74hHwWe5uQS8n4wPBF9OxKmSHW3d+MZd03jWpjlwgqSq2/xoLMfLYGsCVJAqN3qLTeDCYIJyLQTXIRYPUoRj620Vj42IUxC44OWSuDI0V0bTzkj/9D9WJjxksShnQTyC3Lto8eXkPWbN+P7c608PvXcCHxA0Vp0moe2A5tkXdtTMmVPvUz5pQrzbjeUviIlk2r0NcloLPANXbOsR2PRuxb1OLNa';
  static Key KeyVal = Key.fromBase64('');
  static IV IvVal = IV.fromBase64('');
  static String sToken = '';
  SharedPreferences pre = SharedPreferences.getInstance() as SharedPreferences;

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
    var decodedBytes = base64.decode(sBase64String);
    var decodedStr = utf8.decode(decodedBytes);
    return decodedStr;
  }
}
