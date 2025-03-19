import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TabItem {
  String label;
  IconData icon;
  TabItem(this.label, this.icon);

  static final int kTabItemCount = generateTabList().length;
  static List<TabItem> generateTabList() {
    return [
      TabItem('DashBoard', MdiIcons.fileTree),
      TabItem('Folder', MdiIcons.archiveOutline),
/*      TabItem('DashBoard', MdiIcons.viewDashboard),
      TabItem('Worksapace', MdiIcons.briefcaseOutline),
      TabItem('Folder', MdiIcons.archiveOutline),
      TabItem('Task', MdiIcons.cubeOutline),
      TabItem('Portals', MdiIcons.web)*/
    ];
  }
}
