// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delete Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EliminarProducto(),
    );
  }
}

class EliminarProducto extends StatelessWidget {
  final CollectionReference disponibilidadProductoCollection =
      FirebaseFirestore.instance.collection('disponibilidadproducto');
  final CollectionReference eliminacionProductosCollection =
      FirebaseFirestore.instance.collection('eliminacionProductos');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eliminación de Producto'),
      ),
      body: StreamBuilder(
        stream: disponibilidadProductoCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Calidad')),
                DataColumn(label: Text('Cantidad')),
                DataColumn(label: Text('Disponible')),
                DataColumn(label: Text('Imagen')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Precio')),
                DataColumn(label: Text('Eliminar')),
              ],
              rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                return DataRow(cells: [
                  DataCell(Text(document['calidad'].toString())),
                  DataCell(Text(document['cantidad'].toString())),
                  DataCell(Text(document['disponible'].toString())),
                  DataCell(
                    Image.network(
                      document['imagen'],
                      width: 100,
                      height: 100,
                    ),
                  ),
                  DataCell(Text(document['nombre'].toString())),
                  DataCell(Text(document['precio'].toString())),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        String? motivo = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            String motivoText = '';

                            return AlertDialog(
                              title: const Text(
                                  '¿Por qué deseas borrar este producto?'),
                              content: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Ingrese el motivo',
                                ),
                                onChanged: (value) {
                                  motivoText = value;
                                },
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(motivoText);
                                  },
                                  child: Text('Aceptar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (motivo != null && motivo.isNotEmpty) {
                          await document.reference.delete();
                          await eliminacionProductosCollection.add({
                            'calidad': document['calidad'],
                            'cantidad': document['cantidad'],
                            'disponible': document['disponible'],
                            'imagen': document['imagen'],
                            'nombre': document['nombre'],
                            'precio': document['precio'],
                            'motivoeliminacion': motivo,
                            'fechaeliminacion': DateTime.now(),
                          });
                        }
                      },
                    ),
                  ),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
