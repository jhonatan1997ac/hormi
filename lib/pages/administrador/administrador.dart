import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../inicio_secion/inicio.dart';

class Administrador extends StatefulWidget {
  const Administrador({Key? key}) : super(key: key);

  @override
  State<Administrador> createState() => _AdministradorState();
}

class _AdministradorState extends State<Administrador> {
  @override
  Widget build(BuildContext context) {
    return const AdminHome();
  }
}

class AdminHome extends StatelessWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablero de Control'),
        leading: IconButton(
          onPressed: () {
            logout(context);
          },
          icon: const Icon(
            Icons.logout,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            HomeCard(
              title: 'Gestión de Productos',
              icon: Icons.inventory,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/gestprod');
              },
            ),
            HomeCard(
              title: 'Gestión de Clientes',
              icon: Icons.people,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/usu');
              },
            ),
            HomeCard(
              title: 'Realizar Ventas',
              icon: Icons.shopping_cart,
              color: Colors.orange,
              onTap: () {
                // Navigator.pushNamed(context, '/realizar_ventas');
              },
            ),
            HomeCard(
              title: 'Historial de Ventas',
              icon: Icons.receipt,
              color: Colors.purple,
              onTap: () {
                // Navigator.pushNamed(context, '/historial_ventas');
              },
            ),
            HomeCard(
              title: 'Gestión de Empleados',
              icon: Icons.person,
              color: Colors.teal,
              onTap: () {
                // Navigator.pushNamed(context, '/gestion_empleados');
              },
            ),
            HomeCard(
              title: 'Configuración del Sistema',
              icon: Icons.settings,
              color: Colors.indigo,
              onTap: () {
                // Navigator.pushNamed(context, '/configuracion_sistema');
              },
            ),
            HomeCard(
              title: 'Notificaciones y Mensajes',
              icon: Icons.notifications,
              color: Colors.red,
              onTap: () {
                // Navigator.pushNamed(context, '/notificaciones_mensajes');
              },
            ),
            HomeCard(
              title: 'Cerrar Sesión',
              icon: Icons.exit_to_app,
              color: Colors.deepPurple,
              onTap: () {
                logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Inicio(),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HomeCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        elevation: 4.0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48.0,
                color: Colors.white,
              ),
              const SizedBox(height: 8.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
