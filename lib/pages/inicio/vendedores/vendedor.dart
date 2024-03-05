// ignore_for_file: use_build_context_synchronously

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
        title: const Text(
          'Tablero de Control de Ventas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () {
            logout(context);
          },
          icon: const Icon(
            Icons.logout,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/carga.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              HomeCard(
                title: 'Realizar Ventas',
                icon: Icons.shopping_cart,
                color: Colors.blueGrey[900]!,
                onTap: () {
                  Navigator.pushNamed(context, '/ventas');
                },
              ),
              HomeCard(
                title: 'Historial de Ventas',
                icon: Icons.receipt,
                color: Colors.deepPurple[600]!,
                onTap: () {
                  Navigator.pushNamed(context, '/historial_ventas');
                },
              ),
              HomeCard(
                title: 'Estadísticas',
                icon: Icons.dashboard,
                color: Colors.teal[600]!,
                onTap: () {
                  Navigator.pushNamed(context, '/menuestadisticas');
                },
              ),
              HomeCard(
                title: 'Reclamaciones',
                icon: Icons.error_outline,
                color: Colors.red[600]!,
                onTap: () {
                  Navigator.pushNamed(context, '/reclamaciones');
                },
              ),
              // HomeCard(
              //   title: 'carrito de compra',
              //   icon: Icons.shopping_cart,
              //   color: Colors.orange[600]!,
              //   onTap: () {
              //     Navigator.pushNamed(context, '/carritodecompras');
              //   },
              // ),
              // HomeCard(
              //   title: 'Gps',
              //   icon: Icons.group,
              //   color: const Color.fromARGB(255, 74, 105, 16),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/mapagps');
              //   },
              // ),
              HomeCard(
                title: 'Cerrar Sesión',
                icon: Icons.exit_to_app,
                color: Colors.grey[600]!,
                onTap: () {
                  logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48.0,
                color: Colors.white,
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18.0,
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
