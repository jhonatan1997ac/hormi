import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            HomeCard(
              title: 'Gestión de Clientes',
              icon: Icons.people,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/usu');
              },
            ),
            HomeCard(
              title: 'Catálogo de Productos',
              icon: Icons.inventory,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/cata');
              },
            ),
            HomeCard(
              title: 'Cotizaciones y Pedidos',
              icon: Icons.shopping_cart,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/coti');
              },
            ),
            HomeCard(
              title: 'Facturación',
              icon: Icons.receipt,
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/fact');
              },
            ),
            HomeCard(
              title: 'Informes y Estadísticas',
              icon: Icons.bar_chart,
              color: Colors.red,
              onTap: () {
                // Implementa la lógica para informes y estadísticas
              },
            ),
            HomeCard(
              title: 'Calendario de Entregas',
              icon: Icons.calendar_today,
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, '/cale');
              },
            ),
            HomeCard(
              title: 'Configuración y Administración',
              icon: Icons.settings,
              color: Colors.indigo,
              onTap: () {
                Navigator.pushNamed(context, '/conf');
              },
            ),
            HomeCard(
              title: 'Soporte y Ayuda',
              icon: Icons.help,
              color: Colors.amber,
              onTap: () {
                Navigator.pushNamed(context, '/sopor');
              },
            ),
            HomeCard(
              title: 'Integración con GPS',
              icon: Icons.gps_fixed,
              color: Colors.brown,
              onTap: () {
                // Implementa la lógica para integración con GPS
              },
            ),
            HomeCard(
              title: 'Accesos Rápidos',
              icon: Icons.speed,
              color: Colors.deepPurple,
              onTap: () {
                // Implementa la lógica para accesos rápidos
              },
            ),
          ],
        ),
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
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 4.0,
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
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
