import 'package:ez/core/utils/extension+Strings.dart';

class LoginRequest {
  String? email;
  String? otp;
  String? password;
  String? portalId;
  String? tenantId;
  int? formId;
  List<String>? emailColumn;
  String? passwordColumn;
  String? nameColumn;
  String? userType;
  String? loggedFrom;

  // Constructor
  LoginRequest({
    this.email,
    this.otp,
    this.password,
    this.portalId,
    this.tenantId,
    this.formId,
    this.emailColumn,
    this.passwordColumn,
    this.nameColumn,
    this.userType,
    this.loggedFrom,
  });

  // Factory method to create an object from JSON
  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'],
      otp: json['otp'],
      password: json['password'],
      portalId: json['portalId'],
      tenantId: json['tenantId'],
      formId: json['formId'],
      emailColumn: List<String>.from(json['emailColumn'] ?? []),
      passwordColumn: json['passwordColumn'],
      nameColumn: json['nameColumn'],
      userType: json['userType'],
      loggedFrom: json['loggedFrom'],
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['otp'] = otp;
    data['password'] = password;
    data['portalId'] = portalId;
    data['tenantId'] = tenantId;
    data['formId'] = formId;
    data['emailColumn'] = emailColumn;
    data['passwordColumn'] = passwordColumn;
    data['nameColumn'] = nameColumn;
    data['userType'] = userType;
    data['loggedFrom'] = loggedFrom;
    return data;
  }

  Future<bool> usernamefieldsValidation() async {
    if (email!.isValidEmail) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> passwordfieldsValidation() async {
    if (password!.validateStructure) {
      return true;
    } else {
      return false;
    }
  }
}
