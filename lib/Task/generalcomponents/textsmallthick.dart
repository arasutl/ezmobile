import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextSmallThick extends StatefulWidget {
  final String sLabel;
  final Color cColor;

  const TextSmallThick({required this.sLabel, required this.cColor});

  @override
  _TextSmallThickState createState() => _TextSmallThickState();
}

class _TextSmallThickState extends State<TextSmallThick> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.sLabel,
        maxLines: 1,
        style: TextStyle(
            fontSize: 14,
            color: widget.cColor, // Colors.black54,
            fontWeight: FontWeight.w600));
  }
}
