// ignore_for_file: use_key_in_widget_constructors

import 'package:apphormi/pages/inicio/administrador/administrador.dart';
import 'package:flutter/material.dart';

class EliminarDatosScreen extends StatelessWidget {
  final List<List<String>> seccionDatos = [[], [], [], [], [], []];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Eliminacion ',
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
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 30.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        children: [
          for (int i = 0; i < 6; i++)
            CardButton(
              color: _getColor(i),
              text: 'Eliminar Sección ${i + 1}',
              onPressed: () {
                setState(() {
                  if (seccionDatos[i].isNotEmpty) seccionDatos[i].removeLast();
                });
              },
              additionalData: seccionDatos[i].isEmpty
                  ? 'No hay datos en esta sección'
                  : 'Último dato eliminado: ${seccionDatos[i].last}',
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Regresar'),
          ),
        ],
      ),
    );
  }

  Color _getColor(int index) {
    switch (index) {
      case 0:
        return Colors.redAccent;
      case 1:
        return Colors.blueAccent;
      case 2:
        return const Color.fromARGB(255, 118, 105, 240);
      case 3:
        return Colors.orangeAccent;
      case 4:
        return Colors.purpleAccent;
      case 5:
        return const Color.fromARGB(255, 6, 19, 141);
      default:
        return Colors.grey;
    }
  }
}

void setState(Null Function() param0) {}

class CardButton extends StatelessWidget {
  final Color color;
  final String text;
  final VoidCallback onPressed;
  final String additionalData;

  const CardButton({
    required this.color,
    required this.text,
    required this.onPressed,
    required this.additionalData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        child: ListTile(
          tileColor: color.withOpacity(1),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                additionalData,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          onTap: onPressed,
        ),
      ),
    );
  }
}
