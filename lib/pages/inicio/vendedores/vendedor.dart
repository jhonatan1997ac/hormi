import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../inicio_secion/inicio.dart';

class Vendedor extends StatefulWidget {
  const Vendedor({Key? key}) : super(key: key);

  @override
  State<Vendedor> createState() => _VendedorState();
}

class _VendedorState extends State<Vendedor> {
  @override
  Widget build(BuildContext context) {
    return const VendedorHome();
  }
}

class VendedorHome extends StatelessWidget {
  const VendedorHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablero de Control de ventas'),
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
              title: 'Realizar Ventas',
              icon: Icons.shopping_cart,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/ventas');
              },
            ),
            HomeCard(
              title: 'Historial de Ventas',
              icon: Icons.receipt,
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/historial_ventas');
              },
            ),
            HomeCard(
              title: 'Estadistica',
              icon: Icons.dashboard,
              color: Color.fromARGB(255, 14, 61, 22),
              onTap: () {
                Navigator.pushNamed(context, '/menuestadisticas');
              },
            ),
            HomeCard(
              title: 'Reclamaciones',
              icon: Icons.apps_outage,
              color: Colors.indigo,
              onTap: () {
                Navigator.pushNamed(context, '/reclamaciones');
              },
            ),
            HomeCard(
              title: 'Clientes',
              icon: Icons.account_circle_outlined,
              color: Colors.red,
              onTap: () {
                Navigator.pushNamed(context, '/clientes');
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
