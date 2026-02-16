import 'package:app_mobile/features/login/ui/bloc/login_page_bloc.dart';
import 'package:app_mobile/features/login/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobile/core/dtos/login_request_dto.dart';
// Extraje el input a otro archivo pequeño

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomInputField(
            label: 'Correo electrónico',
            placeholder: 'nombre@ejemplo.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomInputField(
            label: 'Contraseña',
            placeholder: '••••••••',
            controller: passwordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              if (value.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        final request = LoginRequestDto(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        context.read<LoginPageBloc>().add(
                          IniciarSesion(request),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Iniciar Sesión',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
