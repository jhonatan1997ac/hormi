import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      routes: {
        '/conf': (context) => const ConfiguracionPage(),
      },
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
                _navigateToPage(context, 'Configuración');
              },
            ),
            HomeCard(
              title: 'Uso de Datos',
              icon: Icons.data_usage,
              color: Colors.blue,
              onTap: () {
                _navigateToPage(context, 'Uso de Datos');
              },
            ),
            HomeCard(
              title: 'Calendario',
              icon: Icons.calendar_month,
              color: Colors.orange,
              onTap: () {
                _navigateToPage(context, 'Calendario');
              },
            ),
            HomeCard(
              title: 'Opción 4',
              icon: Icons.star,
              color: Colors.purple,
              onTap: () {
                _navigateToPage(context, 'Opción 4');
              },
            ),
            HomeCard(
              title: 'Opción 5',
              icon: Icons.access_alarm,
              color: Colors.red,
              onTap: () {
                _navigateToPage(context, 'Opción 5');
              },
            ),
            HomeCard(
              title: 'Opción 6',
              icon: Icons.camera,
              color: Colors.teal,
              onTap: () {
                _navigateToPage(context, 'Opción 6');
              },
            ),
            HomeCard(
              title: 'Opción 7',
              icon: Icons.bluetooth,
              color: Colors.indigo,
              onTap: () {
                _navigateToPage(context, 'Opción 7');
              },
            ),
            HomeCard(
              title: 'Opción 8',
              icon: Icons.airplanemode_active,
              color: Colors.amber,
              onTap: () {
                _navigateToPage(context, 'Opción 8');
              },
            ),
            HomeCard(
              title: 'Opción 9',
              icon: Icons.attach_money,
              color: Colors.brown,
              onTap: () {
                _navigateToPage(context, 'Opción 9');
              },
            ),
            HomeCard(
              title: 'Opción 10',
              icon: Icons.beach_access,
              color: Colors.deepPurple,
              onTap: () {
                _navigateToPage(context, 'Opción 10');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String pageTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(title: pageTitle),
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
          primary: color,
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

class DetailPage extends StatelessWidget {
  final String title;

  const DetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Página de detalles para $title'),
      ),
    );
  }
}

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: const Center(
        child: Text('Esta es la página de configuración'),
      ),
    );
  }
}
