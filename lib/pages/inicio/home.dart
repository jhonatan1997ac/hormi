import 'package:flutter/foundation.dart';
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
                if (kDebugMode) {
                  print('Configuración');
                }
              },
            ),
            HomeCard(
              title: 'Uso de Datos',
              icon: Icons.data_usage,
              color: Colors.blue,
              onTap: () {
                if (kDebugMode) {
                  print('Uso de Datos');
                }
              },
            ),
            HomeCard(
              title: 'Calendario',
              icon: Icons.calendar_month,
              color: Colors.orange,
              onTap: () {
                if (kDebugMode) {
                  print('Calendario');
                }
              },
            ),
            HomeCard(
              title: 'Opción 4',
              icon: Icons.star,
              color: Colors.purple,
              onTap: () {
                if (kDebugMode) {
                  print('Opción 4');
                }
              },
            ),
            HomeCard(
              title: 'Opción 5',
              icon: Icons.access_alarm,
              color: Colors.red,
              onTap: () {
                if (kDebugMode) {
                  print('Opción 5');
                }
              },
            ),
            HomeCard(
              title: 'Opción 6',
              icon: Icons.camera,
              color: Colors.teal,
              onTap: () {
                if (kDebugMode) {
                  print('Opción 6');
                }
              },
            ),
            HomeCard(
              title: 'Opción 7',
              icon: Icons.bluetooth,
              color: Colors.indigo,
              onTap: () {
                if (kDebugMode) {
                  print('Opción 7');
                }
              },
            ),
            HomeCard(
              title: 'Opción 8',
              icon: Icons.airplanemode_active,
              color: Colors.amber,
              onTap: () {
                if (kDebugMode) {
                  print('Opción 8');
                }
              },
            ),
            HomeCard(
              title: 'Opción 9',
              icon: Icons.attach_money,
              color: Colors.brown,
              onTap: () {
                if (kDebugMode) {
                  print('Opción 9');
                }
              },
            ),
            HomeCard(
              title: 'Opción 10',
              icon: Icons.beach_access,
              color: Colors.deepPurple,
              onTap: () {
                if (kDebugMode) {
                  print('Opción 10');
                }
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
      child: Card(
        elevation: 4.0,
        color: color,
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
