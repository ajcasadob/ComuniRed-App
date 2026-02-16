import 'package:app_mobile/features/login/ui/bloc/login_page_bloc.dart';
import 'package:app_mobile/features/login/widgets/login_form.dart';
import 'package:app_mobile/features/login/widgets/login_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<LoginPageBloc, LoginPageState>(
        listener: (context, state) {
          if (state is LoginPageSuccess) {
            Navigator.pushReplacementNamed(context, '/inicio');
          } else if (state is LoginPageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginPageLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    // 1. Cabecera (Logo y Título)
                    const LoginHeader(),
                    
                    const SizedBox(height: 40),
                    
                    // 2. Formulario (Inputs y Botón)
                    LoginForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isLoading: isLoading,
                    ),
                    
                    // He aumentado un poco el espacio aquí para separar el botón del footer
                    const SizedBox(height: 48),
                    
                    // 3. Footer (Registro) - YA NO HAY REDES SOCIALES EN MEDIO
                    const LoginFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}