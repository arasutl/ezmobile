import 'package:ez/features/workflow/model/AutoGenerateValue.dart';
import 'package:ez/features/workflow/model/MatrixColumnX.dart';
import 'package:ez/features/workflow/model/MatrixRowX.dart';
import 'package:ez/features/workflow/model/MatrixTypeSettingsX.dart';
import 'package:ez/features/workflow/model/NestedListTypeSettingsX.dart';
import 'package:ez/features/workflow/model/NestedX.dart';
import 'package:ez/features/workflow/model/TabX.dart';
import 'package:ez/features/workflow/model/TableColumn.dart';

class SpecificX {
  List<String>? additionalLoginTypes;
  bool? allowHalfRating;
  bool? allowMultipleFiles;
  bool? allowMultipleSignatures;
  bool? allowToAddNewOptions;
  AutoGenerateValue? autoGenerateValue;
  var customDefaultValue;
  String? customOptions;
  String? defaultValue;
  List<Object>? fibFields;
  String? formula;
  String? loginType;
  String? mappedColumnId;
  String? mappedFieldId;
  String? masterTable;
  String? masterTableColumn;
  List<MatrixColumnX>? matrixColumns;
  List<MatrixRowX>? matrixRows;
  String? matrixType;
  MatrixTypeSettingsX? matrixTypeSettings;
  List<NestedX>? nestedList;
  String? nestedListFieldType;
  List<Object>? nestedListItemsPerLine;
  int? nestedListMaxLevel;
  NestedListTypeSettingsX? nestedListTypeSettings;
  int? optionsPerLine;
  String? optionsType;
  String? popupTriggerType;
  bool? qrValue;
  String? ratingIcon;
  int? ratingIconCount;
  String? secondaryPanel;
  String? separateOptionsUsing;
  bool? showColumnTotal;
  List<TabX>? tabList;
  List<dynamic>? tableColumns;
  int? tableFixedRowCount;
  List<dynamic>? tableFixedRowLabels;
  String? tableRowsType;
  String? textContent;
  int? masterFormId;
  String? masterFormColumn;
  String? masterFormParentColumn;
  String? predefinedTable;
  String? predefinedTableColumn;
  int? repositoryId;
  String? repositoryField;
  String? repositoryFieldParent;
  String? parentDateField;
  String? parentOptionField;
  String? defaultValueInSelectField;
  List<dynamic>? dateFieldOptionSettings;
  int? parentFieldsDays;
  List<dynamic>? masterFormTableColumns;

  SpecificX(
      {this.additionalLoginTypes,
      this.allowHalfRating,
      this.allowMultipleFiles,
      this.allowMultipleSignatures,
      this.allowToAddNewOptions,
      this.autoGenerateValue,
      this.customDefaultValue,
      this.customOptions,
      this.defaultValue,
      this.fibFields,
      this.formula,
      this.loginType,
      this.mappedColumnId,
      this.mappedFieldId,
      this.masterTable,
      this.masterTableColumn,
      this.matrixColumns,
      this.matrixRows,
      this.matrixType,
      this.matrixTypeSettings,
      this.nestedList,
      this.nestedListFieldType,
      this.nestedListItemsPerLine,
      this.nestedListMaxLevel,
      this.nestedListTypeSettings,
      this.optionsPerLine,
      this.optionsType,
      this.popupTriggerType,
      this.qrValue,
      this.ratingIcon,
      this.ratingIconCount,
      this.secondaryPanel,
      this.separateOptionsUsing,
      this.showColumnTotal,
      this.tabList,
      this.tableColumns,
      this.tableFixedRowCount,
      this.tableFixedRowLabels,
      this.tableRowsType,
      this.masterFormId,
      this.masterFormColumn,
      this.masterFormParentColumn,
      this.textContent,
      this.predefinedTable,
      this.predefinedTableColumn,
      this.repositoryId,
      this.repositoryField,
      this.repositoryFieldParent,
      this.parentDateField,
      this.parentOptionField,
      this.defaultValueInSelectField,
      this.dateFieldOptionSettings,
      this.parentFieldsDays,
      this.masterFormTableColumns});

  factory SpecificX.fromJson(Map<String, dynamic> json) {
    return SpecificX(
      additionalLoginTypes: json['additionalLoginTypes'] != null
          ? List<String>.from(json['additionalLoginTypes'])
          : null,
      allowHalfRating: json['allowHalfRating'],
      allowMultipleFiles: json['allowMultipleFiles'],
      allowMultipleSignatures: json['allowMultipleSignatures'],
      allowToAddNewOptions: json['allowToAddNewOptions'],
      autoGenerateValue: json['autoGenerateValue'] != null
          ? AutoGenerateValue.fromJson(json['autoGenerateValue'])
          : null,
      customDefaultValue: json['customDefaultValue'],
      customOptions: json['customOptions'],
      defaultValue: json['defaultValue'],
      fibFields: json['fibFields'] != null
          ? (json['fibFields'] as List).map((i) => TableColumn.fromJson(i)).toList()
          : null,
      formula: json['formula'],
      loginType: json['loginType'],
      mappedColumnId: json['mappedColumnId'],
      mappedFieldId: json['mappedFieldId'],
      masterTable: json['masterTable'],
      masterTableColumn: json['masterTableColumn'],
      matrixColumns: json['matrixColumns'] != null
          ? (json['matrixColumns'] as List).map((i) => MatrixColumnX.fromJson(i)).toList()
          : null,
      matrixRows: json['matrixRows'] != null
          ? (json['matrixRows'] as List).map((i) => MatrixRowX.fromJson(i)).toList()
          : null,
      matrixType: json['matrixType'],
      matrixTypeSettings: json['matrixTypeSettings'] != null
          ? MatrixTypeSettingsX.fromJson(json['matrixTypeSettings'])
          : null,
      nestedList: json['nestedList'] != null
          ? (json['nestedList'] as List).map((i) => NestedX.fromJson(i)).toList()
          : null,
      nestedListFieldType: json['nestedListFieldType'],
      nestedListItemsPerLine: [],
      nestedListMaxLevel: json['nestedListMaxLevel'],
      nestedListTypeSettings: json['nestedListTypeSettings'] != null
          ? NestedListTypeSettingsX.fromJson(json['nestedListTypeSettings'])
          : null,
      optionsPerLine: json['optionsPerLine'],
      optionsType: json['optionsType'],
      popupTriggerType: json['popupTriggerType'],
      qrValue: json['qrValue'],
      ratingIcon: json['ratingIcon'],
      ratingIconCount: json['ratingIconCount'],
      secondaryPanel: json['secondaryPanel'],
      separateOptionsUsing: json['separateOptionsUsing'],
      showColumnTotal: json['showColumnTotal'],
      tabList: json['tabList'] != null
          ? (json['tabList'] as List).map((i) => TabX.fromJson(i)).toList()
          : null,
      tableColumns: json['tableColumns'] != null
          ? (json['tableColumns'] as List).map((i) => TableColumn.fromJson(i)).toList()
          : null,
      tableFixedRowCount: json['tableFixedRowCount'],
      tableFixedRowLabels: [],
      tableRowsType: json['tableRowsType'],
      textContent: json['textContent'],
      masterFormId: json['masterFormId'],
      masterFormColumn: json['masterFormColumn'],
      masterFormParentColumn: json['masterFormParentColumn'],
      predefinedTable: json['predefinedTable'],
      predefinedTableColumn: json['predefinedTableColumn'],
      repositoryId: json['repositoryId'],
      repositoryField: json['repositoryField'],
      repositoryFieldParent: json['repositoryFieldParent'],
      parentDateField: json['parentDateField'],
      parentOptionField: json['parentOptionField'],
      defaultValueInSelectField: json['defaultValueInSelectField'],
      dateFieldOptionSettings: json['dateFieldOptionSettings'],
      parentFieldsDays: json['parentFieldsDays'],
      masterFormTableColumns: json['masterFormTableColumns'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['allowHalfRating'] = allowHalfRating;
    data['allowMultipleFiles'] = allowMultipleFiles;
    data['allowMultipleSignatures'] = allowMultipleSignatures;
    data['allowToAddNewOptions'] = allowToAddNewOptions;
    data['customDefaultValue'] = customDefaultValue;
    data['customOptions'] = customOptions;
    data['defaultValue'] = defaultValue;
    data['formula'] = formula;
    data['loginType'] = loginType;
    data['mappedColumnId'] = mappedColumnId;
    data['mappedFieldId'] = mappedFieldId;
    data['masterTable'] = masterTable;
    data['masterTableColumn'] = masterTableColumn;
    data['matrixType'] = matrixType;
    data['nestedListFieldType'] = nestedListFieldType;
    data['nestedListMaxLevel'] = nestedListMaxLevel;
    data['optionsPerLine'] = optionsPerLine;
    data['optionsType'] = optionsType;
    data['popupTriggerType'] = popupTriggerType;
    data['qrValue'] = qrValue;
    data['ratingIcon'] = ratingIcon;
    data['ratingIconCount'] = ratingIconCount;
    data['secondaryPanel'] = secondaryPanel;
    data['separateOptionsUsing'] = separateOptionsUsing;
    data['showColumnTotal'] = showColumnTotal;
    data['tableFixedRowCount'] = tableFixedRowCount;
    data['tableRowsType'] = tableRowsType;
    data['textContent'] = textContent;
    data['defaultValueInSelectField'] = defaultValueInSelectField;
    if (additionalLoginTypes != null) {
      data['additionalLoginTypes'] = additionalLoginTypes;
    }
    if (autoGenerateValue != null) {
      data['autoGenerateValue'] = autoGenerateValue?.toJson();
    }
    if (fibFields != null) {
      data['fibFields'] = [];
    }
    if (matrixColumns != null) {
      data['matrixColumns'] = matrixColumns?.map((v) => v.toJson()).toList();
    }
    if (matrixRows != null) {
      data['matrixRows'] = matrixRows?.map((v) => v.toJson()).toList();
    }
    if (matrixTypeSettings != null) {
      data['matrixTypeSettings'] = matrixTypeSettings?.toJson();
    }
    if (nestedList != null) {
      data['nestedList'] = nestedList?.map((v) => v.toJson()).toList();
    }
    if (nestedListItemsPerLine != null) {
      data['nestedListItemsPerLine'] = [];
    }
    if (nestedListTypeSettings != null) {
      data['nestedListTypeSettings'] = nestedListTypeSettings?.toJson();
    }
    if (tabList != null) {
      data['tabList'] = tabList?.map((v) => v.toJson()).toList();
    }
    if (tableColumns != null) {
      data['tableColumns'] = [];
    }
    if (tableFixedRowLabels != null) {
      data['tableFixedRowLabels'] = [];
    }
    return data;
  }
}
