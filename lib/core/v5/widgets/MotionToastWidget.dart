import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';

class MotionToastWidget {
  displayErrorMotionToast(String Msgs, BuildContext ctx) {
    MotionToast.error(
      title: const Text(
        'Error',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(Msgs),
//      position: MotionToastPosition.top,
      layoutOrientation: ToastOrientation.rtl,
      barrierColor: Colors.black.withOpacity(0.3),
      width: 300,
      height: 50,
      dismissable: false,
    ).show(ctx);
  }

  displaySuccessMotionToast(String Msgs, BuildContext ctx) {
    MotionToast toast = MotionToast.success(
        title: const Text(
          'Sucess',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        description: Text(
          Msgs,
          style: const TextStyle(fontSize: 12),
        ),
        layoutOrientation: ToastOrientation.rtl,
        animationType: AnimationType.fromRight,
        borderRadius: 5,
        dismissable: true,
        height: 50,
        width: 300);

    toast.show(ctx);
    Future.delayed(const Duration(seconds: 4)).then((value) {
      //toast.dismiss();
    });
  }

  displayWarningMotionToast(String Msgs, BuildContext ctx) {
    MotionToast toast = MotionToast.warning(
        title: const Text(
          'Warning',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        description: Text(
          Msgs,
          style: const TextStyle(fontSize: 12),
        ),
        layoutOrientation: ToastOrientation.rtl,
        animationType: AnimationType.fromRight,
        borderRadius: 5,
        dismissable: true,
        height: 50,
        width: 300);

    toast.show(ctx);
    Future.delayed(const Duration(seconds: 4)).then((value) {
      // toast.dismiss(); //version issue
    });
  }
}
