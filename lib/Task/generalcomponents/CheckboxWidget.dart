import 'package:ez/Task/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckboxWidget extends StatefulWidget {
  final Function(bool) callback;
  final String sText;
  bool bSlelect;

  CheckboxWidget({Key? key, required this.callback, required this.sText, required this.bSlelect});

  @override
  _CheckboxWidgetState createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(widget.sText),
      Checkbox(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //fillColor: AppColors.blueez,
        //shape: CircleBorder(),
        activeColor: AppColors.blueez,
        visualDensity: VisualDensity.compact,
        value: widget.bSlelect,
        onChanged: (value) {
          widget.callback(value!);
          setState(
            () => widget.bSlelect = !widget.bSlelect,
          ); //
        },
      ),
    ]);
  }
}
