import 'package:apphormi/login/login.dart';
import 'package:apphormi/pages/inicio/home.dart';

import 'package:apphormi/pages/usuario/usu_actualizar.dart';
import 'package:apphormi/pages/usuario/usuario.dart';
import 'package:apphormi/pages/usuario/usua_agregar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extraccion de datos y edicion',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/agg': (context) => const agregarDatos(),
        '/edit': (context) => const EditarDatos(),
        '/usu': (context) => const Usuario(),
        '/home': (context) => const Home(),
      },
    );
  }
}
