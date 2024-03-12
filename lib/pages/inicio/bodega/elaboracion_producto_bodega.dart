// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, use_key_in_widget_constructors, unused_local_variable

import 'package:apphormi/pages/inicio/bodega/agregacion_bodega/agregar_producto_bodega.dart';
import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ElavoracionProductoBode extends StatefulWidget {
  @override
  _ElavoracionProductoBodeState createState() =>
      _ElavoracionProductoBodeState();
}

class _ElavoracionProductoBodeState extends State<ElavoracionProductoBode> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Proceso Elaboración',
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
              MaterialPageRoute(builder: (context) => const Bodeguero()),
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
          stream: firestore.collection('procesoproducto').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            List<DocumentSnapshot> productos = snapshot.data!.docs;

            return Stack(
              children: [
                ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      String cantidad = productos[index]['cantidad'].toString();
                      String descripcion = productos[index]['descripcion'];
                      String nombre = productos[index]['nombre'];
                      String fecha = productos[index]['fecha'];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nombre: $nombre',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text('Descripción: $descripcion'),
                                Text('Cantidad: $cantidad'),
                                Text(
                                    'Fecha de pedido: $fecha'), // Mostrar la fecha
                                const SizedBox(height: 8.0),
                                ElevatedButton(
                                  onPressed: () {
                                    _cambiarEstadoProducto(
                                        productos[index].reference);
                                  },
                                  child: const Text(
                                      'Cambiar Proceso del Producto'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                if (snapshot.connectionState == ConnectionState.waiting)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _cambiarEstadoProducto(DocumentReference productoRef) async {
    DocumentSnapshot productoSnapshot = await productoRef.get();
    String nombre = productoSnapshot['nombre'].toString();
    int cantidad = productoSnapshot['cantidad'] as int;
    String descripcion = productoSnapshot['enviada a terminar'];
    String fecha = productoSnapshot['fecha'];

    // Eliminar el documento de 'procesoproducto'
    await productoRef.delete();

    // Agregar los datos a la colección 'elevoracionenviada'
    await FirebaseFirestore.instance.collection('elevoracionenviada').add({
      'nombre': nombre,
      'cantidad': cantidad,
      'descripcion': 'enviada a terminar',
      'fecha': fecha,
      'idproductoenviado': DateTime.now().millisecondsSinceEpoch,
    });

    // Navegar a la pantalla de AgregarProductoBodega
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarProductoBodega(
          selectedProduct: nombre,
          cantidadProducto: cantidad.toString(), // Convertir cantidad a String
        ),
      ),
    );
  }
}
