import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Demo',
      home: Vender(),
    );
  }
}

class Vender extends StatefulWidget {
  @override
  _VenderState createState() => _VenderState();
}

class _VenderState extends State<Vender> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _documentIdController = TextEditingController();
  final CollectionReference _productosCollection =
      FirebaseFirestore.instance.collection('disponibilidadproducto');

  void _actualizarCantidad() async {
    try {
      int cantidadRestar = int.parse(_controller.text);
      String documentId = _documentIdController.text;

      // Obtener el documento deseado usando el ID ingresado por el usuario
      DocumentSnapshot doc = await _productosCollection.doc(documentId).get();

      if (doc.exists) {
        // Obtener el valor actual de 'cantidad' y restar la cantidad ingresada
        int cantidadActual = doc['cantidad'];
        int nuevaCantidad = cantidadActual - cantidadRestar;

        // Actualizar la base de datos con la nueva cantidad
        await _productosCollection
            .doc(documentId)
            .update({'cantidad': nuevaCantidad});

        // Limpiar los campos de texto después de actualizar
        _controller.clear();
        _documentIdController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cantidad actualizada correctamente'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documento no encontrado'),
          ),
        );
      }
    } catch (e) {
      // Manejar errores al convertir el texto a un número
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizar Cantidad en Firebase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _documentIdController,
              decoration:
                  InputDecoration(labelText: 'Ingrese el ID del documento'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(labelText: 'Ingrese la cantidad a restar'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _actualizarCantidad,
              child: Text('Actualizar Cantidad'),
            ),
          ],
        ),
      ),
    );
  }
}
