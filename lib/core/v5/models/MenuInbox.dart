import 'dart:convert';

class MenuInbox {
  String name = '';
  String id = '';
  String wFormId = '';
  String repositoryId = '';
  var flowJson = '';
  String initiatedBy = '';

  List<MenuInbox> subMenu = [];
  MenuInbox(
      {required this.name,
      required this.subMenu,
      required this.id,
      required this.flowJson,
      required this.wFormId,
      required this.repositoryId,
      required this.initiatedBy});

  MenuInbox.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'].toString();
    wFormId = NullAware(json['wFormId']);
    flowJson = NullAwareFJ(json['flowJson']);
    initiatedBy = NullAware(json['initiatedBy']);

    subMenu.add(MenuInbox(
        id: '${json['id']}_0',
        name: 'Inbox (${json['inboxCount']})',
        wFormId: NullAware(json['wFormId']),
        repositoryId: NullAware(json['repositoryId']),
        flowJson: NullAwareFJ(json['flowJson']),
        initiatedBy: NullAware(json['initiatedBy']),
        subMenu: []));
    subMenu.add(MenuInbox(
        id: '${json['id']}_1',
        name: 'Sent(${json['processCount']})',
        wFormId: NullAware(json['wFormId']),
        repositoryId: NullAware(json['repositoryId']),
        flowJson: NullAwareFJ(json['flowJson']),
        initiatedBy: NullAware(json['initiatedBy']),
        subMenu: []));
    subMenu.add(MenuInbox(
        id: '${json['id']}_2',
        name: 'Stared (0)',
        wFormId: NullAware(json['wFormId']),
        repositoryId: NullAware(json['repositoryId']),
        flowJson: NullAwareFJ(json['flowJson']),
        initiatedBy: NullAware(json['initiatedBy']),
        subMenu: []));
    subMenu.add(MenuInbox(
        id: '${json['id']}_3',
        name: 'Completed (${json['completedCount']})',
        wFormId: NullAware(json['wFormId']),
        repositoryId: NullAware(json['repositoryId']),
        flowJson: NullAwareFJ(json['flowJson']),
        initiatedBy: NullAware(json['initiatedBy']),
        subMenu: []));
  }

  String NullAware(var vtemp) {
    if (vtemp == null) {
      return '';
    } else {
      return jsonEncode(vtemp).toString();
    }
  }

  dynamic NullAwareFJ(var vtemp) {
    if (vtemp == null) {
      return '';
    } else {
      return jsonEncode(vtemp);
    }
  }
}
