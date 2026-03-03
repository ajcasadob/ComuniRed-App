class UpdateUsuarioRequest {
  final String? name;
  final String? email;
  final String? currentPassword;
  final String? password;
  final String? passwordConfirmation;

  UpdateUsuarioRequest({
    this.name,
    this.email,
    this.currentPassword,
    this.password,
    this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (email != null) map['email'] = email;
    if (password != null) {
      map['current_password'] = currentPassword;
      map['password'] = password;
      map['password_confirmation'] = passwordConfirmation;
    }
    return map;
  }
}
