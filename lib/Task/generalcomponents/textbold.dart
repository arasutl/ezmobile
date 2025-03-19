import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Textbold extends StatefulWidget {
  final String sLabel;
  final Color sTextColor;

  const Textbold({required this.sLabel, required this.sTextColor});

  @override
  _TextboldState createState() => _TextboldState();
}

class _TextboldState extends State<Textbold> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.sLabel,
        maxLines: 1,
        style: TextStyle(
            fontSize: 18,
            color: widget.sTextColor,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis));
  }
}
