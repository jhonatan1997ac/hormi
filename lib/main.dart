import 'package:apphormi/pages/inicio/administrador/Agregacion/agregar_bodeguero.dart';
import 'package:apphormi/pages/inicio/administrador/Agregacion/agregar_vendedor_administrador.dart';
import 'package:apphormi/pages/inicio/administrador/vendedor_administrador.dart';
import 'package:apphormi/pages/inicio/bodega/agregar_material_bodega.dart';
import 'package:apphormi/pages/inicio/bodega/disponibilidad_material_bodega.dart';
import 'package:apphormi/pages/inicio/vendedores/cliente_admin.dart';
import 'package:apphormi/pages/inicio/vendedores/configuracion_admin.dart';
import 'package:apphormi/pages/inicio/vendedores/empleados.dart';
import 'package:apphormi/pages/inicio/bodega/gestion_productos.dart';
import 'package:apphormi/pages/inicio/vendedores/estadisticas/estadisticas_pago.dart';
import 'package:apphormi/pages/inicio/vendedores/estadisticas/fecha_ventas.dart';
import 'package:apphormi/pages/inicio/vendedores/estadisticas/menu_estadisticas.dart';
import 'package:apphormi/pages/inicio/vendedores/historial_venta_admin.dart';
import 'package:apphormi/pages/inicio/vendedores/notificacion_admin.dart';
import 'package:apphormi/pages/inicio/vendedores/vender.dart';
import 'package:apphormi/pages/inicio/vendedores/venta_vendedor.dart';
import 'package:apphormi/pages/inicio/bodega/Disponibilidad_produto.dart';
import 'package:apphormi/pages/inicio/bodega/agregar_producto_bodega.dart';
import 'package:apphormi/pages/inicio/home.dart';
import 'package:apphormi/pages/inicio/administrador/bodeguero_administrador.dart';
import 'package:apphormi/pages/inicio/administrador/pedido_administrador.dart';
import 'package:apphormi/pages/inicio/administrador/producto_administrador.dart';
import 'package:apphormi/pages/inicio_secion/inicio.dart';

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
        '/home': (context) => const Home(),
        '/logpag': (context) => const Inicio(),
        '/gestprod': (context) => GestionProductos(),
        '/ventas': (context) => const Ventas(),
        '/historial_ventas': (context) => HistorialVentas(),
        '/empleados': (context) => const Empleados(),
        '/clientes': (context) => const Clientes(),
        '/configuracion': (context) => Configuracion(),
        '/notificacion': (context) => Notificacion(),
        '/productosadministrador': (context) => const ProductosAdministrador(),
        '/pedidovendedor': (context) => PedidoVendedor(),
        '/bodeguero': (context) => const BodegueroAdmin(),
        '/agregarproducto': (context) => const AgregarProducto(),
        '/disponibilidadproducto': (context) => const DisponibilidadProducto(),
        '/disponibilidadmaterial': (context) => const DisponibilidadMaterial(),
        '/agregarbodeguero': (context) => const AgregarBodeguero(),
        '/vendedoradministrador': (context) => const VendedorAdministrador(),
        '/agregarvendedor': (context) => const AgregarVendedor(),
        '/estadisticapago': (context) => const Estadisticapago(),
        '/menuestadisticas': (context) => const MenuEstadisticas(),
        '/fechaventas': (context) => const FechaVentas(),
        '/vender': (context) => Vender(),
        '/agregarmaterial': (context) => const AgregarMaterial(),
      },
    );
  }
}
