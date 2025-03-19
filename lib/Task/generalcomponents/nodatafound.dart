import 'package:ez/Task/utils/AppColors.dart';
import 'package:ez/Task/utils/stringvalues.dart';
import 'package:flutter/material.dart';

class NoDataFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        child: Align(alignment: Alignment.center, child: Text(StringValues.sNoItems)));
  }
}
