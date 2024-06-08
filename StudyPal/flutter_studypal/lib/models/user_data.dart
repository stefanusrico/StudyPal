class UserData {
  final String? id;
  final String? password;
  final String? gender;
  final DateTime? birthDate;
  final String? lastName;
  final String? firstName;
  final String? email;
  final String? status;

  UserData(
      {this.id,
      this.password,
      this.gender,
      this.birthDate,
      this.lastName,
      this.firstName,
      this.email,
      this.status});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      password: json['password'],
      gender: json['gender'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      lastName: json['last_name'],
      firstName: json['first_name'],
      email: json['email'],
      status: json['status'],
    );
  }
}
