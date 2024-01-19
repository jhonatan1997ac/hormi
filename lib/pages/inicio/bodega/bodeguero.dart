import 'package:apphormi/pages/inicio_secion/inicio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Bodeguero extends StatefulWidget {
  const Bodeguero({Key? key}) : super(key: key);

  @override
  State<Bodeguero> createState() => _BodegueroState();
}

class _BodegueroState extends State<Bodeguero> {
  @override
  Widget build(BuildContext context) {
    return const Bodeguero();
  }
}

class BodegueroHome extends StatelessWidget {
  const BodegueroHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bodeguero'),
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
              color: Color.fromARGB(255, 28, 168, 168),
              onTap: () {
                Navigator.pushNamed(context, '/gestprod');
              },
            ),
            HomeCard(
              title: 'Agregar Productos',
              icon: Icons.inventory_sharp,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/agregarproducto');
              },
            ),
            HomeCard(
              title: 'Disponibilidad de producto',
              icon: Icons.check_circle,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/disponibilidadproducto');
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
