import 'package:apphormi/servicio/firebase_usuarios.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class agregarDatos extends StatefulWidget {
  const agregarDatos({super.key});

  @override
  State<agregarDatos> createState() => _agregarDatosState();
}

class _agregarDatosState extends State<agregarDatos> {
  final TextEditingController _nombreController =
      TextEditingController(text: "");

  void _guardarDatos(BuildContext context) {
    String nuevoNombre = _nombreController.text;

    // Validar que el nombre no esté vacío
    if (nuevoNombre.trim().isEmpty) {
      // Mostrar alerta si el nombre está vacío
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('El nombre no puede estar vacío.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el AlertDialog
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } else {
      // Si el nombre no está vacío, proceder con la operación
      if (kDebugMode) {
        print("Guardando nuevo nombre: $nuevoNombre");
      }

      // Llama a la función addUsuario aquí
      addUsuario(nuevoNombre);

      // Reemplazar la pantalla actual con la pantalla "/home"
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar datos'),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese el nuevo nombre',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Espaciador vertical
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _guardarDatos(context),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 50),
                ),
                child: const Text("Guardar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
