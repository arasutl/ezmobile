import 'package:flutter/cupertino.dart';

class TextSmallThin extends StatefulWidget {
  final String sLabel;
  final Color cColor;

  const TextSmallThin({required this.sLabel, required this.cColor});

  @override
  _TextSmallThinState createState() => _TextSmallThinState();
}

class _TextSmallThinState extends State<TextSmallThin> {
  @override
  void initState() {
    super.initState();
  }

//66
  @override
  Widget build(BuildContext context) {
    return Text(widget.sLabel,
        maxLines: 1,
        style: TextStyle(
            fontSize: 12,
            color: widget.cColor,
            overflow: TextOverflow.ellipsis)); //CupertinoColors.placeholderText
  }
}
