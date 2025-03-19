import 'dart:math';

import 'package:flutter/material.dart';

class Fab extends StatelessWidget {
  const Fab({
    Key? key,
    required this.icon,
    required this.onPressed,
    //this.color = BrandColors.primary,
    required this.color,
    required this.sLable,
  }) : super(key: key);

  final Color color;
  final IconData icon;
  final void Function() onPressed;
  final String sLable;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 45,
        child: FloatingActionButton.extended(
          elevation: 5,
          backgroundColor: color,
          onPressed: onPressed,
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                  angle: 180 * pi / 180,
                  child: Icon(
                    icon,
                    color: Colors.white,
                  )),
              SizedBox(
                width: 10,
              ),
              Text(sLable)
            ],
          ),
        ));
  }
}
