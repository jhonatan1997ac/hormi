// ignore_for_file: use_build_context_synchronously

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
    return const BodegueroHome();
  }
}

class BodegueroHome extends StatelessWidget {
  const BodegueroHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tablero del Bodeguero',
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
                title: 'Agregar material ',
                icon: Icons.inventory_outlined,
                color: const Color(0xFF660952),
                onTap: () {
                  Navigator.pushNamed(context, '/agregarmaterial');
                },
              ),
              HomeCard(
                title: 'Disponibilidad material',
                icon: Icons.data_usage,
                color: const Color(0xFF72AD12),
                onTap: () {
                  Navigator.pushNamed(context, '/disponibilidadmaterial');
                },
              ),
              HomeCard(
                title: 'proceso de producto',
                icon: Icons.auto_mode,
                color: const Color.fromARGB(255, 53, 158, 177),
                onTap: () {
                  Navigator.pushNamed(context, '/procesoproductobode');
                },
              ),
              HomeCard(
                title: 'Vista de Pedidos',
                icon: Icons.remove_red_eye,
                color: const Color(0xFF245520),
                onTap: () {
                  Navigator.pushNamed(context, '/detalleorden');
                },
              ),
              HomeCard(
                title: 'Gestión de Productos',
                icon: Icons.inventory,
                color: const Color.fromARGB(255, 204, 171, 100),
                onTap: () {
                  Navigator.pushNamed(context, '/gestprod');
                },
              ),
              // HomeCard(
              //   title: 'Proveedores',
              //   icon: Icons.supervisor_account,
              //   color: const Color.fromARGB(255, 30, 167, 114),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/proveedor');
              //   },
              // ),
              // HomeCard(
              //   title: 'Promoción',
              //   icon: Icons.local_offer,
              //   color: const Color.fromARGB(255, 190, 50, 50),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/promocion');
              //   },
              // ),
              // HomeCard(
              //   title: 'Agregar Productos',
              //   icon: Icons.add_box,
              //   color: const Color(0xFF1976D2),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/agregarproducto');
              //   },
              // ),
              // HomeCard(
              //   title: 'Ubicacion',
              //   icon: Icons.local_offer,
              //   color: const Color(0xFFB1355A),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/geolocatorwidget');
              //   },
              // ),
              // HomeCard(
              //   title: 'Disponibilidad de producto',
              //   icon: Icons.check_circle,
              //   color: const Color(0xFFF39F21),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/disponibilidadproducto');
              //   },
              // ),
              // HomeCard(
              //   title: 'Historial de Inventarios',
              //   icon: Icons.history,
              //   color: const Color(0xFFB7E70B),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/historialinventario');
              //   },
              // ),
              // HomeCard(
              //   title: 'Categorias producto',
              //   icon: Icons.category,
              //   color: const Color(0xFFB16735),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/categoriaproducto');
              //   },
              // ),
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                textAlign: TextAlign.center,
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
