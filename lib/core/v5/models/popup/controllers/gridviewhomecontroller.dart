import 'package:get/get.dart';

import '../models/fields.dart';

class GridViewHomeController extends GetxController {
  var activeRoute = '/browse'.obs;

  final fields = [
    Fields(label: 'Project Year', datavalue: '2022'),
    Fields(label: 'Project Name', datavalue: 'Ezofis'),
    Fields(label: 'Client', datavalue: '-'),
    Fields(label: 'Location', datavalue: 'Chennai'),
    Fields(label: 'Document Date', datavalue: '16-FEB-2023'),
    Fields(label: 'Property Type', datavalue: 'Single-Family Detached Home'),
    Fields(label: 'Category', datavalue: 'New'),
    Fields(label: 'Project No', datavalue: 'SI-0230-2024')
  ];
  Map<dynamic, dynamic> filedsnew = {
/*    'Foldername': 'testfields',
    'Description': '-',
    'Project Year': '2002',
    'Project name': 'Ezofis',
    'Foldernames': 'testfields',
    'Descriptions': '-',
    'ProjectYearrt': '2002',
    'Projectnames': 'Ezofis',
    'Folder_name': 'testfields',
    'ProjectYears': '2002',
    'Projectname': 'Ezofis'*/
  }.obs;
  Map<dynamic, dynamic> filedsIDwithLabel = {}.obs;
  Map<dynamic, dynamic> filedsIDwithLabelOrg = {}.obs;
}
