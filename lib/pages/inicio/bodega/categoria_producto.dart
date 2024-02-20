// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
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
        title: const Text(
          'Categorías de Productos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: Colors.black,
            onPressed: () {
              _mostrarDialogoAgregar(context);
            },
          ),
        ],
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
        child: StreamBuilder<User?>(
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
                      .orderBy('idcategoria')
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
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
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
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _mostrarDialogoEditar(
                                                context,
                                                idCategoria,
                                                datosCategoria['nombre'],
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection(
                                                      'categoriasproducto')
                                                  .doc(idCategoria)
                                                  .delete();
                                            },
                                          ),
                                        ],
                                      ),
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
                'ID Categoría: $idCategoria',
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
                }).then((_) {
                  if (kDebugMode) {
                    print('Documento actualizado correctamente');
                  }
                }).catchError((error) {
                  if (kDebugMode) {
                    print('Error al actualizar el documento: $error');
                  }
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
    var ultimasCategorias = await FirebaseFirestore.instance
        .collection('categoriasproducto')
        .orderBy('idcategoria', descending: true)
        .limit(1)
        .get();

    if (ultimasCategorias.docs.isNotEmpty) {
      var ultimaCategoria = ultimasCategorias.docs.first;
      _ultimoIdCategoria = (ultimaCategoria.data()['idcategoria'] ?? 0) + 1;
    } else {
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
