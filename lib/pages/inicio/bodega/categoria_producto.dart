// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriaProducto extends StatefulWidget {
  const CategoriaProducto({Key? key}) : super(key: key);

  @override
  _CategoriaProductoState createState() => _CategoriaProductoState();
}

class _CategoriaProductoState extends State<CategoriaProducto> {
  int _ultimoIdCategoria = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
                    .collection('categoriasproducto')
                    .orderBy('idcategoria') // Ordena por el campo idcategoria
                    .snapshots(),
                builder: (context, snapshotCategorias) {
                  if (snapshotCategorias.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshotCategorias.hasError) {
                    return Text('Error: ${snapshotCategorias.error}');
                  } else {
                    var categorias = snapshotCategorias.data?.docs;

                    if (categorias == null || categorias.isEmpty) {
                      return const Text(
                          'No se encontraron categorías de productos.');
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: categorias.length,
                              itemBuilder: (context, index) {
                                var datosCategoria = categorias[index].data();
                                var idCategoria = categorias[index].id;
                                return ListTile(
                                  title: Text(
                                    'Categoría ID: ${datosCategoria['idcategoria']}',
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nombre: ${datosCategoria['nombre']}',
                                      ),
                                      // Puedes agregar más campos según tus necesidades
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
                                            idCategoria,
                                            datosCategoria['nombre'],
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('categoriasproducto')
                                              .doc(idCategoria)
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
    String idCategoria,
    String nombreActual,
  ) {
    TextEditingController nombreControlador = TextEditingController()
      ..text = nombreActual;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ID Categoría: $idCategoria', // Muestra el ID, no editable
              ),
              TextField(
                controller: nombreControlador,
                decoration: const InputDecoration(labelText: 'Nuevo Nombre'),
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
                    .collection('categoriasproducto')
                    .doc(idCategoria)
                    .update({
                  'nombre': nombreControlador.text,
                  // Puedes agregar más campos según tus necesidades
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
    // Obtener el último idcategoria de la base de datos
    var ultimasCategorias = await FirebaseFirestore.instance
        .collection('categoriasproducto')
        .orderBy('idcategoria', descending: true)
        .limit(1)
        .get();

    if (ultimasCategorias.docs.isNotEmpty) {
      var ultimaCategoria = ultimasCategorias.docs.first;
      _ultimoIdCategoria = (ultimaCategoria.data()['idcategoria'] ?? 0) + 1;
    } else {
      // Si no hay categorías en la base de datos, comienza desde 1
      _ultimoIdCategoria = 1;
    }

    TextEditingController nombreControlador = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ID Categoría: $_ultimoIdCategoria',
              ),
              TextField(
                controller: nombreControlador,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              // Puedes agregar más campos según tus necesidades
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
                    .collection('categoriasproducto')
                    .add({
                  'idcategoria': _ultimoIdCategoria,
                  'nombre': nombreControlador.text,
                  // Puedes agregar más campos según tus necesidades
                }).then((value) {
                  if (kDebugMode) {
                    print('Categoría agregada correctamente');
                  }
                }).catchError((error) {});

                Navigator.of(context).pop();
              },
              child: const Text('Agregar Categoría'),
            ),
          ],
        );
      },
    );
  }
}
