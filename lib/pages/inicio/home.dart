import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

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
              title: 'Configuración',
              icon: Icons.settings,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/conf');
              },
            ),
            HomeCard(
              title: 'Presupuestos',
              icon: Icons.attach_money_outlined,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/pres');
              },
            ),
            HomeCard(
              title: 'Calendario',
              icon: Icons.calendar_month,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/cale');
              },
            ),
            HomeCard(
              title: '',
              icon: Icons.star,
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/tare');
              },
            ),
            HomeCard(
              title: 'Opción 5',
              icon: Icons.access_alarm,
              color: Colors.red,
              onTap: () {
                // Mantén este espacio vacío si no deseas ninguna acción.
              },
            ),
            HomeCard(
              title: 'Opción 6',
              icon: Icons.camera,
              color: Colors.teal,
              onTap: () {
                // Mantén este espacio vacío si no deseas ninguna acción.
              },
            ),
            HomeCard(
              title: 'Opción 7',
              icon: Icons.bluetooth,
              color: Colors.indigo,
              onTap: () {
                // Mantén este espacio vacío si no deseas ninguna acción.
              },
            ),
            HomeCard(
              title: 'Opción 8',
              icon: Icons.airplanemode_active,
              color: Colors.amber,
              onTap: () {
                // Mantén este espacio vacío si no deseas ninguna acción.
              },
            ),
            HomeCard(
              title: 'Opción 9',
              icon: Icons.attach_money,
              color: Colors.brown,
              onTap: () {
                // Mantén este espacio vacío si no deseas ninguna acción.
              },
            ),
            HomeCard(
              title: 'Opción 10',
              icon: Icons.beach_access,
              color: Colors.deepPurple,
              onTap: () {
                // Mantén este espacio vacío si no deseas ninguna acción.
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
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

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
