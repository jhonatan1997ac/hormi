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
      home: EliminarMaterial(),
    );
  }
}

class EliminarMaterial extends StatelessWidget {
  final CollectionReference disponibilidadMaterialCollection =
      FirebaseFirestore.instance.collection('disponibilidadmaterial');
  final CollectionReference eliminacionDatosCollection =
      FirebaseFirestore.instance.collection('eliminaciondatos');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eliminacion Material'),
      ),
      body: StreamBuilder(
        stream: disponibilidadMaterialCollection.snapshots(),
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
                DataColumn(label: Text('Cantidad')),
                DataColumn(label: Text('Descripción')),
                DataColumn(label: Text('Imagen')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Eliminar')),
              ],
              rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                return DataRow(cells: [
                  DataCell(Text(document['cantidad'].toString())),
                  DataCell(Text(document['descripcion'].toString())),
                  DataCell(
                    Image.network(
                      document['imagenURL'],
                      width: 100,
                      height: 100,
                    ),
                  ),
                  DataCell(Text(document['nombre'].toString())),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        String? motivo = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            String motivoText =
                                ''; // Variable para almacenar el motivo ingresado

                            return AlertDialog(
                              title: const Text(
                                  '¿Por qué deseas borrar este dato?'),
                              content: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Ingrese el motivo',
                                ),
                                onChanged: (value) {
                                  motivoText =
                                      value; // Almacenar el valor del texto en la variable
                                },
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Cerrar el diálogo sin enviar motivo
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                        motivoText); // Enviar el motivo ingresado al presionar "Aceptar"
                                  },
                                  child: Text('Aceptar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (motivo != null && motivo.isNotEmpty) {
                          await document.reference.delete();
                          await eliminacionDatosCollection.add({
                            'cantidad': document['cantidad'],
                            'descripcion': document['descripcion'],
                            'imagenURL': document['imagenURL'],
                            'nombre': document['nombre'],
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
