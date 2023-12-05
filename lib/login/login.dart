import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hormibloque Ecuador S.A'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              child: PageView(
                children: [
                  Image.asset(
                    'assets/cruz.jpg',
                    height: 200,
                    width: 200,
                  ),
                  Image.asset(
                    'assets/paleta.jpg',
                    height: 200,
                    width: 200,
                  ),
                  Image.asset(
                    'assets/jaboncillo.jpg',
                    height: 200,
                    width: 200,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            AnimatedBuilder(
              animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: AlwaysStoppedAnimation(1),
                  curve: Curves.easeInOutBack,
                ),
              ),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0.0, 100 * (1 - (1 - 0.5).abs())),
                  child: Opacity(
                    opacity: 1 - (1 - 0.5).abs(),
                    child: const Text(
                      'Iniciar aplicación',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 75, 170, 88),
              ),
              child: const Text('Iniciar aplicación'),
            ),
          ],
        ),
      ),
    );
  }
}
