import 'package:flutter/material.dart';
import 'package:get/get.dart';

void alert({required String title, String subtitle = '', String type = 'Positive'}) {
/*  Get.snackbar(
    title,
    subtitle,
    icon: Icon(
      type == 'Positive' ? Icons.check_circle : Icons.cancel_rounded,
      color: Colors.white,
    ),
    backgroundColor: type == 'Positive' ? Colors.green : Colors.redAccent,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
  );*/

  Get.showSnackbar(
    GetSnackBar(
      title: title,
      message: subtitle,
      icon: Icon(
        type == 'Positive' ? Icons.check_circle : Icons.cancel_rounded,
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(16),
      backgroundColor: type == 'Positive' ? Colors.green : Colors.redAccent,
      //borderRadius:BorderRadius.circular(2.0) ,
      // borderRadius: BorderRadius.all(Radius.circular(2.0)),
      borderRadius: 2,
      duration: const Duration(seconds: 2),
    ),
  );
}
