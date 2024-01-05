import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    // Configura un temporizador para cambiar automáticamente la página cada 3 segundos.
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hormibloque Ecuador S.A'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 200,
              child: PageView(
                controller: _pageController,
                children: [
                  buildImage('assets/cruz.jpg', 200, 200),
                  buildImage('assets/paleta.jpg', 200, 200),
                  buildImage('assets/jaboncillo.jpg', 200, 200),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/seci');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 75, 170, 88),
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 114),
            ),
            child: const Text(
              'Iniciar aplicación',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImage(String imagePath, double height, double width) {
    return Image.asset(
      imagePath,
      height: height,
      width: width,
    );
  }
}
