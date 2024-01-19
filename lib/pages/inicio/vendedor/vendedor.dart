import 'package:apphormi/pages/inicio_secion/inicio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class vendedor extends StatefulWidget {
  const vendedor({Key? key}) : super(key: key);

  @override
  State<vendedor> createState() => _vendedorState();
}

class _vendedorState extends State<vendedor> {
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
                Navigator.pushNamed(context, '/productosvendedor');
              },
              color: Colors.blue,
              icon: Icons.shopping_cart, // Agrega el icono correspondiente
            ),
            HomeCard(
              title: 'Pedidos',
              onTap: () {
                Navigator.pushNamed(context, '/pedidovendedor');
              },
              color: Colors.green,
              icon: Icons.assignment,
            ),
            HomeCard(
              title: 'Gestión de Vendedor',
              icon: Icons.person,
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, '/empleados');
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
              title: 'Informes',
              onTap: () {
                // Lógica para acceder a la sección de informes
              },
              color: Colors.purple,
              icon: Icons.insert_chart,
            ),
            HomeCard(
              title: 'Configuración',
              onTap: () {
                // Lógica para acceder a la sección de configuración
              },
              color: Colors.red,
              icon: Icons.settings,
            ),
            HomeCard(
              title: 'Estadísticas',
              onTap: () {
                // Lógica para acceder a la sección de estadísticas
              },
              color: Colors.yellow,
              icon: Icons.bar_chart,
            ),
            HomeCard(
              title: 'Mensajes',
              onTap: () {
                // Lógica para acceder a la sección de mensajes
              },
              color: Colors.deepOrange,
              icon: Icons.message,
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
        primary: color,
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
