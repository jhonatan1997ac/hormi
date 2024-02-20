// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Promocion extends StatefulWidget {
  const Promocion({Key? key}) : super(key: key);

  @override
  _PromocionState createState() => _PromocionState();
}

class _PromocionState extends State<Promocion> {
  int _ultimoIdPromocion = 0;
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Promociones',
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
                      .collection('promocion')
                      .orderBy('idpromocion')
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
                                  var datosPromocion =
                                      promociones[index].data();
                                  var idpromocion = promociones[index].id;
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
                                      leading: Image.network(
                                          datosPromocion['imageUrl']),
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
                'ID Promoción: $idpromocion',
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
    var ultimasPromociones = await FirebaseFirestore.instance
        .collection('promocion')
        .orderBy('idpromocion', descending: true)
        .limit(1)
        .get();

    if (ultimasPromociones.docs.isNotEmpty) {
      var ultimaPromocion = ultimasPromociones.docs.first;
      _ultimoIdPromocion = (ultimaPromocion.data()['idpromocion'] ?? 0) + 1;
    } else {
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
              _selectedImage != null
                  ? Image.file(_selectedImage!)
                  : const Text('Seleccionar imagen'),
              ElevatedButton(
                onPressed: () {
                  _mostrarOpcionesImagen(context);
                },
                child: Text('Seleccionar imagen'),
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
                String imageUrl = await _subirImagenFirebaseStorage();
                await FirebaseFirestore.instance.collection('promocion').add({
                  'idpromocion': _ultimoIdPromocion,
                  'idproducto': idproductoControlador.text,
                  'descuento': descuentoControlador.text,
                  'fechainicio': fechainicioControlador.text,
                  'fechafin': fechafinControlador.text,
                  'imageUrl': imageUrl,
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

  Future<String> _subirImagenFirebaseStorage() async {
    String imageUrl = '';

    if (_selectedImage != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('promocion')
            .child('imagen_$_ultimoIdPromocion.jpg');
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      } catch (e) {
        if (kDebugMode) {
          print('Error al subir la imagen: $e');
        }
      }
    }

    return imageUrl;
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
                leading: Icon(Icons.camera),
                title: Text('Tomar foto'),
                onTap: () {
                  _tomarFoto();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Seleccionar de galería'),
                onTap: () {
                  _seleccionarImagenGaleria();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _tomarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        if (kDebugMode) {
          print('No se ha seleccionado ninguna imagen.');
        }
      }
    });
  }

  void _seleccionarImagenGaleria() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        if (kDebugMode) {
          print('No se ha seleccionado ninguna imagen.');
        }
      }
    });
  }
}
