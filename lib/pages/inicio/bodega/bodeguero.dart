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
              color: const Color.fromARGB(255, 28, 168, 168),
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
              color: const Color.fromARGB(255, 243, 159, 33),
              onTap: () {
                Navigator.pushNamed(context, '/disponibilidadproducto');
              },
            ),
            HomeCard(
              title: 'Agregar material ',
              icon: Icons.inventory_outlined,
              color: const Color.fromARGB(255, 102, 9, 82),
              onTap: () {
                Navigator.pushNamed(context, '/agregarmaterial');
              },
            ),
            HomeCard(
              title: 'Disponibilidad material',
              icon: Icons.data_thresholding,
              color: const Color.fromARGB(255, 114, 173, 18),
              onTap: () {
                Navigator.pushNamed(context, '/disponibilidadmaterial');
              },
            ),
            HomeCard(
              title: 'Ordenes',
              icon: Icons.add_shopping_cart,
              color: const Color.fromARGB(255, 32, 32, 85),
              onTap: () {
                Navigator.pushNamed(context, '/ordenes');
              },
            ),
            HomeCard(
              title: 'Detalle de Ordenes',
              icon: Icons.shopping_bag_outlined,
              color: const Color.fromARGB(255, 36, 85, 32),
              onTap: () {
                Navigator.pushNamed(context, '/detalleorden');
              },
            ),
            HomeCard(
              title: 'Provedores',
              icon: Icons.supervised_user_circle,
              color: const Color.fromARGB(255, 53, 179, 179),
              onTap: () {
                Navigator.pushNamed(context, '/proveedor');
              },
            ),
            HomeCard(
              title: 'Historial de Inventarios',
              icon: Icons.history_toggle_off_rounded,
              color: const Color.fromARGB(255, 183, 231, 11),
              onTap: () {
                Navigator.pushNamed(context, '/historialinventario');
              },
            ),
            HomeCard(
              title: 'Categorias producto',
              icon: Icons.label_important_rounded,
              color: const Color.fromARGB(255, 177, 103, 53),
              onTap: () {
                Navigator.pushNamed(context, '/categoriaproducto');
              },
            ),
            HomeCard(
              title: 'Promoción',
              icon: Icons.local_offer_sharp,
              color: const Color.fromARGB(255, 177, 53, 90),
              onTap: () {
                Navigator.pushNamed(context, '/promocion');
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
