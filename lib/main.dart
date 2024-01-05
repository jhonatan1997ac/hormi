import 'package:apphormi/login/login.dart';
import 'package:apphormi/pages/inicio/Inicio/inicio_secion.dart';
import 'package:apphormi/pages/inicio/home.dart';
import 'package:apphormi/pages/inicio/usabilidad/calendario.dart';
import 'package:apphormi/pages/inicio/usabilidad/catalogo.dart';
import 'package:apphormi/pages/inicio/usabilidad/configuracion.dart';
import 'package:apphormi/pages/inicio/usabilidad/cotizacion.dart';
import 'package:apphormi/pages/inicio/usabilidad/factura.dart';
import 'package:apphormi/pages/inicio/usabilidad/presupuesto.dart';
import 'package:apphormi/pages/inicio/usabilidad/soporte.dart';
import 'package:apphormi/pages/usuario/usu_actualizar.dart';
import 'package:apphormi/pages/usuario/usuario.dart';
import 'package:apphormi/pages/usuario/usua_agregar.dart';
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
        '/': (context) => const HomeScreen(),
        '/agg': (context) => const agregarDatos(),
        '/edit': (context) => const EditarDatos(),
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
      },
    );
  }
}
