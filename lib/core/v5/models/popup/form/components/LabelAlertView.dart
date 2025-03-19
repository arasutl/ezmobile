import 'package:flutter/material.dart';

import '../../../../config/theme.dart';

class LabelAlertView extends StatelessWidget {
  final String sLabel;
  const LabelAlertView(this.sLabel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      backgroundColor: Colors.black.withOpacity(0.00001),
      child: dialogContent(context, sLabel),
    );
  }

  Widget dialogContent(BuildContext context, String sLabel) {
    return Container(
      margin: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              top: 18.0,
            ),
            margin: const EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Colors.red,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                    //color: Colors.yellow,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text(sLabel,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            color: Color(0xff64748b),
                            //64748b
                            fontWeight: FontWeight.w500))),
                const SizedBox(height: 18.0),
              ],
            ),
          ),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: BrandColors.gray.shade50,
                  child: const Icon(Icons.close, color: BrandColors.gray),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
