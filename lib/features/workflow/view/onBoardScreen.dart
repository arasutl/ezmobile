import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/CustomColors.dart';
import '../../../core/components/bottom_menu/bottom_nav_bar.dart';
import '../../../core/components/bottom_menu/offstage_navigator.dart';
import '../../../core/components/bottom_menu/tab_data.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  // Generating UniqueKeys for each and every TabItem
  final List<GlobalKey<NavigatorState>> _navigatorKeys =
      OffstageNavigator.getNavigatorKeys(ofTabCount: TabItem.kTabItemCount);
  // _currentIndex to identify at which tab user at
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          _showBackDialog();
        },
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
              children: List.generate(
            _navigatorKeys.length,
            (index) =>
                OffstageNavigator.buildOffstageNavigator(index, _navigatorKeys, _currentIndex),
          )),
          bottomNavigationBar: _getBottomNavigationBar(),
        ));
  }

  BottomBar _getBottomNavigationBar() {
    return BottomBar(
        backgroundColor: CustomColors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: CustomColors.sapphireBlue,
        currentIndex: _currentIndex,
        index: (value) {
          setState(() {
            _currentIndex = value ?? 0;
          });
        },
        items: TabItem.generateTabList());
  }

  void _showBackDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit!'),
          content: const Text(
            'Do You close the Application?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: CustomColors.ezpurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(width: 2, color: CustomColors.ezpurple)),
              ),
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: CustomColors.ezpurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(width: 2, color: CustomColors.ezpurple)),
              ),
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
          ],
        );
      },
    );
  }
}
