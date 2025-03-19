import 'package:flutter/material.dart';

import 'LabelAlertView.dart';

class Labels extends StatefulWidget {
  final String sLabel;
  final bool bRequired;

  const Labels({super.key, required this.sLabel, required this.bRequired});

  @override
  _LabelsState createState() => _LabelsState();
}

class _LabelsState extends State<Labels> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
              onTap: () => {
                    //hasTextOverflow(texts:'',fontWeight: FontWeight.w500,fontSize: 16,maxWidth: double.infinity,fontFamily:'Outfit',maxLines: 4,minWidth: 0 )
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => LabelAlertView(widget.sLabel))
                  },
              child: Container(
                child: DefaultTextStyle(
                    style: const TextStyle(decoration: TextDecoration.none),
                    child: RichText(
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            color: Color(0xff64748b),
                            //64748b
                            fontWeight: FontWeight.w500),
                        children: <TextSpan>[
                          TextSpan(text: widget.sLabel),
                          !widget.bRequired
                              ? const TextSpan(
                                  text: '',
                                  /*text: ' (optional)',*/
                                  style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 14,
                                      color: Color(0xff94a3b8),
                                      fontWeight: FontWeight.w400))
                              : const TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 14,
                                      color: Color(0xffff164a),
                                      fontWeight: FontWeight.w400)),
                        ],
                      ),
                    )),
              )),
        ),
      ],
    );
  }

  bool hasTextOverflow(String texts, TextStyle style,
      {fontFamily = 'Outfit',
      fontWeight = FontWeight.w500,
      fontSize = 16,
      double minWidth = 0,
      double maxWidth = double.infinity,
      int maxLines = 4}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: texts, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }
}
