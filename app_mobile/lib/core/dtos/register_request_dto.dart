class RegisterRequestDto {

  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  RegisterRequestDto({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }


}