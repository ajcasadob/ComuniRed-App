import 'package:app_mobile/core/service/login_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:app_mobile/features/login/ui/bloc/login_page_bloc.dart';
import 'package:app_mobile/features/login/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


void main() async {
  // A. Asegura que el motor de Flutter esté listo (necesario para el Storage)
  WidgetsFlutterBinding.ensureInitialized();

  // B. PREPARACIÓN DE DEPENDENCIAS (Inyección manual)
  // 1. Instanciamos la base de datos segura
  const secureStorage = FlutterSecureStorage();
  
  // 2. Instanciamos nuestro wrapper de storage
  const tokenStorage = TokenStorage(secureStorage);
  
  // 3. Instanciamos el servicio (inyectándole el storage)
  final loginService = LoginService(tokenStorage);

  // C. Arrancamos la App pasando el servicio
  runApp(MyApp(loginService: loginService));
}

class MyApp extends StatelessWidget {
  final LoginService loginService;

  const MyApp({super.key, required this.loginService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Comunidad Vecinal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // DEFINIMOS LA PÁGINA INICIAL
      home: BlocProvider(
        // D. Aquí creamos el BLoC y le inyectamos el servicio
        create: (context) => LoginPageBloc(loginService),
        child: const LoginPage(),
      ),
      // DEFINIMOS LAS RUTAS
      routes: {
        // E. Una página "Home" simple para probar que el login funcionó
        '/home': (context) => const Scaffold(
          body: Center(
            child: Text(
              "¡LOGIN EXITOSO!\nBienvenido al Home", 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      },
    );
  }
}