import 'package:apphormi/pages/inicio/Inicio/inicio_secion.dart';
import 'package:apphormi/pages/inicio/home.dart';
import 'package:apphormi/pages/inicio/usabilidad/calendario.dart';
import 'package:apphormi/pages/inicio/usabilidad/catalogo.dart';
import 'package:apphormi/pages/inicio/usabilidad/configuracion.dart';
import 'package:apphormi/pages/inicio/usabilidad/cotizacion.dart';
import 'package:apphormi/pages/inicio/usabilidad/factura.dart';
import 'package:apphormi/pages/inicio/usabilidad/presupuesto.dart';
import 'package:apphormi/pages/inicio/usabilidad/soporte.dart';
import 'package:apphormi/pages/loging/login.dart';

import 'package:apphormi/pages/usuario/usuario.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error al inicializar Firebase: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extraccion de datos y edicion',
      debugShowCheckedModeBanner: false,
      initialRoute: '/logpag',
      routes: {
        '/usu': (context) => const Usuario(),
        '/home': (context) => const Home(),
        '/conf': (context) => const ConfiguracionPage(),
        '/pres': (context) => const Presupuesto(),
        '/cale': (context) => const Calendario(),
        '/cata': (context) => Catalogo(),
        '/coti': (context) => const CotizacionesScreen(),
        '/fact': (context) => const FacturacionScreen(),
        '/sopor': (context) => const SoporteScreen(),
        '/seci': (context) => const Secion(),
        '/logpag': (context) => const LoginPage(),
      },
    );
  }
}
