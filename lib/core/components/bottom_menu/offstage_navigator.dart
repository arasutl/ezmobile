import 'package:flutter/material.dart';

import '../../../routes.dart';

class OffstageNavigator {
  static List<GlobalKey<NavigatorState>> getNavigatorKeys({required int ofTabCount}) {
    return List.generate(ofTabCount, (index) => GlobalKey<NavigatorState>());
  }

  static Widget buildOffstageNavigator(
      int index, List<GlobalKey<NavigatorState>> navigatorKeys, int currentIndex) {
    return Offstage(
      offstage: currentIndex != index,
      child: WillPopScope(
          onWillPop: () async {
            final NavigatorState? navigator = navigatorKeys[index].currentState;
            if (navigator != null && navigator.canPop()) {
              navigator.pop();
              return false; // Prevent the app from closing
            }
            return true; // Allow the app to close
          },
          child: Navigator(
            key: navigatorKeys[index],
            initialRoute: AppRoutes.initialRouteForIndex(index),
            onGenerateRoute: AppRoutes.generateRoute,
          )),
    );
  }
}
