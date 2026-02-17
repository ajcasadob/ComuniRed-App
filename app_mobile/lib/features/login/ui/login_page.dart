import 'package:app_mobile/features/avisos/ui/avisos_page.dart';
import 'package:app_mobile/features/login/ui/bloc/login_page_bloc.dart';
import 'package:app_mobile/features/login/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_mobile/core/dtos/login_request_dto.dart';
import 'package:app_mobile/core/service/login_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginPageBloc loginPageBloc;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage);
    final loginService = LoginService(tokenStorage);
    loginPageBloc = LoginPageBloc(loginService);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    loginPageBloc.close();
    super.dispose();
  }

  void _iniciarSesion() {
    if (_formKey.currentState!.validate()) {
      final request = LoginRequestDto(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      loginPageBloc.add(IniciarSesion(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: loginPageBloc,
      child: BlocListener<LoginPageBloc, LoginPageState>(
        listener: (context, state) {
          if (state is LoginPageSuccess) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context)=> const AvisosPage()));
          } else if (state is LoginPageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: BlocBuilder<LoginPageBloc, LoginPageState>(
              builder: (context, state) {
                final isLoading = state is LoginPageLoading;
                return LoginForm(
                  formKey: _formKey,
                  emailController: emailController,
                  passwordController: passwordController,
                  isLoading: isLoading,
                  onSubmit: _iniciarSesion,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
