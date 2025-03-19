import 'package:ez/core/CustomColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:scanning_effect/scanning_effect.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({super.key});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ClipRect(
            child: QRCodeDartScanView(
              typeScan: TypeScan.live,

              onCapture: (Result result) {
                Get.back(result: result.text);
              },
            ),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,height: MediaQuery.of(context).size.width * 0.75,
              child: ScanningEffect(
                scanningColor: CustomColors.green.withAlpha(40),
                borderLineColor: CustomColors.white,

                delay: Duration(seconds: 1),
                duration: Duration(seconds: 2),
                child: SizedBox(width: 100,height: 100),
              ),
            ),
          ),


        ],
      )
    );
  }
}
