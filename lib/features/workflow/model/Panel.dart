import 'PanelX.dart';
import 'SecondaryPanel.dart';
import 'Settings.dart';

class Panel {
  bool? isDeleted;
  List<PanelX>? panels;
  List<SecondaryPanel>? secondaryPanels;
  Settings? settings;
  String? uid;

  Panel(
      {this.isDeleted,
      this.panels,
      this.secondaryPanels,
      this.settings,
      this.uid});

  factory Panel.fromJson(Map<String, dynamic> json) {
    var panel = Panel(
      isDeleted: json['isDeleted'],
      panels: json['panels'] != null
          ? (json['panels'] as List).map((i) => PanelX.fromJson(i)).toList()
          : null,
      secondaryPanels: json['secondaryPanels'] != null
          ? (json['secondaryPanels'] as List)
              .map((i) => SecondaryPanel.fromJson(i))
              .toList()
          : null,
      settings:
          json['settings'] != null ? Settings.fromJson(json['settings']) : null,
      uid: json['uid'],
    );
    return panel;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isDeleted'] = isDeleted;
    data['uid'] = uid;
    if (panels != null) {
      data['panels'] = panels?.map((v) => v.toJson()).toList();
    }
    if (secondaryPanels != null) {
      data['secondaryPanels'] =
          secondaryPanels?.map((v) => v.toJson()).toList();
    }
    if (settings != null) {
      data['settings'] = settings?.toJson();
    }
    return data;
  }
}
