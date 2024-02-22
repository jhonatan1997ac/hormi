// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:apphormi/pages/inicio/administrador/administrador.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProcesoProductos extends StatefulWidget {
  @override
  _ProcesoProductosState createState() => _ProcesoProductosState();
}

class _ProcesoProductosState extends State<ProcesoProductos> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Productos en Proceso',
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 55, 111, 139),
              Color.fromARGB(255, 165, 160, 160),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('productosterminados').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            List<DocumentSnapshot> productos = snapshot.data!.docs;

            return ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                String cantidad = productos[index]['cantidad'];
                String descripcion = productos[index]['descripcion'];
                String nombre = productos[index]['nombre'];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nombre: $nombre',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Descripción: $descripcion'),
                          Text('Cantidad: $cantidad'),
                          const SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              _mostrarDialogoConfirmacion(
                                  productos[index].reference);
                            },
                            child: const Text('Cambiar a Terminado'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _mostrarDialogoConfirmacion(DocumentReference productoRef) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content: const Text("¿Estás seguro de que deseas cambiar el estado?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Aceptar"),
              onPressed: () {
                _cambiarEstadoProducto(productoRef);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _cambiarEstadoProducto(DocumentReference productoRef) {
    productoRef.update({'descripcion': 'Terminado'}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado cambiado a Terminado')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar el estado: $error')),
      );
    });
  }
}

void main() {
  runApp(MaterialApp(
    home: ProcesoProductos(),
  ));
}
