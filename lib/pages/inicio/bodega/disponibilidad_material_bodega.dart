// ignore_for_file: unused_local_variable, unnecessary_null_comparison, use_key_in_widget_constructors, library_private_types_in_public_api, unnecessary_cast, prefer_const_constructors_in_immutables, deprecated_member_use

import 'dart:io';

import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disponibilidad de material',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DisponibilidadMaterial(),
    );
  }
}

class DisponibilidadMaterial extends StatefulWidget {
  const DisponibilidadMaterial({Key? key}) : super(key: key);

  @override
  _DisponibilidadMaterialState createState() => _DisponibilidadMaterialState();
}

class _DisponibilidadMaterialState extends State<DisponibilidadMaterial> {
  late CollectionReference materialesCollection;

  @override
  void initState() {
    super.initState();
    materialesCollection =
        FirebaseFirestore.instance.collection('disponibilidadmaterial');
  }

  Future<void> editarMaterial(MaterialAgregado material) async {
    try {
      MaterialAgregado materialEditado = MaterialAgregado(
        nombre: material.nombre,
        cantidad: material.cantidad,
        descripcion: material.descripcion,
        imagenURL: material.imagenURL,
      );
      bool confirmacion =
          (await _mostrarConfirmacion(context, materialEditado)) as bool;
      if (confirmacion) {
        await materialesCollection.doc(material.nombre).update({
          'cantidad': materialEditado.cantidad,
          'descripcion': materialEditado.descripcion,
        });

        if (kDebugMode) {
          print('Material actualizado: $materialEditado');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al editar el material: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Disponibilidad de material',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: materialesCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final material = MaterialAgregado.fromSnapshot(
                            snapshot.data!.docs[index]);
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                if (material.imagenURL != null)
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Image.network(
                                      material.imagenURL!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nombre: ${material.nombre}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      Text(
                                        'Cantidad: ${material.cantidad}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      Text(
                                        'Descripción: ${material.descripcion}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditarMaterialScreen(
                                          material: material,
                                        ),
                                      ),
                                    ).then((materialActualizado) async {
                                      if (materialActualizado != null) {
                                        await editarMaterial(
                                            materialActualizado);
                                        if (kDebugMode) {
                                          print(
                                              'Material actualizado: $materialActualizado');
                                        }
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    eliminarMaterial(material);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> eliminarMaterial(MaterialAgregado material) async {
    try {
      await materialesCollection.doc(material.nombre).delete();
      if (kDebugMode) {
        print('Material eliminado: ${material.nombre}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar el material: $e');
      }
    }
  }

  Future<bool> _mostrarConfirmacion(
      BuildContext context, MaterialAgregado materialEditado) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar Edición'),
              content:
                  const Text('¿Está seguro de que desea editar este material?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

class MaterialAgregado {
  final String nombre;
  final int cantidad;
  final String descripcion;
  final String? imagenURL;

  MaterialAgregado({
    required this.nombre,
    required this.cantidad,
    required this.descripcion,
    this.imagenURL,
  });

  MaterialAgregado.fromSnapshot(DocumentSnapshot snapshot)
      : nombre = snapshot.id,
        cantidad = snapshot['cantidad'] ?? 0,
        descripcion = snapshot['descripcion'] ?? '',
        imagenURL = snapshot['imagenURL'] ?? '';

  Map<String, dynamic> toMap() {
    return {
      'cantidad': cantidad,
      'descripcion': descripcion,
      'imagenURL': imagenURL,
    };
  }
}

class EditarMaterialScreen extends StatefulWidget {
  final MaterialAgregado material;

  EditarMaterialScreen({required this.material});

  @override
  _EditarMaterialScreenState createState() => _EditarMaterialScreenState();
}

class _EditarMaterialScreenState extends State<EditarMaterialScreen> {
  late TextEditingController nombreController;
  late TextEditingController cantidadController;
  late TextEditingController descripcionController;
  late TextEditingController imagenURLController;
  File? _image;
  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.material.nombre);
    cantidadController =
        TextEditingController(text: widget.material.cantidad.toString());
    descripcionController =
        TextEditingController(text: widget.material.descripcion);
    imagenURLController =
        TextEditingController(text: widget.material.imagenURL ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Material',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: nombreController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Material',
                    labelStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: cantidadController,
                  decoration:
                      const InputDecoration(labelText: 'Cantidad del Material'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: 250,
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder<String?>(
                    future: _getImageUrl(widget.material.imagenURL),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final imageUrl = snapshot.data;
                      return _image != null
                          ? Image.file(
                              _image!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Placeholder(),
                                );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.getImage(source: ImageSource.camera);

                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  } else {
                    if (kDebugMode) {
                      print('No image selected.');
                    }
                  }
                },
                child: const Text('Agregar Foto desde la Cámara'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final materialActualizado = MaterialAgregado(
                    nombre: nombreController.text,
                    cantidad: int.parse(cantidadController.text),
                    descripcion: descripcionController.text,
                    imagenURL: imagenURLController.text,
                  );

                  Navigator.pop(context, materialActualizado);
                },
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _getImageUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }
    try {
      final url = await FirebaseStorage.instance.ref(imageUrl).getDownloadURL();
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener la URL de la imagen: $e');
      }
      return null;
    }
  }
}
