// ignore_for_file: use_build_context_synchronously

import 'package:apphormi/pages/inicio/administrador/administrador.dart';
import 'package:apphormi/pages/inicio_secion/inicio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EliminarDatosScreen extends StatefulWidget {
  const EliminarDatosScreen({Key? key}) : super(key: key);

  @override
  State<EliminarDatosScreen> createState() => _EliminarDatosScreenState();
}

class _EliminarDatosScreenState extends State<EliminarDatosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Eliminar Datos",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Administrador()),
            );
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
                title: 'Eliminar material disponibilidad',
                color: const Color.fromARGB(255, 114, 97, 189),
                icon: Icons.folder_delete_rounded,
                onTap: () {
                  Navigator.pushNamed(context, '/eliminarmaterial');
                },
              ),
              buildMenuCard(
                title: 'Eliminar producto disponibilidad',
                color: const Color.fromARGB(255, 130, 151, 141),
                icon: Icons.delete_forever_sharp,
                onTap: () {
                  Navigator.pushNamed(context, '/eliminarproducto');
                },
              ),
              buildMenuCard(
                title: 'Eliminar historial ventas',
                color: Colors.blue,
                icon: Icons.delete_sharp,
                onTap: () {
                  Navigator.pushNamed(context, '/eliminarhistorial');
                },
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
        child: SizedBox(
          width: 150,
          height: 150,
          child: Center(
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
        ),
      ),
    );
  }
}
