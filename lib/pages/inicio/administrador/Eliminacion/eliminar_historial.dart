// ignore_for_file: unused_local_variable, use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delete Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EliminarHistorial(),
    );
  }
}

class EliminarHistorial extends StatelessWidget {
  final CollectionReference disponibilidadMaterialCollection =
      FirebaseFirestore.instance.collection('historialventas');
  final CollectionReference eliminacionDatosCollection =
      FirebaseFirestore.instance.collection('eliminarhistorial');

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
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('IVA')),
                DataColumn(label: Text('Método de Pago')),
                DataColumn(label: Text('Eliminar')),
              ],
              rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                var fecha = document['fecha'] as Timestamp;
                var iva = document['iva'] ?? '';
                var metodoPago = document['metodoPago'] ?? '';

                var productos = document['productos'] ?? [];
                var primerProducto = productos.isNotEmpty ? productos[0] : null;
                var nombreProducto =
                    primerProducto != null ? primerProducto['nombre'] : '';

                return DataRow(cells: [
                  DataCell(Text(nombreProducto.toString())),
                  DataCell(Text(fecha.toDate().toString())),
                  DataCell(Text(iva.toString())),
                  DataCell(Text(metodoPago)),
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
                                decoration: const InputDecoration(
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
                                  onPressed: () async {
                                    if (motivoText.isNotEmpty) {
                                      await eliminacionDatosCollection.add({
                                        'fechaEliminacion': DateTime.now(),
                                        'ivaEliminacion': iva,
                                        'metodoPagoEliminacion': metodoPago,
                                        'nombreProductoEliminacion':
                                            nombreProducto,
                                        'motivoEliminacion': motivoText,
                                      });

                                      // Aquí puedes agregar la lógica para eliminar el producto
                                      // Puedes usar document.reference.delete() para eliminar el documento completo

                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Text('Aceptar'),
                                ),
                              ],
                            );
                          },
                        );
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
