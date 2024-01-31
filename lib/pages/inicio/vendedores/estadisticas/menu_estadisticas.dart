import 'package:apphormi/pages/inicio/vendedores/vendedor.dart';
import 'package:apphormi/pages/inicio_secion/inicio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MenuEstadisticas extends StatefulWidget {
  const MenuEstadisticas({Key? key}) : super(key: key);

  @override
  State<MenuEstadisticas> createState() => _MenuEstadisticasState();
}

class _MenuEstadisticasState extends State<MenuEstadisticas> {
  @override
  Widget build(BuildContext context) {
    return const MenuEstadisticasHome();
  }
}

class MenuEstadisticasHome extends StatelessWidget {
  const MenuEstadisticasHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escoja la Estadistica'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const VendedorHome(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
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
              title: 'Estadísticas de pago',
              icon: Icons.pie_chart,
              color: Color.fromARGB(255, 60, 59, 155),
              onTap: () {
                Navigator.pushNamed(context, '/estadisticapago');
              },
            ),
            HomeCard(
              title: 'Estadistica de fecha de ventas',
              icon: Icons.pie_chart_outline_rounded,
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/fechaventas');
              },
            ),
            HomeCard(
              title: 'Estadistica del producto vendido',
              icon: Icons.pie_chart_outline_rounded,
              color: const Color.fromARGB(255, 14, 61, 22),
              onTap: () {
                Navigator.pushNamed(context, '/estadisticas');
              },
            ),
            HomeCard(
              title: 'Configuración del Sistema',
              icon: Icons.pie_chart,
              color: Colors.indigo,
              onTap: () {
                Navigator.pushNamed(context, '/configuracion');
              },
            ),
            HomeCard(
              title: 'Notificaciones y Mensajes',
              icon: Icons.pie_chart,
              color: Colors.red,
              onTap: () {
                Navigator.pushNamed(context, '/notificacion');
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
