import 'package:ez/core/utils/strings.dart';

extension FieldValidation on String {
  static String validateformFields(var panels, var controls) {
    String errorMessage = "";

    for (var panel in panels) {
      final index = controls.indexWhere((f) => f.jsonId == panel.id);
      if (index >= 0 && controls[index].isMandatory) {
        errorMessage += "${controls[index].name} ${Strings.alert_required_field}";
        break;
      }
    }
    return errorMessage;
  }

  bool get isValidEmail {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }

  bool get isValidPassword {
    final passwordRegExp = RegExp(r'^((?=.*\d)(?=.*[a-zA-Z])[a-zA-Z0-9!@#$%&*]{6,20})$/pre>');
    return passwordRegExp.hasMatch(this);
  }

  bool get isValidPhoneNumber {
    return RegExp(r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$)')
        .hasMatch(this ?? '');
  }

  bool get validateStructure {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(this);
  }
}
