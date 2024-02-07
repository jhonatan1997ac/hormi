import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Proveedor extends StatefulWidget {
  const Proveedor({Key? key}) : super(key: key);

  @override
  _ProveedorState createState() => _ProveedorState();
}

class _ProveedorState extends State<Proveedor> {
  int _ultimoIdProveedor = 0;
  File? _imageFile;

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
                    .orderBy('idproveedor')
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
                      return ListView.builder(
                        itemCount: proveedores.length,
                        itemBuilder: (context, index) {
                          var datosProveedor = proveedores[index].data();
                          var idproveedor = proveedores[index].id;
                          var imageUrl = datosProveedor['imagen'];

                          return Card(
                            child: ListTile(
                              leading: imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Placeholder(),
                                    ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Proveedor ID: ${datosProveedor['idproveedor']}',
                                  ),
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
                            ),
                          );
                        },
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
                'ID Proveedor: $idproveedor',
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
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      width: 100,
                      height: 100,
                    )
                  : const SizedBox(),
              ElevatedButton(
                onPressed: () {
                  _mostrarOpcionesImagen(context);
                },
                child: const Text('Seleccionar Imagen'),
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
                String? imageUrl;
                if (_imageFile != null) {
                  imageUrl = await _subirImagen(_imageFile!);
                }

                await FirebaseFirestore.instance
                    .collection('proveedor')
                    .doc(idproveedor)
                    .update({
                  'email': emailControlador.text,
                  'rool': rolControlador.text,
                  'nombreEmpresa': nombreEmpresaControlador.text,
                  'contacto': contactoControlador.text,
                  'imagen': imageUrl,
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
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      width: 100,
                      height: 100,
                    )
                  : const SizedBox(),
              ElevatedButton(
                onPressed: () {
                  _mostrarOpcionesImagen(context);
                },
                child: const Text('Seleccionar Imagen'),
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
                String? imageUrl;
                if (_imageFile != null) {
                  imageUrl = await _subirImagen(_imageFile!);
                }

                await FirebaseFirestore.instance.collection('proveedor').add({
                  'idproveedor': _ultimoIdProveedor,
                  'email': emailControlador.text,
                  'rool': rolControlador.text,
                  'nombreEmpresa': nombreEmpresaControlador.text,
                  'contacto': contactoControlador.text,
                  'imagen': imageUrl,
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

  void _mostrarOpcionesImagen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: const Text('Seleccionar de la galería'),
                onTap: () {
                  _cargarImagen(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tomar una foto'),
                onTap: () {
                  _cargarImagen(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _cargarImagen(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _subirImagen(File imageFile) async {
    try {
      var imagePath = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await FirebaseStorage.instance.ref(imagePath).putFile(imageFile);
      return await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }
}
