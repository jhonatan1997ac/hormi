import 'package:apphormi/servicio/firebase_usuarios.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditarDatos extends StatefulWidget {
  const EditarDatos({Key? key});

  @override
  State<EditarDatos> createState() => _EditarDatosState();
}

class _EditarDatosState extends State<EditarDatos> {
  final TextEditingController _nombreController =
      TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    _nombreController.text = arguments['nombre'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar datos'),
        backgroundColor: Colors.lightGreen,
        automaticallyImplyLeading: false, // Oculta el botón de retroceso
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    hintText: 'Edite el nombre',
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String uid = arguments['uid'];
                  String nuevoNombre = _nombreController.text;

                  // Validar que el nuevo nombre no esté vacío
                  if (nuevoNombre.trim().isEmpty) {
                    // Muestra un mensaje de error como un AlertDialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error de edición'),
                          content: Text('El nombre no puede estar vacío.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Cerrar el AlertDialog
                              },
                              child: Text('Aceptar'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Llama a la función editUsuario solo si el nombre no está vacío
                    await editUsuario(uid, nuevoNombre);
                    // Redirige a la ruta /home después de la edición
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("EDITAR"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
