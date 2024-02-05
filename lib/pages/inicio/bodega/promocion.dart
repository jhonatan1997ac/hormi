// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Promocion extends StatefulWidget {
  const Promocion({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PromocionState createState() => _PromocionState();
}

class _PromocionState extends State<Promocion> {
  int _ultimoIdPromocion = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promociones'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _mostrarDialogoAgregar(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            User? usuarioActual = snapshot.data;

            if (usuarioActual == null) {
              return const Text('No hay usuarios autenticados.');
            } else {
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('promocion')
                    .orderBy('idpromocion') // Ordena por el campo idpromocion
                    .snapshots(),
                builder: (context, snapshotPromociones) {
                  if (snapshotPromociones.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshotPromociones.hasError) {
                    return Text('Error: ${snapshotPromociones.error}');
                  } else {
                    var promociones = snapshotPromociones.data?.docs;

                    if (promociones == null || promociones.isEmpty) {
                      return const Text('No se encontraron promociones.');
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: promociones.length,
                              itemBuilder: (context, index) {
                                var datosPromocion = promociones[index].data();
                                var idpromocion = promociones[index].id;
                                return ListTile(
                                  title: Text(
                                    'Promoción ID: ${datosPromocion['idpromocion']}',
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ID Producto: ${datosPromocion['idproducto']}',
                                      ),
                                      Text(
                                        'Descuento: ${datosPromocion['descuento']}',
                                      ),
                                      Text(
                                        'Fecha Inicio: ${datosPromocion['fechainicio']}',
                                      ),
                                      Text(
                                        'Fecha Fin: ${datosPromocion['fechafin']}',
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          _mostrarDialogoEditar(
                                            context,
                                            idpromocion,
                                            datosPromocion['idproducto'],
                                            datosPromocion['descuento'],
                                            datosPromocion['fechainicio'],
                                            datosPromocion['fechafin'],
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('promocion')
                                              .doc(idpromocion)
                                              .delete();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  }
                },
              );
            }
          }
        },
      ),
    );
  }

  void _mostrarDialogoEditar(
    BuildContext context,
    String idpromocion,
    String idproductoActual,
    String descuentoActual,
    String fechainicioActual,
    String fechafinActual,
  ) {
    TextEditingController idproductoControlador = TextEditingController()
      ..text = idproductoActual;
    TextEditingController descuentoControlador = TextEditingController()
      ..text = descuentoActual;
    TextEditingController fechainicioControlador = TextEditingController()
      ..text = fechainicioActual;
    TextEditingController fechafinControlador = TextEditingController()
      ..text = fechafinActual;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Promoción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ID Promoción: $idpromocion', // Muestra el ID, no editable
              ),
              TextField(
                controller: idproductoControlador,
                decoration: const InputDecoration(labelText: 'ID Producto'),
              ),
              TextField(
                controller: descuentoControlador,
                decoration: const InputDecoration(labelText: 'Descuento'),
              ),
              TextField(
                controller: fechainicioControlador,
                decoration: const InputDecoration(labelText: 'Fecha Inicio'),
              ),
              TextField(
                controller: fechafinControlador,
                decoration: const InputDecoration(labelText: 'Fecha Fin'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('promocion')
                    .doc(idpromocion)
                    .update({
                  'idproducto': idproductoControlador.text,
                  'descuento': descuentoControlador.text,
                  'fechainicio': fechainicioControlador.text,
                  'fechafin': fechafinControlador.text,
                }).then((_) {
                  print('Documento actualizado correctamente');
                }).catchError((error) {
                  print('Error al actualizar el documento: $error');
                });

                Navigator.of(context).pop();
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoAgregar(BuildContext context) async {
    // Obtener el último idpromocion de la base de datos
    var ultimasPromociones = await FirebaseFirestore.instance
        .collection('promocion')
        .orderBy('idpromocion', descending: true)
        .limit(1)
        .get();

    if (ultimasPromociones.docs.isNotEmpty) {
      var ultimaPromocion = ultimasPromociones.docs.first;
      _ultimoIdPromocion = (ultimaPromocion.data()['idpromocion'] ?? 0) + 1;
    } else {
      // Si no hay promociones en la base de datos, comienza desde 1
      _ultimoIdPromocion = 1;
    }

    TextEditingController idproductoControlador = TextEditingController();
    TextEditingController descuentoControlador = TextEditingController();
    TextEditingController fechainicioControlador = TextEditingController();
    TextEditingController fechafinControlador = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Promoción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ID Promoción: $_ultimoIdPromocion',
              ),
              TextField(
                controller: idproductoControlador,
                decoration: const InputDecoration(labelText: 'ID Producto'),
              ),
              TextField(
                controller: descuentoControlador,
                decoration: const InputDecoration(labelText: 'Descuento'),
              ),
              TextField(
                controller: fechainicioControlador,
                decoration: const InputDecoration(labelText: 'Fecha Inicio'),
              ),
              TextField(
                controller: fechafinControlador,
                decoration: const InputDecoration(labelText: 'Fecha Fin'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('promocion').add({
                  'idpromocion': _ultimoIdPromocion,
                  'idproducto': idproductoControlador.text,
                  'descuento': descuentoControlador.text,
                  'fechainicio': fechainicioControlador.text,
                  'fechafin': fechafinControlador.text,
                }).then((value) {
                  if (kDebugMode) {
                    print('Promoción agregada correctamente');
                  }
                }).catchError((error) {});

                Navigator.of(context).pop();
              },
              child: const Text('Agregar Promoción'),
            ),
          ],
        );
      },
    );
  }
}
