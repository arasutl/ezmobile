class UserDetails {
  final String id;
  final String firstName, lastName, profileUrl, email, role;
  final String tenantId;

  UserDetails(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.role,
      required this.profileUrl,
      required this.tenantId});

  factory UserDetails.empty() => UserDetails(
      id: '', firstName: '', lastName: '', email: '', role: '', profileUrl: '', tenantId: '');

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
        id: json['id'].toString(),
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        role: json['role'],
        profileUrl: json['avatar'],
        tenantId: json['tenantId'].toString());
  }
}
