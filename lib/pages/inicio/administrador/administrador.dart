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
        title: const Text("Administrador"),
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
              title: 'Productos',
              onTap: () {
                Navigator.pushNamed(context, '/productosadministrador');
              },
              color: Colors.blue,
              icon: Icons.shopping_cart,
            ),
            HomeCard(
              title: 'Pedidos',
              color: const Color.fromARGB(255, 175, 76, 170),
              icon: Icons.assignment,
              onTap: () {
                Navigator.pushNamed(context, '/pedidovendedor');
              },
            ),
            HomeCard(
              title: 'Departamento',
              icon: Icons.work_history,
              color: const Color.fromARGB(255, 88, 146, 73),
              onTap: () {
                Navigator.pushNamed(context, '/departamento');
              },
            ),
            HomeCard(
              title: 'Transportista',
              icon: Icons.car_repair_rounded,
              color: const Color.fromARGB(255, 80, 73, 146),
              onTap: () {
                Navigator.pushNamed(context, '/transporte');
              },
            ),
            HomeCard(
              title: 'Ruta de envio',
              icon: Icons.alt_route_rounded,
              color: const Color.fromARGB(255, 48, 17, 31),
              onTap: () {
                Navigator.pushNamed(context, '/rutaenvio');
              },
            ),
            HomeCard(
              title: 'Gestión de Vendedor',
              icon: Icons.person,
              color: const Color.fromARGB(255, 192, 80, 80),
              onTap: () {
                Navigator.pushNamed(context, '/vendedoradministrador');
              },
            ),
            HomeCard(
              title: 'Gestion de Bodeguero',
              onTap: () {
                Navigator.pushNamed(context, '/bodeguero');
              },
              color: Colors.orange,
              icon: Icons.people,
            ),

            HomeCard(
              title: 'Configuración de Cuenta',
              onTap: () {
                // Lógica para acceder a la sección de configuración de cuenta
              },
              color: Colors.indigo,
              icon: Icons.account_circle,
            ),
            // Puedes agregar más HomeCard según sea necesario
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    const CircularProgressIndicator();
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
  final Color color;
  final VoidCallback onTap;
  final IconData icon;

  const HomeCard({
    Key? key,
    required this.title,
    required this.onTap,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
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
    );
  }
}
