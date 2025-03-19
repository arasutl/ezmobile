import 'package:ez/core/components/bottom_menu/tab_data.dart';
import 'package:flutter/material.dart';

import '../../CustomColors.dart';

class BottomBar extends StatefulWidget {
  BottomBar(
      {super.key, required this.currentIndex,
      required this.index,
      this.backgroundColor,
      this.selectedItemColor,
      this.unselectedItemColor,
      this.elevation,
      this.type,
      this.fixedColor,
      this.iconSize,
      this.selectedIconTheme,
      this.unselectedIconTheme,
      this.selectedFontSize,
      this.unselectedFontSize,
      this.selectedLabelStyle,
      this.unselectedLabelStyle,
      required this.items});

  int? currentIndex;
  void Function(int?) index;
  Color? backgroundColor;
  Color? selectedItemColor;
  Color? unselectedItemColor;
  double? elevation;
  BottomNavigationBarType? type;
  Color? fixedColor;
  double? iconSize;
  IconThemeData? selectedIconTheme;
  IconThemeData? unselectedIconTheme;
  double? selectedFontSize;
  double? unselectedFontSize;
  TextStyle? selectedLabelStyle;
  TextStyle? unselectedLabelStyle;
  List<TabItem>? items;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: CustomColors.black, width: 0.1)),
      ),
      child: BottomNavigationBar(
          backgroundColor: widget.backgroundColor,
          type: widget.type,
          selectedItemColor: widget.selectedItemColor,
          currentIndex: widget.currentIndex ?? 0,
          onTap: (index) {
            setState(() {
              widget.index(index);
            });
          },
          selectedFontSize: widget.selectedFontSize ?? 0,
          unselectedFontSize: widget.unselectedFontSize ?? 0,
          items: List.generate(
              widget.items?.length as int,
              (index) => _buildTabItem(
                  widget.items?[index].label as String, widget.items?[index].icon as IconData))),
    );
  }

  BottomNavigationBarItem _buildTabItem(String tabItem, IconData icons) {
    return BottomNavigationBarItem(
      label: tabItem,
      icon: Icon(icons),
    );
  }
}
