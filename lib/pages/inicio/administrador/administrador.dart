// ignore_for_file: use_build_context_synchronously

import 'package:apphormi/pages/inicio_secion/inicio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Administrador extends StatefulWidget {
  const Administrador({Key? key}) : super(key: key);

  @override
  State<Administrador> createState() => _AdministradorState();
}

class _AdministradorState extends State<Administrador> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Panel de Administrador",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            logout(context);
          },
          icon: const Icon(
            Icons.logout,
            color: Colors.black,
            size: 30.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/carga.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              buildMenuCard(
                title: 'Proceso de productos',
                color: const Color.fromARGB(255, 114, 97, 189),
                icon: Icons.auto_mode,
                onTap: () {
                  Navigator.pushNamed(context, '/MaterialAvailabilityPage');
                },
              ),
              buildMenuCard(
                title: 'Elavoracion',
                color: const Color.fromARGB(255, 130, 151, 141),
                icon: Icons.all_inbox_rounded,
                onTap: () {
                  Navigator.pushNamed(context, '/procesoproductos');
                },
              ),
              buildMenuCard(
                title: 'Gestión de Productos',
                color: Colors.blue,
                icon: Icons.change_circle_rounded,
                onTap: () {
                  Navigator.pushNamed(
                      context, '/GestiornarProductoAdministrador');
                },
              ),
              buildMenuCard(
                title: 'Vista Datos',
                icon: Icons.remove_red_eye_outlined,
                color: const Color.fromARGB(255, 190, 202, 84),
                onTap: () {
                  Navigator.pushNamed(context, '/vistadatos');
                },
              ),
              buildMenuCard(
                title: 'Datos Eliminar',
                icon: Icons.delete_sweep_outlined,
                color: const Color.fromARGB(164, 84, 202, 100),
                onTap: () {
                  Navigator.pushNamed(context, '/eliminardatos');
                },
              ),
              buildMenuCard(
                title: 'Gestión de Vendedor',
                icon: Icons.person,
                color: const Color.fromARGB(242, 192, 80, 80),
                onTap: () {
                  Navigator.pushNamed(context, '/vendedoradministrador');
                },
              ),
              buildMenuCard(
                title: 'Gestión de Bodeguero',
                onTap: () {
                  Navigator.pushNamed(context, '/bodeguero');
                },
                color: Colors.orange,
                icon: Icons.people,
              ),
              buildMenuCard(
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

  Widget buildMenuCard({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.0,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
