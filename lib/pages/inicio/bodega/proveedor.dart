// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Proveedor extends StatefulWidget {
  const Proveedor({Key? key}) : super(key: key);

  @override
  _ProveedorState createState() => _ProveedorState();
}

class _ProveedorState extends State<Proveedor> {
  int _ultimoIdProveedor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios Proveedor'),
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
                    .collection('proveedor')
                    .orderBy('idproveedor') // Ordena por el campo idproveedor
                    .snapshots(),
                builder: (context, snapshotProveedores) {
                  if (snapshotProveedores.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshotProveedores.hasError) {
                    return Text('Error: ${snapshotProveedores.error}');
                  } else {
                    var proveedores = snapshotProveedores.data?.docs;

                    if (proveedores == null || proveedores.isEmpty) {
                      return const Text(
                          'No se encontraron usuarios proveedores.');
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: proveedores.length,
                              itemBuilder: (context, index) {
                                var datosProveedor = proveedores[index].data();
                                var idproveedor = proveedores[index].id;
                                return ListTile(
                                  title: Text(
                                    'Proveedor ID: ${datosProveedor['idproveedor']}',
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nombre Empresa: ${datosProveedor['nombreEmpresa']}',
                                      ),
                                      Text(
                                        'Contacto: ${datosProveedor['contacto']}',
                                      ),
                                      Text(
                                        'Email: ${datosProveedor['email']}',
                                      ),
                                      Text(
                                        'Rol: ${datosProveedor['rool']}',
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
                                            idproveedor,
                                            datosProveedor['email'],
                                            datosProveedor['rool'],
                                            datosProveedor['nombreEmpresa'],
                                            datosProveedor['contacto'],
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('proveedor')
                                              .doc(idproveedor)
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
    String idproveedor,
    String emailActual,
    String rolActual,
    String nombreEmpresaActual,
    String contactoActual,
  ) {
    TextEditingController emailControlador = TextEditingController()
      ..text = emailActual;
    TextEditingController rolControlador = TextEditingController()
      ..text = rolActual;
    TextEditingController nombreEmpresaControlador = TextEditingController()
      ..text = nombreEmpresaActual;
    TextEditingController contactoControlador = TextEditingController()
      ..text = contactoActual;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ID Proveedor: $idproveedor', // Muestra el ID, no editable
              ),
              TextField(
                controller: emailControlador,
                decoration: const InputDecoration(labelText: 'Nuevo Email'),
              ),
              TextField(
                controller: rolControlador,
                decoration: const InputDecoration(labelText: 'Nuevo Rol'),
              ),
              TextField(
                controller: nombreEmpresaControlador,
                decoration:
                    const InputDecoration(labelText: 'Nuevo Nombre Empresa'),
              ),
              TextField(
                controller: contactoControlador,
                decoration: const InputDecoration(labelText: 'Nuevo Contacto'),
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
                    .collection('proveedor')
                    .doc(idproveedor)
                    .update({
                  'email': emailControlador.text,
                  'rool': rolControlador.text,
                  'nombreEmpresa': nombreEmpresaControlador.text,
                  'contacto': contactoControlador.text,
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
    // Obtener el último idproveedor de la base de datos
    var ultimosProveedores = await FirebaseFirestore.instance
        .collection('proveedor')
        .orderBy('idproveedor', descending: true)
        .limit(1)
        .get();

    if (ultimosProveedores.docs.isNotEmpty) {
      var ultimoProveedor = ultimosProveedores.docs.first;
      _ultimoIdProveedor = (ultimoProveedor.data()['idproveedor'] ?? 0) + 1;
    } else {
      // Si no hay proveedores en la base de datos, comienza desde 1
      _ultimoIdProveedor = 1;
    }

    TextEditingController emailControlador = TextEditingController();
    TextEditingController rolControlador = TextEditingController();
    TextEditingController nombreEmpresaControlador = TextEditingController();
    TextEditingController contactoControlador = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ID Proveedor: $_ultimoIdProveedor',
              ),
              TextField(
                controller: emailControlador,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: rolControlador,
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
              TextField(
                controller: nombreEmpresaControlador,
                decoration: const InputDecoration(labelText: 'Nombre Empresa'),
              ),
              TextField(
                controller: contactoControlador,
                decoration: const InputDecoration(labelText: 'Contacto'),
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
                await FirebaseFirestore.instance.collection('proveedor').add({
                  'idproveedor': _ultimoIdProveedor,
                  'email': emailControlador.text,
                  'rool': rolControlador.text,
                  'nombreEmpresa': nombreEmpresaControlador.text,
                  'contacto': contactoControlador.text,
                }).then((value) {
                  if (kDebugMode) {
                    print('Usuario agregado correctamente');
                  }
                }).catchError((error) {});

                Navigator.of(context).pop();
              },
              child: const Text('Agregar Usuario'),
            ),
          ],
        );
      },
    );
  }
}
